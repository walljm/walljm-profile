$url = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
$outpath = "$PSScriptRoot/wsl_update_x64.msi"
Invoke-WebRequest -Uri $url -OutFile $outpath
Start-Process -Filepath $outpath

choco install klogg -y

winget install --silent --accept-package-agreements --accept-source-agreements --id Docker.DockerDesktop

winget install --silent --accept-package-agreements --accept-source-agreements --id 7zip.7zip
winget install --silent --accept-package-agreements --accept-source-agreements --id Insecure.Nmap
winget install --silent --accept-package-agreements --accept-source-agreements --id Microsoft.PowerToys
winget install --silent --accept-package-agreements --accept-source-agreements --id gnuplot.gnuplot
winget install --silent --accept-package-agreements --accept-source-agreements --id Notepad++.Notepad++
winget install --silent --accept-package-agreements --accept-source-agreements --id dbeaver.dbeaver
winget install --silent --accept-package-agreements --accept-source-agreements --id Keybase.Keybase
winget install --silent --accept-package-agreements --accept-source-agreements --id KDE.KDiff3
winget install --silent --accept-package-agreements --accept-source-agreements --id Logitech.UnifyingSoftware
winget install --silent --accept-package-agreements --accept-source-agreements --id TortoiseHg.TortoiseHg
winget install --silent --accept-package-agreements --accept-source-agreements --id PuTTY.PuTTY

winget install --silent --accept-package-agreements --accept-source-agreements --id GoLang.Go
winget install --silent --accept-package-agreements --accept-source-agreements --id Python.Python3
winget install --silent --accept-package-agreements --accept-source-agreements --id Microsoft.dotnet
winget install --silent --accept-package-agreements --accept-source-agreements --id OpenJS.NodeJS -v 16.9.0

winget install --accept-package-agreements --accept-source-agreements --id Microsoft.VisualStudioCode
# restart