<# Installing and configuring Distributed File System
#
# This script:            Configures and installs Distributed File System
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

    #Variables
    $shareFolder = "C:\DFSRoots\UserShare "
    $nameFolder = "UserShare"
    $path = "\\agentsmith\UserShare"

    #Install DFS
    Install-WindowsFeature FS-DFS-Namespace, RSAT-DFS-Mgmt-Con

    #Creating Usershare folder
    mkdir $shareFolder 

    #Creating Share
    New-SmbShare -Name $nameFolder -Path $shareFolder -FullAccess 'Everyone'
    New-DfsnRoot -Path $path -Type standalone -TargetPath $path 
    Get-DfsnRoot -Path $path | Format-List