<powershell>
# Set administrator password
net user Administrator SuperS3cr3t!!!!
wmic useraccount where "name='Administrator'" set PasswordExpires=FALSE

# First, make sure WinRM can't be connected to
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=block

# Delete any existing WinRM listeners
winrm delete winrm/config/listener?Address=*+Transport=HTTP  2>$Null
winrm delete winrm/config/listener?Address=*+Transport=HTTPS 2>$Null

# Disable group policies which block basic authentication and unencrypted login

Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client -Name AllowBasic -Value 1
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client -Name AllowUnencryptedTraffic -Value 1
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service -Name AllowBasic -Value 1
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service -Name AllowUnencryptedTraffic -Value 1


# Create a new WinRM listener and configure

# Certificate creation for Secure WinRM
$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "packer"
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

# WinRM
write-output "Setting up WinRM"
write-host "(host) setting up WinRM"

cmd.exe /c winrm quickconfig -q
cmd.exe /c winrm set "winrm/config" '@{MaxTimeoutms="1800000"}'
cmd.exe /c winrm set "winrm/config/winrs" '@{MaxMemoryPerShellMB="1024"}'
cmd.exe /c winrm set "winrm/config/service" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/client" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/client/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{CredSSP="true"}'
cmd.exe /c winrm set "winrm/config/listener?Address=*+Transport=HTTPS" "@{Port=`"5986`";Hostname=`"packer`";CertificateThumbprint=`"$($Cert.Thumbprint)`"}"


# Configure UAC to allow privilege elevation in remote shells
$Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$Setting = 'LocalAccountTokenFilterPolicy'
Set-ItemProperty -Path $Key -Name $Setting -Value 1 -Force

# Configure and restart the WinRM Service; Enable the required firewall exception
cmd.exe /c netsh advfirewall firewall set rule group="remote administration" new enable=yes
netsh advfirewall firewall set rule name="Windows Remote Management (HTTPS-In)" new enable=yes
netsh firewall add portopening TCP 5986 "Port 5986"
netsh advfirewall set allprofiles state off
cmd.exe /c net stop winrm
cmd.exe /c sc config winrm start= auto
cmd.exe /c net start winrm
 
</powershell>