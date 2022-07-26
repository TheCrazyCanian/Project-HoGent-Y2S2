<# Group Policy Editor
#
# This script:            Configures the Group Policies
-# Before running:        Configure the variables below (lines 18-20)
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
$noControlPanel = "Block Control Panel for users"
$noNetworkProperties = "Block Network Adapter properties for users"
$noGamesLink = "Delete Games Link from startmenu"

New-GPO -Name $noControlPanel
New-GPO -Name $noNetworkProperties
New-GPO -Name $noGamesLink

#region Prohibit access to Control Panel and PC settings

#Create the key if missing 
If((Test-Path 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer') -eq $false ) { 
    New-Item -Path 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -force -ea SilentlyContinue 
    } 

#Enable the Policy
Set-GPRegistryValue -Name $noControlPanel -Key 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -ValueName 'NoControlPanel' -Value 1 -Type DWord -ea SilentlyContinue 

#endregion

#region Prohibit access to properties of a LAN connection

#Create the key if missing 
If((Test-Path 'HKCU\Software\Policies\Microsoft\Windows\Network Connections') -eq $false ) { 
    New-Item -Path 'HKCU:\Software\Policies\Microsoft\Windows\Network Connections' -force -ea SilentlyContinue 
    } 

#Enable the Policy
Set-GPRegistryValue -Name $noNetworkProperties -Key 'HKCU\Software\Policies\Microsoft\Windows\Network Connections' -ValueName 'NC_LanProperties' -Value 0 -Type DWord -ea SilentlyContinue 

#endregion

#region Remove Games link from Start Menu

#Create the key if missing 
If((Test-Path 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer') -eq $false ) { 
    New-Item -Path 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -force -ea SilentlyContinue 
    }


#Enable the Policy
Set-GPRegistryValue -Name $noGamesLink -Key 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -ValueName 'NoStartMenuMyGames' -Value 1 -Type DWord -ea SilentlyContinue 

#endregion

#Link GPO's to the OU's
Get-GPO -Name $noControlPanel | New-GPLink -target "OU=Administratie,DC=thematrix,DC=local" -LinkEnabled Yes
Get-GPO -Name $noControlPanel | New-GPLink -target "OU=Directie,DC=thematrix,DC=local" -LinkEnabled Yes
Get-GPO -Name $noControlPanel | New-GPLink -target "OU=Ontwikkeling,DC=thematrix,DC=local" -LinkEnabled Yes
Get-GPO -Name $noControlPanel | New-GPLink -target "OU=Verkoop,DC=thematrix,DC=local" -LinkEnabled Yes

Get-GPO -Name $noNetworkProperties | New-GPLink -target "OU=Administratie,DC=thematrix,DC=local" -LinkEnabled Yes
Get-GPO -Name $noNetworkProperties | New-GPLink -target "OU=Verkoop,DC=thematrix,DC=local" -LinkEnabled Yes

Get-GPO -Name $noGamesLink | New-GPLink -target "OU=Administratie,DC=thematrix,DC=local" -LinkEnabled Yes
Get-GPO -Name $noGamesLink | New-GPLink -target "OU=Directie,DC=thematrix,DC=local" -LinkEnabled Yes
Get-GPO -Name $noGamesLink | New-GPLink -target "OU=Ontwikkeling,DC=thematrix,DC=local" -LinkEnabled Yes
Get-GPO -Name $noGamesLink | New-GPLink -target "OU=Verkoop,DC=thematrix,DC=local" -LinkEnabled Yes
Get-GPO -Name $noGamesLink | New-GPLink -target "OU=IT Administratie,DC=thematrix,DC=local" -LinkEnabled Yes
