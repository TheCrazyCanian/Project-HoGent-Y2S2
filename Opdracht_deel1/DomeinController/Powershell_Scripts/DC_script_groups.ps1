<# Computer Configuration
#
# This script:            Configures the Active directory, creates OU's and Groups
# Before running:         
# Usage:                  Run this script as Administrator
#
#>

  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator"))

    {
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Break
    }

#OU aanmaken
New-ADOrganizationalUnit -Name "Administratie" -Path "DC=thematrix, DC=local";
New-ADOrganizationalUnit -Name "Directie" -Path "DC=thematrix,DC=local";
New-ADOrganizationalUnit -Name "IT Administratie" -Path "DC=thematrix,DC=local";
New-ADOrganizationalUnit -Name "Ontwikkeling" -Path "DC=thematrix,DC=local";
New-ADOrganizationalUnit -Name "Verkoop" -Path "DC=thematrix,DC=local";


#Groepen aanmaken
New-ADGroup -Name "Administratie" -SamAccountName "Administratie" -GroupCategory Security -GroupScope Global -DisplayName "Administratie" -Path "OU=Administratie,DC=thematrix,DC=local"
New-ADGroup -Name "Directie" -SamAccountName "Directie" -GroupCategory Security -GroupScope Global -DisplayName "Directie" -Path "OU=Directie,DC=thematrix,DC=local"
New-ADGroup -Name "IT Administratie" -SamAccountName "IT Administratie" -GroupCategory Security -GroupScope Global -DisplayName "IT Administratie" -Path "OU=IT Administratie,DC=thematrix,DC=local"
New-ADGroup -Name "Ontwikkeling" -SamAccountName "Ontwikkeling" -GroupCategory Security -GroupScope Global -DisplayName "Ontwikkeling" -Path "OU=Ontwikkeling,DC=thematrix,DC=local"
New-ADGroup -Name "Verkoop" -SamAccountName "Verkoop" -GroupCategory Security -GroupScope Global -DisplayName "Verkoop" -Path "OU=Verkoop,DC=thematrix,DC=local"