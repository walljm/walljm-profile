choco upgrade chocolatey -y
choco upgrade 7zip -y
choco upgrade wireshark -y
choco upgrade nmap -y
choco upgrade powertoys -y
choco upgrade powershell-core -y
choco upgrade openssh -y
choco upgrade nodejs -y
choco upgrade mkcert -y
choco install gnuplot -y
choco install jq -y
choco install golang -y

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
Import-Module 'C:\Program Files\Microsoft Virtual Machine Converter\MvmcCmdlet.psd1'

Install-Module -Name ComputerManagementDsc
Install-Module -Name NetworkingDsc -RequiredVersion 7.4.0.0
