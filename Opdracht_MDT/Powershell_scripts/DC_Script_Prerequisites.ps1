<# Domain controller Configuration for Microsoft Deployment toolkit
#
# This script:            Configures a domaincontroller 
# Before running:         Configure the variables below (lines 18)
# Usage:                  Run this script as Administrator
#
#>

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator"))

    {
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Break
    }

# Variables
$csvPath = "C:\oulist.csv"

# Creating OU structure
Import-CSV -Path $csvPath | ForEach-Object {
    New-ADOrganizationalUnit -Name $_.ouname -Path $_.oupath
    Write-Host -ForegroundColor Green "OU $($_.ouname) is created in the location $($_.oupath)"
}

# Create the MDT service account MDT Build Account
New-ADUser -Name MDT_BA -UserPrincipalName MDT_BA -path "OU=Service Accounts,OU=Accounts,OU=thematrix,DC=thematrix,DC=local" -Description "MDT Build Account" -AccountPassword (ConvertTo-SecureString "Admin2022" -AsPlainText -Force) -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Enabled $true

# Creating MDT Join Domain account
New-ADUser -Name MDT_JD -UserPrincipalName MDT_JD@ -path "OU=Service Accounts,OU=Accounts,OU=thematrix,DC=thematrix,DC=local" -Description "MDT join domain account" -AccountPassword (ConvertTo-SecureString "Admin2022" -AsPlainText -Force) -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Enabled $true

# Set OUPermissions
Write-host (get-date -Format u)" - Starting"

$Account1 = "MDT_BA"
$Account2 = "MDT_JD"
$TargetOU = "OU=Service Accounts,OU=Accounts,OU=thematrix"

$CurrentDomain = Get-ADDomain

$OrganizationalUnitDN = $TargetOU+","+$CurrentDomain
$SearchAccount1 = Get-ADUser $Account1
$SearchAccount2 = Get-ADUser $Account2

$SAM1 = $SearchAccount1.SamAccountName
$SAM2 = $SearchAccount2.SamAccountName
$UserAccount1 = $CurrentDomain.NetBIOSName+"\"+$SAM1
$UserAccount2 = $CurrentDomain.NetBIOSName+"\"+$SAM2

Write-Host "Account is = $UserAccount1"
Write-host "OU is =" $OrganizationalUnitDN

dsacls.exe $OrganizationalUnitDN /G $UserAccount1":CCDC;Computer" /I:T | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount1":LC;;Computer" /I:S | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount1":RC;;Computer" /I:S | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount1":WD;;Computer" /I:S  | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount1":WP;;Computer" /I:S  | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount1":RP;;Computer" /I:S | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount1":CA;Reset Password;Computer" /I:S | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount1":CA;Change Password;Computer" /I:S | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount1":WS;Validated write to service principal name;Computer" /I:S | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount1":WS;Validated write to DNS host name;Computer" /I:S | Out-Null
dsacls.exe $OrganizationalUnitDN

Write-Host "
The following permissions were being granted to '$Account1':

Scope: This object and all descendant objects
Create Computer objects
Delete Computer objects
Scope: Descendant Computer objects
Read All Properties
Write All Properties
Read Permissions
Modify Permissions
Change Password
Reset Password
Validated write to DNS host name
Validated write to service principal name"

Write-Host "Account is = $UserAccount2"
Write-host "OU is =" $OrganizationalUnitDN

dsacls.exe $OrganizationalUnitDN /G $UserAccount2":CCDC;Computer" /I:T | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount2":LC;;Computer" /I:S | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount2":RC;;Computer" /I:S | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount2":WD;;Computer" /I:S  | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount2":WP;;Computer" /I:S  | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount2":RP;;Computer" /I:S | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount2":CA;Reset Password;Computer" /I:S | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount2":CA;Change Password;Computer" /I:S | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount2":WS;Validated write to service principal name;Computer" /I:S | Out-Null
dsacls.exe $OrganizationalUnitDN /G $UserAccount2":WS;Validated write to DNS host name;Computer" /I:S | Out-Null
dsacls.exe $OrganizationalUnitDN

Write-Host "
The following permissions were being granted to '$Account2':

Scope: This object and all descendant objects
Create Computer objects
Delete Computer objects
Scope: Descendant Computer objects
Read All Properties
Write All Properties
Read Permissions
Modify Permissions
Change Password
Reset Password
Validated write to DNS host name
Validated write to service principal name"