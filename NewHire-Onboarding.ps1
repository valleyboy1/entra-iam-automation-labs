# NewHire-Onboarding.ps1
# Creates users from CSV, adds them to a group, and issues a Temporary Access Pass (TAP)
# Folder: C:\IAM-Projects\Onboarding
# CSV:    C:\IAM-Projects\Onboarding\newhires.csv

# ---- SETTINGS ----
$csvPath = "C:\IAM-Projects\Onboarding\Data\newhires.csv"
$groupId = "79e52812-8b4c-4f6b-baa5-5d4d6005e199"   # <-- Replace with your Entra Group Object ID

# ---- CONNECT ----
Connect-MgGraph -Scopes `
  "User.ReadWrite.All",`
  "Group.ReadWrite.All",`
  "Directory.ReadWrite.All",`
  "UserAuthenticationMethod.ReadWrite.All" `
  -NoWelcome

$newHires = Import-Csv $csvPath

$report = @()

foreach ($u in $newHires) {

    Write-Host "Creating user: $($u.DisplayName)" -ForegroundColor Cyan

    $passwordProfile = @{
        Password = "TempPass123!"
        ForceChangePasswordNextSignIn = $true
    }

    # --- Create user ---
    $newUser = New-MgUser `
        -DisplayName $u.DisplayName `
        -GivenName $u.FirstName `
        -Surname $u.LastName `
        -Department $u.Department `
        -JobTitle $u.JobTitle `
        -MailNickname (($u.FirstName + "." + $u.LastName).ToLower()) `
        -UserPrincipalName $u.UserPrincipalName `
        -AccountEnabled:$true `
        -PasswordProfile $passwordProfile

    # --- Add to group ---
    try {
        New-MgGroupMember -GroupId $groupId -DirectoryObjectId $newUser.Id -ErrorAction Stop
        $groupStatus = "Success"
        Write-Host "Added to group." -ForegroundColor Green
    }
    catch {
        $groupStatus = "Failed: $($_.Exception.Message)"
        Write-Host "Group add FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ---- Wait for provisioning (helps TAP) ----
    Start-Sleep -Seconds 10

    # --- Create TAP (retry) ---
    $tap = $null
    $tapStatus = "Failed"
    $tapValue = ""

    for ($i = 1; $i -le 3; $i++) {
        try {
            $params = @{ isUsableOnce = $true; lifetimeInMinutes = 60 }
            $tap = New-MgUserAuthenticationTemporaryAccessPassMethod `
                -UserId $newUser.Id `
                -BodyParameter $params `
                -ErrorAction Stop

            $tapStatus = "Success"
            $tapValue  = $tap.TemporaryAccessPass
            Write-Host "TAP Created: $tapValue" -ForegroundColor Yellow
            break
        }
        catch {
            Write-Host "TAP attempt $i failed for $($u.UserPrincipalName). Retrying in 10s..." -ForegroundColor DarkYellow
            Start-Sleep -Seconds 10
        }
    }

    # --- Report row ---
    $report += [PSCustomObject]@{
        DisplayName = $u.DisplayName
        UPN         = $u.UserPrincipalName
        UserId      = $newUser.Id
        GroupAdd    = $groupStatus
        TAPStatus   = $tapStatus
        TAP         = $tapValue
        Timestamp   = (Get-Date)
    }
}

# ---- Export Report ----
$reportPath = "C:\IAM-Projects\Onboarding\OnboardingReport_$(Get-Date -Format 'yyyy-MM-dd_HHmm').csv"
$report | Export-Csv -NoTypeInformation -Path $reportPath
Write-Host "Onboarding complete. Report saved to: $reportPath" -ForegroundColor Green