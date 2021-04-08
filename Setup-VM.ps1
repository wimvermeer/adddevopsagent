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
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
Install-Module -Name Pester -Force -SkipPublisherCheck
if($null -eq (Get-PSDrive -Name Z -ErrorAction SilentlyContinue)){
    cmd.exe /C "cmdkey /add:`"wdevtmdfgher.file.core.windows.net`" /user:`"Azure\wdevtmdfgher`" /pass:`"$pass`""
    # Mount the drive
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\wdevtmdfgher.file.core.windows.net\vmtransfer" -Persist
    Set-ExecutionPolicy Unrestricted -Force 
}
Set-Location C:\
Remove-Item C:\ZDrive -Force -Recurse -ErrorAction SilentlyContinue
Copy-Item -Path Z:\ -Destination C:\ZDrive -Recurse -Force
Set-Location  C:\ZDrive
