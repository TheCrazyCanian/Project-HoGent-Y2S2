<# Installs Microsoft Exchange 2019
#
# This script:            Installs Microsoft Exchange 2019
#
# Before running:         Configure the variables below (lines 25-28)
# Usage:                  Run this script as Administrator
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
# Visual C++ Redistributable Packages: https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe
#                                      https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x86.exe
# Unified Communications Managed API 4.0 Runtime: https://www.microsoft.com/en-us/download/confirmation.aspx?id=34992

# Variables
$DotNetInstallationMedia = "C:\ndp48-x86-x64-allos-enu.exe"
$C2013x64InstallationMedia = "C:\vcredist_x64.exe"
$C2013x86InstallationMedia = "C:\vcredist_x86.exe"
$UcmaInstallationMedia = "C:\UcmaRuntimeSetup.exe"

# Installing .NET 4.8 (follow prompt to complete installation)
Write-Host "Installing .NET 4.8 (follow prompt to complete installation)"
& $DotNetInstallationMedia /run /quiet /SilentMode

Write-Host "Checking .NET version"
(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' ).Release

# Installing Visual C++ 2013 Redistributable Package
Write-Host "Installing Visual C++ 2013 Redistributable Package"
& $C2013x64InstallationMedia /run /quiet /SilentMode
& $C2013x86InstallationMedia /run /quiet /SilentMode

# Installing Microsoft Unified Communications Managed API 4.0
Write-Host "Installing Microsoft Unified Communications Managed API 4.0"
& $UcmaInstallationMedia /run /quiet /SilentMode
Restart-Computer -Force

# Installing Remote Tools Administration Pack
Write-Host "Installing Remote Tools Administration Pack"
Install-WindowsFeature RSAT-ADDS

# Installing Required Windows Components
Write-Host "Installing Required Windows Components"
Install-WindowsFeature NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation
