<# 
# Download Microsoft Deployment Toolkit
#
# This Script:          The script Microsoft Deployment Toolkit
# Before running:       Modify the ADK download path source variable (line 23) 
# Usage:                Run this script on the ConfigMgr Primary Server as a user with local Administrative permissions on the server
#>

  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator"))

    {
        Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
        Break
    }

Write-Host "This scripts needs unrestricted access (Set-ExecutionPolicy Unrestricted.) " -nonewline -ForegroundColor Green
Write-Host "The entire setup takes around 30 minutes (depending on your internet speed and if components are already downloaded)." -nonewline -ForegroundColor Green
Write-Host "At the end of the process, if there are any errors they will be shown in red text, review them to see what failed." -ForegroundColor Green
Write-Host " "

# Variables (where to download content)
$SourcePath = "C:\Source"

# Check if the folder exists, if not, create it
 if (Test-Path $SourcePath){
 Write-Host "The folder $SourcePath exists."
 } else{
 Write-Host "The folder $SourcePath does not exist, creating..." -NoNewline
 New-Item $SourcePath -type directory | Out-Null
 Write-Host "done!" -ForegroundColor Green
 }
 
# Check if these files exists, if not, download them
 $file3 = $SourcePath+"\MicrosoftDeploymentToolkit_x64.msi"

 if (Test-Path $file3){
 write-host "The file $file3 exists."
 } else {
 
# Download Microsoft Deployment Toolkit
		Write-Host "Downloading Microsoft Deployment Toolkit..." -nonewline
		$clnt = New-Object System.Net.WebClient
		$url = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
		$clnt.DownloadFile($url,$file3)
		Write-Host "done!" -ForegroundColor Green
 }