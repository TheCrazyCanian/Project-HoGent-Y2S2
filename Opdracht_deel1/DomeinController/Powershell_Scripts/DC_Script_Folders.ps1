<# Folder Configuration
#
# This script:            Configures the User Home Folders
-# Before running:         Change the variables (lines 17-19)
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
$path = "E:\UserFolders"
$name = "UserFolders"
$fullaccess = "thematrix\Domain Users"

New-Item -Path $path -ItemType "Directory"
New-SmbShare -Name $name -path $path -FullAccess $fullaccess

