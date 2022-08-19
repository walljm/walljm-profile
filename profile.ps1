
$projects = "c:\projects"

function prompt {
    $origLastExitCode = $LASTEXITCODE

    $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path

    Write-Host $curPath -ForegroundColor Yellow -NoNewline
    $LASTEXITCODE = $origLastExitCode
    "$('>' * ($nestedPromptLevel + 1)) "
}

function cmds {
    echo " show commands"
    echo " ---------------------------------------------------------------"
    showhelp
    echo ""
    echo " git aliases"
    echo " ---------------------------------------------------------------"
    echo "   gt update branch =>"
    echo "      git checkout other --force"
    echo "      git clean -f -d -x"
    echo "      git reset --hard"
    echo "   gt heads => "
    echo "      git branch"
    echo "   gt clean =>"
    echo "      git clean -f -d -x"
    echo "      git reset --hard"
    echo "   gt rebase t1 t2 =>"
    echo "      git checkout t1"
    echo "      git rebase t2"
    echo ""
    echo " aliases"
    echo " ---------------------------------------------------------------"
    echo "    nst == netstat -n -b"
    echo "    cdp == cd $projects"
    echo "   cdpw == cd $projects\walljm"
    echo "     dc == docker-compose args"
    echo "     vs == devenv.exe args"
    echo ""
}

function nst {
    echo "netstat -n $($args -join ' ')"
    netstat -n $args
}

function cdp {
    param (
        [Parameter(Mandatory = $false)]
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
            
                $dir = "$projects\$wordToComplete"			
                if ($wordToComplete -eq "") {
                    $dir = "$projects\a"
                }
                if ($wordToComplete.EndsWith("\")) {
                    $dir = $dir + "a"
                }
                $examine = split-path -path $dir
                $pre = $examine.Substring($projects.length)
                if ($pre.length -gt 0) {
                    $pre = "$pre\"
                }
                if ($pre.StartsWith("\")) {
                    $pre = $pre.Substring(1)
                }
                $test = $wordToComplete.split('\') | Select-Object -last 1
                Get-ChildItem $examine | Where-Object { $_.PSIsContainer } | Select-Object Name | Where-Object { $_ -like "*$test*" } | ForEach-Object { "$($pre)$($_.Name)\" }

            } )]
        $args
    )
    if ($args) {
        echo "cd  $projects\$args"
        cd $projects\$args
    }
    else {
        echo "cd  $projects"
        cd  $projects
    }
}

function cdpw {
    param (
        [Parameter(Mandatory = $false)]
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
            
                $dir = "$projects\walljm\$wordToComplete"			
                if ($wordToComplete -eq "") {
                    $dir = "$projects\a"
                }
                if ($wordToComplete.EndsWith("\")) {
                    $dir = $dir + "a"
                }
                $examine = split-path -path $dir
                $pre = $examine.Substring($projects.length)
                if ($pre.length -gt 0) {
                    $pre = "$pre\"
                }
                if ($pre.StartsWith("\")) {
                    $pre = $pre.Substring(1)
                }
                $test = $wordToComplete.split('\') | Select-Object -last 1
                Get-ChildItem $examine | Where-Object { $_.PSIsContainer } | Select-Object Name | Where-Object { $_ -like "*$test*" } | ForEach-Object { "$($pre)$($_.Name)\" }

            } )]
        $args
    )
    if ($args) {
        echo "cd  $projects\$args"
        cd $projects\$args
    }
    else {
        echo "cd  $projects"
        cd  $projects\walljm
    }
}

function dc {
    echo "docker compose $($args -join ' ')"
    docker compose $args
}

function gt {
    $cmd, $other, $other2 = $args
    
    if ($cmd -eq "fetch") {
        invoke "git fetch --all --prune --prune-tags"
        invoke "git branch -v"
        invoke "git status"
    }
    elseif ($cmd -eq "update") {
        invoke "git checkout $other --force"
        invoke "git clean -f -d -x"
        invoke "git reset --hard"
    }
    elseif ($cmd -eq "heads") {
        invoke "git branch"
    }
    elseif ($cmd -eq "clean") {
        invoke "git clean -f -d -x"
        invoke "git reset --hard"
    }
    elseif ($cmd -eq "rebase") {
        $t1, $t2 = $other
        invoke "git checkout $t1"
        invoke "git rebase $t2"
    }
    elseif (($cmd -eq "contracts") -and ($other -eq "pull")) {
        invoke "git subtree pull --prefix src/ITPIE.Contracts --squash contracts $other2"
    }
    elseif (($cmd -eq "contracts") -and ($other -eq "push")) {
        invoke "git subtree push --prefix src/ITPIE.Contracts --squash contracts $other2"
    }
    else {
        invoke "git $cmd $other"
    }
}

function show {
    $cmd, $other = $args

    if ($cmd -like "ifc*" -or $cmd -like "int*") {
        if ($other -like "lst") {
            Get-NetAdapter -IncludeHidden | `
                Sort-Object Hidden, InterfaceIndex | `
                Format-List -Property  InterfaceIndex, Name, InterfaceDescription, InterfaceName, MacAddress, `
                AdminStatus, ifOperStatus, LinkSpeed, ReceiveLinkSpeed, TransmitLinkSpeed, FullDuplex, MediaType, Virtual
        }
        elseif ($other -like "hid*") {
            Get-NetAdapter -IncludeHidden | `
                Sort-Object Hidden, InterfaceIndex | `
                Format-Table -Property InterfaceIndex, InterfaceName, Name, InterfaceDescription, MacAddress, `
                PermanentAddress, AdminStatus, ifOperStatus, LinkSpeed, FullDuplex, MediaType, Virtual, `
                DeviceWakeUpEnable, Hidden, VlanID
        }
        elseif ($other -like "d*") {
            Get-NetIPConfiguration -Detailed -All -AllCompartments `
            | ForEach-Object {
                $dns = Get-DnsClientServerAddress -AddressFamily IPv4 -InterfaceAlias $_.InterfaceAlias -CimSession $_.ComputerName -erroraction 'silentlycontinue'
                $dnsv6 = Get-DnsClientServerAddress -AddressFamily IPv6 -InterfaceAlias $_.InterfaceAlias -CimSession $_.ComputerName -erroraction 'silentlycontinue'
                $ip = Get-NetIPAddress -InterfaceAlias $_.InterfaceAlias -AddressFamily IPv4 -PolicyStore ActiveStore -CimSession $_.ComputerName -erroraction 'silentlycontinue'
                $ifc = Get-NetIPInterface -InterfaceAlias $_.InterfaceAlias -AddressFamily IPv4 -PolicyStore ActiveStore -CimSession $_.ComputerName -erroraction 'silentlycontinue'
                $gateway = Get-NetRoute -erroraction 'silentlycontinue' -DestinationPrefix '0.0.0.0/0' -InterfaceIndex $_.InterfaceIndex -PolicyStore ActiveStore -CimSession $_.ComputerName | Select-Object NextHop
                $adapter = Get-NetAdapter -Name $_.InterfaceAlias -CimSession $_.ComputerName -erroraction 'silentlycontinue'
                $ipprofile = Get-NetConnectionProfile -InterfaceAlias  $_.InterfaceAlias -CimSession $_.ComputerName -erroraction 'silentlycontinue'

                $obj = [PSCustomObject]@{
                    InterfaceAlias       = $_.InterfaceAlias
                    InterfaceDescription = $_.InterfaceDescription
                    InterfaceIndex       = $_.InterfaceIndex
                    DHCP                 = $ifc.DHCP
                    Virtual              = $adapter.Virtual
                }

                if ($null -ne $adapter.LinkLayerAddress) {
                    $obj | Add-Member -NotePropertyName MAC -NotePropertyValue $adapter.LinkLayerAddress
                }
                if ($null -ne $adapter.AdminStatus) {
                    $obj | Add-Member -NotePropertyName AdminStatus -NotePropertyValue $adapter.AdminStatus
                }
                if ($null -ne $adapter.ifOperStatus) {
                    $obj | Add-Member -NotePropertyName OperStatus -NotePropertyValue $adapter.ifOperStatus
                }
                if ($null -ne $adapter.LinkSpeed) {
                    $obj | Add-Member -NotePropertyName Speed -NotePropertyValue $adapter.LinkSpeed
                }
                if ($null -ne $adapter.FullDuplex) {
                    $obj | Add-Member -NotePropertyName FullDuplex -NotePropertyValue $adapter.FullDuplex
                }
                if ($null -ne $adapter.MediaType) {
                    $obj | Add-Member -NotePropertyName MediaType -NotePropertyValue $adapter.MediaType
                }
                if ($null -ne $adapter.VlanID) {
                    $obj | Add-Member -NotePropertyName VlanID -NotePropertyValue $adapter.VlanID
                }
                if ($null -ne $ipprofile.IPv4Connectivity) {
                    $obj | Add-Member -NotePropertyName IPv4Connectivity -NotePropertyValue $ipprofile.IPv4Connectivity
                }
                if ($null -ne $ipprofile.NetworkCategory) {
                    $obj | Add-Member -NotePropertyName NetworkCategory -NotePropertyValue $ipprofile.NetworkCategory
                }
                if ($null -ne $ip.IPAddress) {
                    $obj | Add-Member -NotePropertyName IPv4 -NotePropertyValue "$($ip.IPAddress)/$($ip.PrefixLength)"
                    $obj | Add-Member -NotePropertyName IPv4Type -NotePropertyValue "$($ip.Type)"
                    $obj | Add-Member -NotePropertyName IPv4Origin -NotePropertyValue "$($ip.SuffixOrigin)"
                }
                if (($gateway | Join-String -Property NextHop -Separator "`n") -ne '') {
                    $obj | Add-Member -NotePropertyName IPv4Gateway -NotePropertyValue ($gateway | Join-String -Property NextHop -Separator "`n")
                }
                if (($dns.ServerAddresses -join "`n") -ne '') {
                    $obj | Add-Member -NotePropertyName IPv4DNS -NotePropertyValue ($dns.ServerAddresses -join "`n")   
                }
                if (($dnsv6.ServerAddresses -join "`n") -ne '') {
                    $obj | Add-Member -NotePropertyName IPv6DNS -NotePropertyValue ($dnsv6.ServerAddresses -join "`n")   
                }
                return $obj;
            } `
            | Where-Object -Property Virtual -ne False `
            | Where-Object -Property Virtual -ne $null `
            | Format-List -Property *
        }
        else {
            Get-NetAdapter | `
                Sort-Object Hidden, InterfaceIndex | `
                Format-Table -Property InterfaceIndex, InterfaceName, Name, InterfaceDescription, MacAddress, `
                AdminStatus, ifOperStatus, LinkSpeed, FullDuplex, MediaType, Virtual, `
                DeviceWakeUpEnable
        }
        return
    }
    elseif ($cmd -like "route*") {
        if ($other -like "det*") {
            $ifcs = Get-NetAdapter | `
                Select-Object -Property InterfaceIndex, MacAddress, AdminStatus, ifOperStatus
            $routes = Get-NetRoute -IncludeAllCompartments | `
                Select-Object -Property InterfaceIndex, DestinationPrefix, NextHop, InterfaceMetric, RouteMetric, Protocol, State, Publish, `
                TypeOfRoute, IsStatic, InterfaceAlias, PreferredLifetime, AdminDistance

            Join-Object `
                -Left $routes `
                -Right $ifcs `
                -LeftJoinProperty InterfaceIndex `
                -RightJoinProperty InterfaceIndex `
                -Type AllInLeft `
                -RightProperties MacAddress, AdminStatus, ifOperStatus | `
                Format-Table -Property DestinationPrefix, NextHop, InterfaceMetric, RouteMetric, Protocol, State, Publish, TypeOfRoute, IsStatic, `
                InterfaceAlias, InterfaceIndex, AdminStatus, ifOperStatus, MacAddress, PreferredLifetime, AdminDistance
        }
        else {
            Get-NetRoute -IncludeAllCompartments -AddressFamily IPv4 | `
                Where-Object { $_.InterfaceAlias -Match "(?i).*$other.*" -or $_.DestinationPrefix -Match "(?i).*$other.*" -or $_.NextHop -Match "(?i).*$other.*" } | `
                Where-Object { $_.DestinationPrefix -NE "255.255.255.255/32" -and $_.DestinationPrefix -NE "224.0.0.0/4" } | `
                Format-Table -Property DestinationPrefix, NextHop, InterfaceMetric, RouteMetric, Protocol, State, Publish, TypeOfRoute, `
                InterfaceIndex, InterfaceAlias, PreferredLifetime
        }
        return
    }
    elseif ($cmd -like "ip*") {
        if ($other -like "det*") {
            Get-NetIPAddress -IncludeAllCompartments | `
                Sort-Object IPAddress | `
                Format-Table -Property IPAddress, PrefixLength, AddressFamily, InterfaceIndex, InterfaceAlias, PrefixOrigin, Type, ValidLifetime;
        }
        else {
            
            Get-NetIPAddress -IncludeAllCompartments | `
                Where-Object PrefixOrigin -ne "WellKnown" | `
                Sort-Object IPAddress | `
                Format-Table -Property IPAddress, PrefixLength, AddressFamily, InterfaceIndex, InterfaceAlias, PrefixOrigin, Type, ValidLifetime;
        }
        return
    }
    elseif ($cmd -like "arp*") {
        Get-NetNeighbor -AddressFamily IPv4 -IncludeAllCompartments | `
            Where-Object State -ne "Permanent" | `
            Sort-Object IPAddress | `
            Format-Table -Property IPAddress, LinkLayerAddress, InterfaceIndex, InterfaceAlias, State;
        return
    }
    elseif ($cmd -like "wsl*") {
        wsl --list --verbose --all;
        return
    }
    elseif ($cmd -like "help") {
        showhelp
        return
    }

    # help
    Write-Output " help: show";
    Write-Output ""
    showhelp
}

function showhelp {
    Write-Output "    show ifc             | shows all the interfaces and their status"
    Write-Output "    show ifc lst         | shows all the interfaces and their status as a list"
    Write-Output "    show ifc detail      | shows connected interfaces in detail as a list"
    Write-Output "    show ifc             | shows all the interfaces and their status"
    Write-Output "    show route           | shows the route table"
    Write-Output "    show route details   | shows the route table"
    Write-Output "    show ip              | shows the ips configured on the computer excluding WellKnown"
    Write-Output "    show ip detail       | shows the ips configured on the computer"
    Write-Output "    show arp             | shows the arp table"
    Write-Output "    show wsl             | lists the wsl distros installed"
}

function vs {
    $project = (Get-ChildItem -Path $args -Name -Include *.sln);
    
    if ($project -eq "" -or $null -eq $project) {
        $project = (Get-ChildItem -Path $args -Name -Include *.csproj);
    }
    
    if ($project -eq "" -or $null -eq $project) {
        $project = ".";
    }

    & "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe" $project
}

function invoke
{
    param(
        [String]
        [Parameter(Mandatory = $true, Position = 0)]
        $cmd)
    Write-Host $cmd
    Invoke-Expression $cmd
}

####
# Helper Functions
####

function aliases {
    cmds
    vcmds
}

set-alias -Name ll -Value dir

cmds

#source the work specific profiles
. C:\Projects\walljm\windows-profile\vae.ps1

# https://github.com/ili101/Join-Object
# . C:\Projects\walljm\windows-profile\join.ps1

echo ""