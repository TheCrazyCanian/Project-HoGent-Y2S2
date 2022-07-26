<# Installs Active Directory Domain Services
#
# This script:            Installs the Active Directory Domain Services and promotes the computer to the domaincontroller
# Before running:         Configure the variable below (line 17)
# Usage:                  Run this script as Administrator on a Domain joined server
#>

  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator"))

    {
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Break
    }

# Variables
$domainname="thematrix.local"

#Installation Active Directory Domain Services
Install-WindowsFeature AD-domain-services -IncludeAllSubFeature -IncludeManagementTools 
Import-Module ADDSDeployment

#Promotion of the computer to the domaincontroller
Install-ADDSForest -DomainName $domainname -CreateDnsDelegation:$false -InstallDns:$false
