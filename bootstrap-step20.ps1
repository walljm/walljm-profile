
mkdir c:\Projects
mkdir c:\Projects\walljm
cd c:\Projects\walljm
git clone git@gitlab.com:walljm/windows-profile.git
cd c:\Projects\walljm\windows-profile

choco install mkcert
mkcert -install

cd docker-files
cd certs
mkcert itpie.dev itpie.test itpie.demo portainer.dev faker.dev pgadmin.dev docker.dev *.dev 127.0.0.1 localhost ::1
rm .\localhost-key.pem
rm .\localhost.pem
mv .\itpie.dev+10-key.pem .\localhost-key.pem
mv .\itpie.dev+10.pem .\localhost.pem


Install-Module -Name ComputerManagementDsc
Install-Module -Name NetworkingDsc -RequiredVersion 7.4.0.0

dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
Import-Module 'C:\Program Files\Microsoft Virtual Machine Converter\MvmcCmdlet.psd1'

New-Item -Path $profile -ItemType "file" -Force
Add-Content -Path $profile -Value ". c:\Projects\walljm\windows-profile\profile.ps1"

Copy-Item -Path .\windows_terminal_settings\settings.json -Destination "C:\Users\jason.wall\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}

# this will require a restart...
wsl --install -d Ubuntu-20.04