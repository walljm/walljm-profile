# PREREQUISITES
#
# 1) Copy your ~./ssh folder over to your new profile


# GIT setup
winget install --silent --id Git.Git
git config --global core.autocrlf true
git config --global user.name "jason.wall"
git config --global user.email "jason.wall@vaeit.com"
git config --global pull.rebase merges
git config --global rebase.autoStash true
git config --global core.excludesfile ~/.gitignore

Copy-Item -Path .\ssh\config -Destination "C:\Users\jason.wall\.ssh\"

# setup Project folders
mkdir c:\Projects
mkdir c:\Projects\walljm
cd c:\Projects\walljm

# get your windows profile
git clone git@gitlab.com:walljm/windows-profile.git
cd c:\Projects\walljm\windows-profile

# setup the local dev certificate
choco install mkcert
mkcert -install
cd docker-files
cd certs
mkcert itpie.dev itpie.test itpie.demo portainer.dev faker.dev pgadmin.dev docker.dev *.dev 127.0.0.1 localhost ::1
rm .\localhost-key.pem
rm .\localhost.pem
mv .\itpie.dev+10-key.pem .\localhost-key.pem
mv .\itpie.dev+10.pem .\localhost.pem

cd c:\Projects\
mkdir vae
cd vae
git clone git@gitlab.com:vaeit/itpie/operations.git
git clone git@gitlab.com:vaeit/itpie/engineering.git
git clone git@gitlab.com:vaeit/network-faker.git
git clone git@gitlab.com:vaeit/itpie/zoneviz.git

cd C:\Projects\walljm
git clone git@gitlab.com:walljm/dynamicbible.git

# install some powershell modules...
Install-Module -Name ComputerManagementDsc
Install-Module -Name NetworkingDsc -RequiredVersion 7.4.0.0
Import-Module 'C:\Program Files\Microsoft Virtual Machine Converter\MvmcCmdlet.psd1'


#setup your powershell profile
winget install --silent --accept-package-agreements --accept-source-agreements --id 9N0DX20HK701 # windows terminal (msstore)
winget install --silent --accept-package-agreements --accept-source-agreements --id 9MZ1SNWT0N5D # powershell (msstore)

New-Item -Path $profile -ItemType "file" -Force
Add-Content -Path $profile -Value ". c:\Projects\walljm\windows-profile\profile.ps1"
Copy-Item -Path .\windows_terminal_settings\settings.json -Destination "C:\Users\jason.wall\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"

# setup vm features
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

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