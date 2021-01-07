param(
    $token
)

Get-PackageProvider -Name NuGet -ForceBootstrap

#Remove the default Pester install
$modulePath = "C:\Program Files\WindowsPowerShell\Modules\Pester"
if (-not (Test-Path $modulePath)) {
    "There is no Pester folder in $modulePath, doing nothing."
}
else {
    takeown /F $modulePath /A /R
    icacls $modulePath /reset
    icacls $modulePath /grant Administrators:'F' /inheritance:d /T
    Remove-Item -Path $modulePath -Recurse -Force -Confirm:$false
}
#Create a temp folder
New-Item -Path C:\Temp -ItemType Directory
Set-Location C:\Temp

#Install the needed modules
Install-Module Pester -Force
Install-Module -Name Az -RequiredVersion 3.1.0 -Force

$url = "https://github.com/PowerShell/PowerShell/releases/download/v7.1.0/PowerShell-7.1.0-win-x64.msi"
$out = "C:\Temp\PSCore.msi"
#Download and install powershell core v 7.1.0 
Invoke-WebRequest -Uri $url -OutFile $out
& .\PSCore.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 REGISTER_MANIFEST=1 ADD_PATH=1

#Intall the Azure Devops Agent
$ErrorActionPreference = "Stop"
If(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator")){ throw "Run command in an administrator PowerShell prompt"}
If($PSVersionTable.PSVersion -lt (New-Object System.Version("3.0"))){ throw "The minimum version of Windows PowerShell that is required by the script (3.0) does not match the currently running version of Windows PowerShell." }
If(-NOT (Test-Path $env:SystemDrive\'azagent')){mkdir $env:SystemDrive\'azagent'}
Set-Location $env:SystemDrive\'azagent'
for($i = 1
    $i -lt 100
    $i++){
    $destFolder = "A" + $i.ToString()
    if(-NOT (Test-Path ($destFolder))){
        mkdir $destFolder
        Set-Location $destFolder
        break
    }
}
$securityProtocol = @()
$securityProtocol += [Net.ServicePointManager]::SecurityProtocol
$securityProtocol += [Net.SecurityProtocolType]::Tls12
[Net.ServicePointManager]::SecurityProtocol = $securityProtocol
$url = "https://vstsagentpackage.azureedge.net/agent/2.179.0/vsts-agent-win-x64-2.179.0.zip"
$Output = "$ENV:TEMP\vsts-agent-win-x64-2.179.0.zip"
Start-BitsTransfer -Source $url -Destination $Output -TransferType Download
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory( $Output, "$PWD")

#Commented --pool to use the default pool since it causes authorization issues with custom created pools
.\config.cmd --replace --unattended --agent $env:COMPUTERNAME --runasservice --work '_work' --url 'https://dev.azure.com/Dev-WGBV/' --auth PAT --token $token ## --pool "AzureVMs"

#Restart the computer to make sure all installations are finished properly
Restart-Computer -Force
