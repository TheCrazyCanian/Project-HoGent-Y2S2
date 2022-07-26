<# Computer Configuration
#
# This script:            Configures the Active directory, creates Users
# Before running:         Configure the variables below (line 21-24)
# Usage:                  Run this script as Administrator
#
#>

  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator"))

    {
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Break
    }

# Import required modules
Import-Module ActiveDirectory

# Create password
$securepassword = ConvertTo-SecureString "Admin2022" -AsPlainText -Force

# Variables
$csvpath = "C:\Users.csv"

# Import csv file into a variable
$users = Import-Csv $csvpath -Delimiter ";"

# Loop through each row
ForEach($user in $users) {
    
    # Info per user
    $fname = $user.'First Name'
    $lname = $user.'Last Name'
    $jtitle = $user.'Job Title'
    $OUPath = $user.'Organizational Unit'

    # Create new AD user for each user in CSV file
    New-ADUser -Name "$fname $lname" -Path $OUPath -GivenName $fname -Surname $lname -UserPrincipalName "$fname.$lname" -AccountPassword $securepassword -ChangePasswordAtLogon $true -Enabled $true 
}

# Creating MDT and Exchange Admin accounts
New-ADUser -Name "EchangeAdmin" -SamAccountName "ExchangeAdmin" -AccountPassword $securepassword -PasswordNeverExpires:$true -ChangePasswordAtLogon $false -Enabled $true
Add-ADGroupMember -Identity "Administrators" -Members "ExchangeAdmin"
Add-ADGroupMember -Identity "Domain Admins" -Members "ExchangeAdmin"

New-ADUser -Name "MDTAdmin" -SamAccountName "MDTAdmin" -AccountPassword $securepassword -PasswordNeverExpires:$true -ChangePasswordAtLogon $false -Enabled $true
Add-ADGroupMember -Identity "Administrators" -Members "MDTAdmin"
Add-ADGroupMember -Identity "Domain Admins" -Members "MDTAdmin"

