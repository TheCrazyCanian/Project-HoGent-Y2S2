<# Computer Configuration
#
# This script:            Configures a computer
# Before running:         Configure the variables below (lines 18-24)
# Usage:                  Run this script as Administrator
#
#>

  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator"))

    {
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Break
    }

# Parameters
$ComputerName = "agentsmith"
$Adapter = "Ethernet"
$Adapter2 = "Ethernet 2"
$IP_Adress = "172.16.128.50"
$NetMask = "28"
$DefaultGateway = "172.16.128.49"
$DNSServer = "172.16.128.51"

# Changing computername
Write-Host "Changing to name of the computer..."
Rename-Computer -NewName $ComputerName

# Configuring the network adapter
Write-Host "Changing the network adapter..."
New-NetIPAddress -InterfaceAlias $Adapter -IPAddress $IP_Adress -PrefixLength $NetMask -DefaultGateway $DefaultGateway
Set-DnsClientServerAddress -InterfaceAlias $Adapter -ServerAddresses $DNSServer 
Set-DnsClientServerAddress -InterfaceAlias $Adapter2 -ServerAddresses $DNSServer

# Restarting the computer
Write-Host "Restarting computer..."
Restart-Computer
