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
Set-ExecutionPolicy RemoteSigned -force
Import-Module AWSPowerShell
cd c:\temp\
Invoke-WebRequest -Uri "https://aws-codedeploy-us-east-2.s3.amazonaws.com/latest/codedeploy-agent.msi" -OutFile "codedeploy-agent.msi"
c:\temp\codedeploy-agent.msi /quiet /l c:\temp\host-agent-install-log.txt
$cdaservice = Get-Service -Name codedeployagent 2>$null | Format-Wide -Property Status | out-string
$cdaservice = $cdaservice -replace '\s',''
while ($cdaservice -ne 'Running'){
  'Service Not Yet Started'
  $cdaservice = Get-Service -Name codedeployagent 2>$null | Format-Wide -Property Status | out-string
  $cdaservice = $cdaservice -replace '\s',''
  Start-Sleep -s 5
}
echo "Code Deploy Agent Service $cdaservice"
