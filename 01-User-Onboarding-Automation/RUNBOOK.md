📘 Automated User Onboarding Lab — Runbook
🎯 Objective

Automate creation of new users in Microsoft Entra ID using Microsoft Graph PowerShell, assign them to a security group, and generate a Temporary Access Pass (TAP).

This simulates a real IAM onboarding workflow.

🧠 Workflow Overview
Prepare → Connect → Execute → Verify → Report

✅ Step 1 — Preparation
1.1 Update CSV File

Location:
Data/newhires.csv
Add new test users with unique UPNs:
DisplayName,FirstName,LastName,Department,JobTitle,UserPrincipalName
John Carter,John,Carter,Sales,Sales Rep,john.carter30@brownsense.net
Sarah Lee,Sarah,Lee,HR,HR Specialist,sarah.lee30@brownsense.net

You do NOT need to delete previous users.

1.2 Confirm Group ID

Ensure the group Object ID in the script is correct:
$groupId = "YOUR-GROUP-ID"

Documentation reference point:

Group IDs can be retrieved from Microsoft Entra portal → Groups → Properties.

1.3 Confirm Temporary Access Pass Enabled

Portal:

Entra Admin Center
→ Protection
→ Authentication Methods
→ Temporary Access Pass

Status: Enabled

✅ Step 2 — Connect to Microsoft Graph

Open PowerShell or VS Code terminal.

Run:

Connect-MgGraph -Scopes `
"User.ReadWrite.All",
"Group.ReadWrite.All",
"Directory.ReadWrite.All",
"UserAuthenticationMethod.ReadWrite.All"

Explanation:

Authenticates PowerShell session to Microsoft Entra.

Documentation reference point:

Microsoft Graph permissions documentation.

Optional verification:

Get-MgContext
✅ Step 3 — Execute Automation Script

Navigate to project folder:

cd C:\Path\To\Project\Scripts

Run script:

.\NewHire-Onboarding.ps1

Expected output:

Creating user

Added to group

TAP created

Report generated

Documentation reference point:

Microsoft Graph PowerShell command references.

✅ Step 4 — Verify Results in Entra Portal

Open:

https://entra.microsoft.com

Verify:

4.1 Users Created
Identity → Users

Confirm new users exist.

4.2 Group Membership
Groups → Your Group → Members

Confirm users added.

4.3 Authentication Methods (Optional)

Open user → Authentication methods.

✅ Step 5 — Review Report Output

Script exports report automatically.

Location example:

OnboardingReport_YYYY-MM-DD.csv

Purpose:

Operational tracking

Audit record

Troubleshooting reference

✅ Step 6 — Talking Points for Recording

Use these during your video.

Introduction

This lab demonstrates automated user onboarding using Microsoft Entra ID and Microsoft Graph PowerShell. The script provisions users from a CSV file, assigns group membership, and generates a Temporary Access Pass for secure onboarding.

During Graph Connection

I reference Microsoft documentation when confirming required Graph permissions.

During Script Execution

The script reads HR-provided data, creates users, assigns access, and secures initial authentication using TAP.

During Verification

Verifying results in the portal confirms automation completed successfully.

Closing

This automation reflects common IAM lifecycle tasks performed by identity administrators.

✅ Step 7 — Reset for Next Practice

For repeated practice:

Update CSV with new UPN numbers

Keep group and previous users

Re-run script

No deletion required.