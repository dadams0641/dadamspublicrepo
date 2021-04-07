param([switch]$Elevated)
function Check-Admin {
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Check-Admin) -eq $false)  {
if ($elevated)
{
}
 else {
 Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}
exit
}

Import-Module Dism
Import-Module ServerManager

Add-WindowsFeature NET-Framework-45-ASPNET
Add-WindowsFeature NET-HTTP-Activation

Install-WindowsFeature -name Web-Server -IncludeManagementTools
Install-WindowsFeature -name NFS-Client


$featureSet = "IIS-DefaultDocument", "IIS-DirectoryBrowsing", "IIS-HttpErrors", "IIS-StaticContent", "IIS-HttpRedirect", "IIS-HttpLogging", "IIS-HttpCompressionStatic", "IIS-RequestFiltering", "IIS-BasicAuthentication", "IIS-ClientCertificateMappingAuthentication", "IIS-DigestAuthentication", "IIS-IISCertificateMappingAuthentication", "IIS-Security", "IIS-URLAuthorization", "IIS-WindowsAuthentication", "IIS-ApplicationInit", "NetFx3ServerFeatures", "NetFx4Extended-ASPNET45", "NetFx3", "IIS-ASPNET", "IIS-NetFxExtensibility", "WCF-TCP-Activation45", "WCF-Pipe-Activation45", "WCF-MSMQ-Activation45", "NFS-Administration", "IIS-NetFxExtensibility45", "WCF-HTTP-Activation45", "WCF-NonHTTP-Activation", "MSMQ-HTTP", "IIS-ASPNET45", "IIS-ISAPIExtensions", "IIS-ISAPIFilter"

foreach ($feature in $featureSet) {
  Enable-WindowsOptionalFeature -Online -FeatureName $feature -All
}

cd c:\temp\

Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?LinkId=863265" -OutFile NDP472-KB4054530-x86-x64-AllOS-ENU.exe

echo $null >> c:\temp\iis_complete.txt
