<#
# Creates and shares the folders required for Microsoft Deployment Toolkit
#
# This script:            - Creates shared logs folder
#                         - Creates Deployment Shared folder
#                         - Creates OS Folder in MDT for both Workstation and Windows Server
#                         - Creates Task Sequence folders for both Workstation and Windows Server
#                         - Downloads Applications
#                         - Creates Applications folder
#                         - Imports Applications in the Applications folder for both Workstation and Windows Server
#                         - Imports OS files for both Workstation and Windows Server
#                         - Modifies CustomSettings.ini file
#                         - Modifies Bootstrap.ini file 
# Before running:         Configure the variables below (lines 39-56)
# Usage:                  Run this script on the ConfigMgr Primary Server as a user with Administrative permissions on the server
#>

    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator"))

    {
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Break
    }

# Import MDT PowerShell module for MDT commands
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"

# TestPath funtion
function TestPath($Path) {
if ( $(Try { Test-Path $Path.trim() } Catch { $false }) ) {
   write-host "Path OK"
 }
Else {
   write-host "$Path not found, please fix and try again."
   break
 }}

# Variables
$DriveLetter = "E"
$Computer = get-content env:computername
$FolderPath = "${DriveLetter}:\MDTDeploy"
$ShareName = "MDTDeploy$"
$MDTDescription = "MDT Deployment Share"
$NetPath = "\\$Computer\MDTDeploy$"
$WorkstationOStoDeploy = "Windows 10 X64"
$WorkstationVersiontoDeploy = "1903"
$ServerOStoDeploy = "Windows Server"
$ServerVersiontoDeploy = "2019" 
$SourcePath = "C:\Source"
$AdobePath = "$SourcePath\Applications\Acrobat Reader DC"
$PuttyPath = "$SourcePath\Applications\PuTTY"
$7ZipPath = "$SourcePath\Applications\7-Zip"
$VscPath = "$SourcePath\Applications\Visual Studio Code"
$WorkstationPath = "$SourcePath\$WorkstationOStoDeploy\$WorkstationVersiontoDeploy"
$ServerPath = "$SourcePath\$ServerOStoDeploy\$ServerVersiontoDeploy"

# create folders if needed
if (Test-Path $AdobePath){
 write-host "The Adobe folder already exists."
 } else {

New-Item -Path $AdobePath -ItemType Directory
}

if (Test-Path $PuttyPath){
 write-host "The PuTTY folder already exists."
 } else {

New-Item -Path $PuttyPath -ItemType Directory
}

if (Test-Path $7ZipPath){
 write-host "The 7-Zip folder already exists."
 } else {

New-Item -Path $7ZipPath -ItemType Directory
}

if (Test-Path $VscPath){
 write-host "The Visual Studio Code folder already exists."
 } else {

New-Item -Path $VscPath -ItemType Directory
}

if (Test-Path $WorkstationPath){
 write-host "The Windows 10 Client folder already exists"
 } else {

New-Item -Path $WorkstationPath -ItemType Directory
}

if (Test-Path $ServerPath){
 write-host "The Windows Server folder already exists"
 } else {

New-Item -Path $ServerPath -ItemType Directory
}

# Download Applications
# Adobe Reader DC
# Check if the file exists, if not, download them

 $file1 = $AdobePath+"\AcroRdrDC2200120117_en_US.exe"
 
if (Test-Path $file1){
 write-host "The file $file1 exists."
 } else {
 
# Download Adobe Reader DC 
		Write-Host "Downloading Adobe Reader DC..." -nonewline
		$clnt = New-Object System.Net.WebClient
		$url = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2200120117/AcroRdrDC2200120117_en_US.exe"
		$clnt.DownloadFile($url,$file1)
		Write-Host "done!" -ForegroundColor Green
        cd $AdobePath
        .\AcroRdrDC2200120117_en_US.exe -sfx_o"$AdobePath" -sfx_ne
 }

# PuTTY
# Check if the file exists, if not, download them

 $file2 = $PuttyPath+"\putty-64bit-0.76-installer.msi"
 
if (Test-Path $file2){
 write-host "The file $file2 exists."
 } else {
 
# Download PuTTY 
		Write-Host "Downloading PuTTY..." -nonewline
		$clnt = New-Object System.Net.WebClient
		$url = "https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.76-installer.msi"
		$clnt.DownloadFile($url,$file2)
		Write-Host "done!" -ForegroundColor Green
 }

# 7-Zip
# Check if the file exists, if not, download them

 $file3 = $7ZipPath+"\7z2107-x64.msi"
 
if (Test-Path $file3){
 write-host "The file $file3 exists."
 } else {
 
# Download 7-Zip 
		Write-Host "Downloading 7-Zip..." -nonewline
		$clnt = New-Object System.Net.WebClient
		$url = "https://d3.7-zip.org/a/7z2107-x64.msi"
		$clnt.DownloadFile($url,$file3)
		Write-Host "done!" -ForegroundColor Green
 }

# Visual Studio Code
# Check if the file exists, if not, download them

 $file4 = $VscPath+"\VSCodeSetup-ia32-1.67.0.exe"
 
if (Test-Path $file4){
 write-host "The file $file4 exists."
 } else {
 
# Download Visual Studio Code 
		Write-Host "Downloading Visual Studio Code..." -nonewline
		$clnt = New-Object System.Net.WebClient
		$url = "https://az764295.vo.msecnd.net/stable/57fd6d0195bb9b9d1b49f6da5db789060795de47/VSCodeSetup-ia32-1.67.0.exe"
		$clnt.DownloadFile($url,$file4)
		Write-Host "done!" -ForegroundColor Green
 }

# Creating Logs Folder Share
mkdir "${DriveLetter}:\Logs" 
New-SmbShare -Name "Logs$" -Path "${DriveLetter}:\Logs" -ChangeAccess EVERYONE
icacls "${DriveLetter}:\Logs" /grant '"MDT_BA":(OI)(CI)(M)'

# Make MDT Directory
if (Test-Path "$FolderPath"){
 write-host "'$FolderPath' already exists, will not recreate it."
 } else {
mkdir "$FolderPath"
}

# Create MDT Shared Folder
$Type = 0
$objWMI = [wmiClass] 'Win32_share'
$objWMI.create($FolderPath, $ShareName, $Type)

# Create PS Drive for MDT
New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "$FolderPath" -Description "$MDTDescription" -NetworkPath "$NetPath"  -Verbose | add-MDTPersistentDrive -Verbose

# Create Application Folder in MDT GUI
New-item -path "DS001:\Applications" -enable "True" -Name "Applications" -Comments "" -ItemType "folder" -Verbose

# Import Applications in the DS001:\Applications folder
# Make sure .msi files are in the correct folder in C:\Source\Applications, see -ApplicationSourcePath PARAM
Import-MDTApplication -path "DS001:\Applications\Applications" -enable "True" -Name "Acrobat Reader DC" -ShortName "Acrobat Reader DC" -Publisher "Acrobat" -CommandLine "msiexec /i AcroRead.msi /q" -WorkingDirectory ".\Applications\Acrobat Reader DC" -ApplicationSourcePath "$SourcePath\Applications\Acrobat Reader DC" -DestinationFolder "Acrobat Reader DC" -Verbose 
Import-MDTApplication -path "DS001:\Applications\Applications" -enable "True" -Name "7-Zip" -ShortName "7-Zip" -Publisher "Igor Pavlov" -CommandLine "msiexec /i 7z2107-x64.msi /q" -WorkingDirectory ".\Applications\7-Zip" -ApplicationSourcePath "$SourcePath\Applications\7-Zip" -DestinationFolder "7-Zip" -Verbose 
Import-MDTApplication -path "DS001:\Applications\Applications" -enable "True" -Name "PuTTY" -ShortName "PuTTY" -Publisher "Simon Tatham" -CommandLine "msiexec /i putty-64bit-0.76-installer.msi /q" -WorkingDirectory ".\Applications\PuTTY" -ApplicationSourcePath "$SourcePath\Applications\PuTTY" -DestinationFolder "PuTTY" -Verbose 
Import-MDTApplication -path "DS001:\Applications\Applications" -enable "True" -Name "Visual Studio Code" -ShortName "Visual Studio Code" -Publisher "Microsoft" -CommandLine ".\VSCodeSetup-ia32-1.67.0.exe /VERYSILENT /NORESTART /MERGETASKS=!runcode" -WorkingDirectory ".\Applications\Visual Studio Code" -ApplicationSourcePath "$SourcePath\Applications\Visual Studio Code" -DestinationFolder "Visual Studio Code" -Verbose 

#############################################
# Workstation Configuration
# Create OS Folders for Workstation in MDT GUI
New-item -path "DS001:\Operating Systems" -enable "True" -Name "$WorkstationOStoDeploy" -Comments "" -ItemType "folder" -Verbose
New-item -path "DS001:\Operating Systems" -enable "True" -Name "$WorkstationOStoDeploy\$WorkstationVersiontoDeploy" -Comments "" -ItemType "folder" -Verbose

# Create TS Folders for Workstation in MDT GUI
New-item -path "DS001:\Task Sequences" -enable "True" -Name "$WorkstationOStoDeploy" -Comments "" -ItemType "folder" -Verbose

# Import Operating System Source Files, make sure the os source files are in C:\Source\Operating Systems\Windows 10 x64\1903 for Workstation
Import-mdtoperatingsystem -path "DS001:\Operating Systems\$WorkstationOStoDeploy\$WorkstationVersiontoDeploy" -SourcePath "$SourcePath\Operating Systems\$WorkstationOStoDeploy\$WorkstationVersiontoDeploy" -DestinationFolder "$WorkstationOStoDeploy\$WorkstationVersiontoDeploy" -Verbose

#############################################
# Server Configuration
# Create OS Folders for Server in MDT GUI
New-item -path "DS001:\Operating Systems" -enable "True" -Name "$ServerOStoDeploy" -Comments "" -ItemType "folder" -Verbose
New-item -path "DS001:\Operating Systems" -enable "True" -Name "$ServerOStoDeploy\$ServerVersiontoDeploy" -Comments "" -ItemType "folder" -Verbose

# Create TS Folders for Server in MDT GUI
New-item -path "DS001:\Task Sequences" -enable "True" -Name "$ServerOStoDeploy" -Comments "" -ItemType "folder" -Verbose

# Import Operating System Source Files, make sure the os source files are in C:\Source\Operating Systems\Windows 10 x64\1903 for Workstation
Import-mdtoperatingsystem -path "DS001:\Operating Systems\$ServerOStoDeploy\$ServerVersiontoDeploy" -SourcePath "$SourcePath\Operating Systems\$ServerOStoDeploy\$ServerVersiontoDeploy" -DestinationFolder "$ServerOStoDeploy\$ServerVersiontoDeploy" -Verbose

#############################################
# Modifying the standard CustomSettings.ini
#

$JoinDomain="thematrix.local"
$DomainAdmin="$JoinDomain\MDT_JD"
$DomainAdminPassword="Admin2022"

$CSFile = @"
[Settings]
Priority=Model, Default
Properties=MyCustomProperty

[Default]
OSInstall=Y
SkipCapture=YES
DoCapture=NO
SkipAdminPassword=YES
SkipProductKey=YES
SkipComputerBackup=YES
SkipBitLocker=YES
SkipComputerName=NO
SkipDomainMembership=NO
JoinDomain=$JoinDomain
DomainAdmin=$DomainAdmin
DomainAdminDomain=$JoinDomain
DomainAdminPassword=$DomainAdminPassword
MachineObjectOU=OU=Computers,OU=thematrix,DC=thematrix,DC=local
UILanguage=en-US
UserLocale=nl-BE
SystemLocale=nl-NL
KeyboardLocale:0813:00000813
TimeZoneName=Romance Standard Time
SkipTimeZone=YES
SkipLocaleSelection=YES
UserID=Administrator
UserDomain=thematrix.local
UserPassword=Admin2022
"@ 

# Modifying theCustomSettings.ini file
Remove-Item -Path "$FolderPath\Control\CustomSettings.ini" -Force
New-Item -Path "$FolderPath\Control\CustomSettings.ini" -ItemType File -Value $CSFile

##############################################
# Modifying the standard BootStrap.ini
# 

$MDTServer="theoracle.thematrix.local"
$UserID="MDT_BA"
$UserPassword="Admin2022"
$UserDomain="thematrix.local"

$BSFile = @"
[Settings]
Priority=Default

[Default]
SkipBDDWelcome=YES
DeployRoot=\\THEORACLE\MDTDeploy$
UserID=$UserID
UserPassword=$UserPassword
UserDomain=$UserDomain
"@ 

# Modifying the BootStrap.ini file
Remove-Item -Path "$FolderPath\Control\BootStrap.ini" -Force
New-Item -Path "$FolderPath\Control\BootStrap.ini" -ItemType File -Value $BSFile
