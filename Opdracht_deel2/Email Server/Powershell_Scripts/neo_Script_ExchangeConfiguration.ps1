<# Microsoft Exchange 2019 Configuration Spam Filter installation
#
# This script:            Configures Microsoft Exchange 2019
# Before running:         Configure the variables below (line 18)
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
$s = New-PSSession -ConfigurationName microsoft.exchange -ConnectionUri http://neo.thematrix.local/powershell

Import-PSSession $s

Write-Host "Creating Send Connector..."
New-SendConnector -Internet -Name "Send Connector" -AddressSpaces * 

Write-Host "Creating AD Users mailboxes..."
Enable-Mailbox -Identity "Kelsey Mason" -Alias "kelsey.mason"
Enable-Mailbox -Identity "Mike Terry" -Alias "mike.terry"
Enable-Mailbox -Identity "Stan Kenzie" -Alias "stan.kenzie"
Enable-Mailbox -Identity "Ridley Dalton" -Alias "ridley.dalton"
Enable-Mailbox -Identity "Clyde Braiden" -Alias "clyde.braiden"

# Install Anti Spam Agents
Write-Host "Installing Anti Spam Agents..."
cd "C:\Program Files\Microsoft\Exchange Server\V15\Scripts\"
.\install-AntispamAgents.ps1

Write-Host "Restarting Microsoft Exchange Transport service..."
Restart-Service -Name MSExchangeTransport

Write-Host "Configuring Transport Service..."
Set-TransportConfig -InternalSMTPServers 172.16.128.53
Set-SenderFilterConfig -Enabled $true
Set-SenderFilterConfig -BlankSenderBlockingEnabled $true
Set-SenderFilterConfig -InternalMailEnabled $true

Set-RecipientFilterConfig -Enabled $true
Set-RecipientFilterConfig -BlockListEnabled $true
Set-RecipientFilterConfig -RecipientValidationEnabled $true
Set-ReceiveConnector "NEO\Default Frontend NEO" -TarpitInterval 00:00:06
Restart-Service -Name MSExchangeTransport

Set-SenderIdConfig -Enabled $true
Set-SenderIdConfig -SpoofedDomainAction StampStatus

Set-ContentFilterConfig -Enabled $true
Set-ContentFilterConfig -SCLDeleteEnabled $true -SCLDeleteThreshold 8
Set-ContentFilterConfig -QuarantineMailbox spam@thematrix.local
Set-ContentFilterConfig -SCLQuarantineEnabled $true -SCLQuarantineThreshold 5
Set-OrganizationConfig -SCLJunkThreshold 3

Set-Mailbox -Identity Administrator -SCLJunkEnabled $true -SCLJunkThreshold 4
Set-Mailbox -Identity Administrator -SCLDeleteEnabled $null
Set-Mailbox -Identity Administrator -SCLDeleteThreshold $null

Get-Mailbox -OrganizationalUnit thematrix.local/Users | Set-Mailbox -SCLDeleteEnabled $true -SCLDeleteThreshold 8
Set-Mailbox -Identity Administrator -AntispamBypassEnabled $true

Add-ContentFilterPhrase -Influence GoodWord -Phrase "good phrase"
Add-ContentFilterPhrase -Influence BadWord -Phrase "bad phrase"

Set-ContentFilterConfig -BypassedRecipients @{Add="Administrator@thematrix.local"}

Set-ContentFilterConfig -RejectionResponse "Blocked as spam."
