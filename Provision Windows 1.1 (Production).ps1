$ComputerName = Read-Host "Enter Computer Name and press Enter:"
$OOBEKey = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\OOBE").PSObject.Properties.Name -contains "LaunchUserOOBE"
$DefaultKey = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\OOBE").PSObject.Properties.Name -contains "DefaultAccountAction"
$PrivacyKey = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\OOBE").PSObject.Properties.Name -contains "PrivacyConsentStatus"
$SkipMachineKey = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\OOBE").PSObject.Properties.Name -contains "SkipMachineOOBE"
$RecoveryOOBEKey = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\OOBE").PSObject.Properties.Name -contains "RecoveryOOBEEnabled"
$BypassNROKey = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\OOBE").PSObject.Properties.Name -contains "BypassNRO"
#$FirstBootKey = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\OOBE\FirstBoot").PSObject.Properties.Name -contains "FirstLogonUI" -ErrorAction SilentlyContinue
$WinLogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

$addComputerParam = @{
    DomainName = 'hctra.pri'
    Restart = $true
	NewName = $ComputerName
	Options = 'JoinWithNewName', 'AccountCreate'
#   Force = $true
#	Whatif = $true		
}

Write-Host "Is " $ComputerName " correct? Y or N"
$correct = Read-Host

If ($correct -eq "N")
{
	Clear-Host
	Write-Host "Re-run Script to re-enter Computer Name"
	Start-Sleep -Seconds 5
	exit
}

$UserExists = Get-LocalUser | Where-Object {$_.Name -eq "Setup"}
If ( -not $UserExists)
 {
	Clear-Host 
	Write-Host "Enter Password for Setup User:" 
	New-LocalUser -Name 'Setup'
	Add-LocalGroupMember -Group "Administrators" -Member "Setup"
 } 

If ($OOBEKey -eq $true) {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "LaunchUserOOBE" -Value "0"
} else {
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "LaunchUserOOBE" -Value "0" -PropertyType DWord	
}

If ($DefaultKey -eq $true) {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "DefaultAccountAction" -Value "0"
} else {
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "DefaultAccountAction" -Value "0" -PropertyType DWord	
}

If ($PrivacyKey -eq $true) {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "PrivacyConsentStatus" -Value "0"
} else {
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "PrivacyConsentStatus" -Value "0" -PropertyType DWord
}

If ($SkipMachineKey -eq $true) {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "SkipMachineOOBE" -Value "1"
} else {
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "SkipMachineOOBE" -Value "1" -PropertyType DWord
}

If ($RecoveryOOBEKey -eq $true) {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "RecoveryOOBEEnabled" -Value "0"
} else {
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "RecoveryOOBEEnabled" -Value "0" -PropertyType DWord
}

If ($BypassNROKey -eq $true) {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "BypassNRO" -Value "0"
} else {
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "BypassNRO" -Value "0" -PropertyType DWord
}

If ($FirstBootKey -eq $true) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\FirstBoot" -ItemType "Directory" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\FirstBoot" -Name "FirstLogonUI" -Value "0"
} else {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\FirstBoot" -ItemType "Directory" -ErrorAction SilentlyContinue
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\FirstBoot" -Name "FirstLogonUI" -Value "0" -PropertyType DWord
}

Set-ItemProperty -Path $WinLogonPath -Name "SystemAutoLogon" -Value "0"
Set-ItemProperty -Path $WinLogonPath -Name "AutoAdminLogon" -Value "0"
Set-ItemProperty -Path $WinLogonPath -Name "AutoLogonSID" -Value ""
Set-ItemProperty -Path $WinLogonPath -Name "DefaultUserName" -Value "Administrator"
Set-ItemProperty -Path $WinLogonPath -Name "EnableFirstLogonAnimation" -Value "0"
Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True
Start-Sleep -Seconds 5

Clear-Host

Write-Host "Enter your credentials to Join Domain:"

If ((Get-CimInstance Win32_ComputerSystem).Domain -eq "hctra.pri") {
	
	Write-Host "Domain is HCTRA, which means the Computer rename likely failed. Please join any workgroup to leave the domain and then re-join the Domain with the correct Computer Name."
	Start-Sleep -Seconds 10
	Clear-Host
	Shutdown -r /t 0

} else {

    Add-Computer @addComputerParam

}






