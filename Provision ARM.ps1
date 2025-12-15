

$ComputerName = Read-Host "Enter Computer Name:"

Write-Host "Is " $ComputerName " correct? Y or N"
$correct = Read-Host
If ($correct = "Y")
{


$addComputerParam = @{
    DomainName = 'hctra.pri'
    Restart = $true
	NewName = $ComputerName
	Options = 'JoinWithNewName'
#   Force = $true
#	Whatif = $true		
}

Rename-Computer -NewName $ComputerName -DomainCredential "hctra.pri\smithl75717" -Force

Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\OOBE" -Name "LaunchUserOOBE"

Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True

New-LocalUser -Name 'Setup'

Add-LocalGroupMember -Group "Administrators" -Member "Setup"

Add-Computer @addComputerParam
Pause 
}

cls
Write-Host "Re-Run Script to re-enter Computer Name"
exit

Pause





