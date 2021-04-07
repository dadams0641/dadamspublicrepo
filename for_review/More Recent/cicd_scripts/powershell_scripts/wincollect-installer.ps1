#$IP = (Get-NetIPAddress |? { $_.IPAddress -like "192.*" -or $_.IPAddress -like "10.*"}| Select -First 1).IPAddress
$IP = "{{item}}"
$InstallCheck = "C:\Program Files\IBM\WinCollect\bin\WinCollect.exe"
$FileLocation = "c:\temp\wincollect-7.3.0-41.x64.exe"

$Flags2 = '/s /v"/qn INSTALLDIR=\"C:\Program Files\IBM\WinCollect\" LOG_SOURCE_AUTO_CREATION_ENABLED=True LOG_SOURCE_AUTO_CREATION_PARAMETERS=""Component1.AgentDevice=DeviceWindowsLog&Component1.Action=create&Component1.LogSourceName='+$env:computername+'+@+'+$IP+'&Component1.LogSourceIdentifier='+$IP+'&Component1.Dest.Name=10.199.7.34&Component1.Dest.Hostname=10.199.7.34&Component1.Dest.Port=514&Component1.Dest.Protocol=TCP&Component1.Log.Security=true&Component1.Log.System=true&Component1.Log.Application=true&Component1.Log.DNS+Server=false&Component1.Log.File+Replication+Service=false&Component1.Log.Directory+Service=true&Component1.RemoteMachinePollInterval=3000&Component1.EventRateTuningProfile=High+Event+Rate+Server&Component1.MinLogsToProcessPerPass=1250&Component1.MaxLogsToProcessPerPass=1875"""'
$Prms = $Flags2.Split(" ")

$Install = $false

while ($Install -eq $true){
    
}

while ($Install -eq $False){
    if (!(Test-Path $InstallCheck -PathType Leaf)) {
        $ProgressPreference = "SilentlyContinue"
        & "$FileLocation" $Prms #$Arg1 $Arg2 $Arg3 $Arg4 $Arg5
        $install = $true
    } else {
        #Below command is commented, if you uncomment it, it will uninstall WinCollect first, before installing it with these settings.
        #(Get-WmiObject -Class Win32_Product -Filter "Name='WinCollect'" -ComputerName . ).Uninstall()
        }
        #start-sleep 45
Exit
        
}
