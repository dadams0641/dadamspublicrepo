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
cd 'C:\Program Files (x86)\VisualCron\VCCommand\'
.\VCCommand --action activate --r 5b24f0f1-ec75-43fa-922d-07341429b8e5 --connectionmode local --username admin
Unregister-ScheduledJob -Name ActivateVisualCron
