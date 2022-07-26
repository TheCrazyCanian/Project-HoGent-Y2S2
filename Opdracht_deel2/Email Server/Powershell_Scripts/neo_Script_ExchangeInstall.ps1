<# Microsoft Exchange 2019 Installation
#
# This script:            Install Microsoft Exchange 2019
# Before running:         Configure the variables below (line 21)
# Usage:                  Run this script as Administrator
#
#>

  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator"))

    {
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Break
    }

# Download Link
# Exchange 2019: https://www.microsoft.com/en-us/download/confirmation.aspx?id=102900

#Variables
$ExchangeInstallationMedia = "E:"

# Installation
Write-Host "Installing Microsoft Exchange 2019"
cd $ExchangeInstallationMedia
.\setup.exe /mode:Install /role:Mailbox /OrganizationName:"THEMATRIX" /IAcceptExchangeServerLicenseTerms /InstallWindowsComponents /CustomerFeedbackEnabled:False
