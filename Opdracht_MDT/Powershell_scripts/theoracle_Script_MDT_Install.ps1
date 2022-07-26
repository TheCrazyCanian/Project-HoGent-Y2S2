<#
# Install Microsoft Deployment Toolkit
#
# This script:            Installs Microsoft Deployment Toolkit
# Before running:         Modify the MDT download path source variable (lines 18)
# Usage:                  Run this script on the ConfigMgr Primary Server as a user with local Administrative permissions on the server
#>

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator"))

    {
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Break
    }

# Variables
$SourcePath = "C:\Source"

# Installing Microsoft Deployment Toolkit
Write-Host "Installing Microsoft Deployment Toolkit"
msiexec /qb /i "$SourcePath\MicrosoftDeploymentToolkit_x64.msi" | Out-Null

Start-Sleep -s 10
Write-Host "Done !"