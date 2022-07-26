<#
# Reconfigures MDT Shared folder permissions in case of an error
#
# This script:            Reconfigures MDT Shared folder permissions in case of an error
# Before running:         Modify the variable (line 19)
# Usage:                  Run this script on the ConfigMgr Primary Server as a user with local Administrative permissions on the server
#>


 If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator"))

    {
        Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
        Break
    }

# Variables
$SharedFolder= "E:\MDTDeploy" 

# Configure NTFS Permissions for the MDT deployment share
$DeploymentShareNTFS = $SharedFolder
icacls $DeploymentShareNTFS /grant '"Users":(OI)(CI)(RX)'
icacls $DeploymentShareNTFS /grant '"Administrators":(OI)(CI)(F)'
icacls $DeploymentShareNTFS /grant '"SYSTEM":(OI)(CI)(F)'

# Configure Sharing Permissions for the MDT deployment share
$DeploymentShare = $SharedFolder
Grant-SmbShareAccess -Name $DeploymentShare -AccountName "EVERYONE" -AccessRight Change -Force
Revoke-SmbShareAccess -Name $DeploymentShare -AccountName "CREATOR OWNER" -Force