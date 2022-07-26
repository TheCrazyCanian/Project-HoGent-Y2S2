<# Installs Exchange Server 2019 Prerequisites
#
# This script:            Installs Exchange Server 2019 Prerequisites
# Before running:         Configure the variables below (lines 22-23)
# Usage:                  Run this script as Administrator on the domaincontroller
#
#>

  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator"))

    {
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Break
    }

# Download Links: 
# .NET 4.8: https://go.microsoft.com/fwlink/?linkid=2088631
# Exchange 2019: https://www.microsoft.com/en-us/download/confirmation.aspx?id=102900

# Variables
$ExchangeInstallationMedia = "F:"
$DotNetInstallationMedia = "C:\ndp48-x86-x64-allos-enu.exe"

# Installing .NET 4.8 (follow prompt to complete installation)
Write-Host "Installing .NET 4.8 (follow prompt to complete installation)"
& $DotNetInstallationMedia /run /quiet /SilentMode
Start-Sleep -s 30
Restart-Computer -Force

#Extend the Active Directory schema
Write-Host "Extending the Active Directory schema"
cd $ExchangeInstallationMedia
.\setup /PrepareSchema /IAcceptExchangeServerLicenseTerms

# Prepare Active Directory for Exchange 2019
Write-Host "Preparing the Active Directory for Exchange 2019"
.\setup /PrepareAD /OrganizationName:"THEMATRIX" /IAcceptExchangeServerLicenseTerms

# Prepare the domain
Write-Host "Preparing the domain"
.\setup /Preparedomain /IAcceptExchangeServerLicenseTerms
Restart-Computer -Force