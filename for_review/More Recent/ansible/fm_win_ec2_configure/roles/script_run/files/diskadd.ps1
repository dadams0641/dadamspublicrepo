$diskNumber = (Get-Disk | Where-Object -FilterScript { $_.OperationalStatus -Eq "Offline" -or $_.PartitionStyle -Eq "Raw" }).Number

foreach ($disknum in $diskNumber) {
    Initialize-Disk -Number $disknum -PartitionStyle "GPT"
    $part = New-Partition -DiskNumber $disknum -UseMaximumSize -AssignDriveLetter
    Format-Volume -DriveLetter $part.DriveLetter -Confirm:$FALSE
}