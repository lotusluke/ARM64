$ComputerName = Read-Host "Enter Computer Name and press Enter: (If repairing press Enter without a name to add Reg Keys\Firewall Rules)"
$WinLogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$OOBEPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE"
$EnableFirstKey = (Get-ItemProperty $WinLogonPath).PSObject.Properties.Name -contains "EnableFirstLogonAnimation"
$DefaultUserNameKey = (Get-ItemProperty $WinLogonPath).PSObject.Properties.Name -contains "DefaultUserName"
$OOBEKey = (Get-ItemProperty $OOBEPath).PSObject.Properties.Name -contains "LaunchUserOOBE"
$DefaultKey = (Get-ItemProperty $OOBEPath).PSObject.Properties.Name -contains "DefaultAccountAction"
$HideEULAKey = (Get-ItemProperty $OOBEPath).PSObject.Properties.Name -contains "HideEULAPage"
$PrivacyConsentKey = (Get-ItemProperty $OOBEPath).PSObject.Properties.Name -contains "PrivacyConsentStatus"
$DisablePrivacyKey = (Get-ItemProperty $OOBEPath).PSObject.Properties.Name -contains "DisablePrivacyExperience"
$SkipMachineKey = (Get-ItemProperty $OOBEPath).PSObject.Properties.Name -contains "SkipMachineOOBE"
$SkipUserKey = (Get-ItemProperty $OOBEPath).PSObject.Properties.Name -contains "SkipUserOOBE"
$RecoveryOOBEKey = (Get-ItemProperty $OOBEPath).PSObject.Properties.Name -contains "RecoveryOOBEEnabled"
$BypassNROKey = (Get-ItemProperty $OOBEPath).PSObject.Properties.Name -contains "BypassNRO"
$FirstBootKey = Test-Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\FirstBoot

# Setting parameters for Domain Join
$addComputerParam = @{
    DomainName = ''
    Restart = $true
	NewName = $ComputerName
	Options = 'JoinWithNewName', 'AccountCreate'
#   Force = $true
#	Whatif = $true		
}
Clear-Host

#Have the user validate their input and continue or end to re-enter the computer name
If ($ComputerName -ne "") {
    Write-Host "Is " $ComputerName " correct? Y or N"
    $correct = Read-Host
    Clear-Host
} else {
    Write-Host "Adding Reg Keys and Firewall Rules..."    
}

If ($correct -eq "N") {
	Clear-Host
	Write-Host "Re-run Script to re-enter Computer Name"
	Start-Sleep -Seconds 5
	Clear-Host
    exit
}

#Check if local user exists and if not create and add to Local Administrators
$UserExists = Get-LocalUser | Where-Object {$_.Name -eq "Setup"}
If ( -not $UserExists -and $ComputerName -ne "") {
	Clear-Host 
	Write-Host "Enter Password for Setup User:" 
	New-LocalUser -Name 'Setup'
	Add-LocalGroupMember -Group "Administrators" -Member "Setup"
    Clear-Host
} 

#Adding Reg keys, I know this is gross, it will be better in 1.3
If ($OOBEKey -eq $true) {
    Set-ItemProperty -Path $OOBEPath -Name "LaunchUserOOBE" -Value "0"
} else {
	New-ItemProperty -Path $OOBEPath -Name "LaunchUserOOBE" -Value "0" -PropertyType DWord	
}

If ($DefaultKey -eq $true) {
    Set-ItemProperty -Path $OOBEPath -Name "DefaultAccountAction" -Value "0"
} else {
	New-ItemProperty -Path $OOBEPath -Name "DefaultAccountAction" -Value "0" -PropertyType DWord	
}

If ($PrivacyConsentKey -eq $true) {
    Set-ItemProperty -Path $OOBEPath -Name "PrivacyConsentStatus" -Value "1"
} else {
	New-ItemProperty -Path $OOBEPath -Name "PrivacyConsentStatus" -Value "1" -PropertyType DWord
}

If ($DisablePrivacyKey -eq $true) {
    Set-ItemProperty -Path $OOBEPath -Name "DisablePrivacyExperience" -Value "1"
} else {
	New-ItemProperty -Path $OOBEPath -Name "DisablePrivacyExperience" -Value "1" -PropertyType DWord
}

If ($SkipMachineKey -eq $true) {
    Set-ItemProperty -Path $OOBEPath -Name "SkipMachineOOBE" -Value "1"
} else {
	New-ItemProperty -Path $OOBEPath -Name "SkipMachineOOBE" -Value "1" -PropertyType DWord
}

If ($SkipUserKey -eq $true) {
    Set-ItemProperty -Path $OOBEPath -Name "SkipUserOOBE" -Value "1"
} else {
	New-ItemProperty -Path $OOBEPath -Name "SkipUserOOBE" -Value "1" -PropertyType DWord
}

If ($RecoveryOOBEKey -eq $true) {
    Set-ItemProperty -Path $OOBEPath -Name "RecoveryOOBEEnabled" -Value "0"
} else {
	New-ItemProperty -Path $OOBEPath -Name "RecoveryOOBEEnabled" -Value "0" -PropertyType DWord
}

If ($BypassNROKey -eq $true) {
    Set-ItemProperty -Path $OOBEPath -Name "BypassNRO" -Value "1"
} else {
	New-ItemProperty -Path $OOBEPath -Name "BypassNRO" -Value "1" -PropertyType DWord
}

If ($HideEULAKey -eq $true) {
    Set-ItemProperty -Path $OOBEPath -Name "HideEULAPage" -Value "1"
} else {
	New-ItemProperty -Path $OOBEPath -Name "HideEULAPage" -Value "1" -PropertyType DWord
}

If ($EnableFirstKey -eq $true) {
    Set-ItemProperty -Path $WinLogonPath -Name "EnableFirstLogonAnimation" -Value "0"
} else {
	New-ItemProperty -Path $WinLogonPath -Name "EnableFirstLogonAnimation" -Value "0" -PropertyType DWord
}

#Detecting registry directories and creating if missing to add key
If ($FirstBootKey -eq $true) {
		If ((Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\FirstBoot).PSObject.Properties.Name -contains "FirstLogonUI") {
			Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\FirstBoot" -Name "FirstLogonUI" -Value "0"
		} else {
			New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\FirstBoot" -Name "FirstLogonUI" -Value "0" -PropertyType DWord	
}	
} else {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\FirstBoot" -ItemType "Directory" 
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\FirstBoot" -Name "FirstLogonUI" -Value "0" -PropertyType DWord 
}

If ($DefaultUserNameKey -eq $true) {   
    Set-ItemProperty -Path $WinLogonPath -Name "DefaultUserName" -Value ""
} 
Set-ItemProperty -Path $WinLogonPath -Name "SystemAutoLogon" -Value "0"
Set-ItemProperty -Path $WinLogonPath -Name "AutoAdminLogon" -Value "0"
Set-ItemProperty -Path $WinLogonPath -Name "AutoLogonSID" -Value ""

#Set Firewall Rules for SCCM
Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True
Start-Sleep -Seconds 5
Clear-Host
Write-Host "Enter your credentials to Join Domain:"

#Detect if already joined to the domain and if not, Join Domain
If ((Get-CimInstance Win32_ComputerSystem).Domain -eq "") {
	Clear-Host
	Write-Host "Domain is already joined, so Domain Join cancelled. Repair Complete. If it was renamed to LAPTOP-******** please join this machine to any workgroup and then re-join the HCTRA Domain with the correct Computer Name."
	Start-Sleep -Seconds 10
	Clear-Host
#Housekeeping
    Set-ExecutionPolicy -ExecutionPolicy Undefined
#Shutdown -r /t 0 for later in case you need it
	Exit
} else {
    Add-Computer @addComputerParam
}







