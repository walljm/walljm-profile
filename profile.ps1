
$projects = "c:\projects"
$dockerfiles = "$projects\walljm\winprofile\docker_files"

function prompt
{
    $origLastExitCode = $LASTEXITCODE

    $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path

    Write-Host $curPath -ForegroundColor Yellow -NoNewline
    $LASTEXITCODE = $origLastExitCode
    "$('>' * ($nestedPromptLevel + 1)) "
}

function cmds
{
    echo " show commands"
    echo " ---------------------------------------------------------------"
    echo "   show route"
    echo "   show route detail"
    echo "   show interfaces"
    echo "   show interfaces hidden"
    echo "   show ip"
    echo "   show linux"
    echo ""
    echo " git aliases"
    echo " ---------------------------------------------------------------"
    echo "   gt update $branch =>"
    echo "      git checkout $other --force"
    echo "      git clean -f -d -x"
    echo "      git reset --hard"
    echo "   gt heads => "
    echo "      git branch"
    echo "   gt clean =>"
    echo "      git clean -f -d -x"
    echo "      git reset --hard"
    echo "   gt rebase $t1 $t2 =>"
    echo "      git checkout $t1"
    echo "      git rebase $t2"
    echo ""
    echo " aliases"
    echo " ---------------------------------------------------------------"
    echo "   grep == sls $args"
    echo "    nst == netstat -n -b"
    echo "    cdp == cd $projects"
    echo "   cdpw == cd $projects\walljm"
    echo "     dc == docker-compose $args"
    echo "     rn == react-native $args"
    echo "     io == ionic $args"
    echo "    ioc == ionic cordova $args"
    echo ""

}

function grep
{ 
    Select-String $args
}

function nst
{
    echo "netstat -n $($args -join ' ')"
    netstat -n $args
}

function cdp
{
    param (
        [Parameter(Mandatory = $false)]
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
            
                $dir = "$projects\$wordToComplete"			
                if ($wordToComplete -eq "")
                {
                    $dir = "$projects\a"
                }
                if ($wordToComplete.EndsWith("\"))
                {
                    $dir = $dir + "a"
                }
                $examine = split-path -path $dir
                $pre = $examine.Substring($projects.length)
                if ($pre.length -gt 0)
                {
                    $pre = "$pre\"
                }
                if ($pre.StartsWith("\"))
                {
                    $pre = $pre.Substring(1)
                }
                $test = $wordToComplete.split('\') | Select-Object -last 1
                Get-ChildItem $examine | Where-Object { $_.PSIsContainer } | Select-Object Name | Where-Object { $_ -like "*$test*" } | ForEach-Object { "$($pre)$($_.Name)\" }

            } )]
        $args
    )
    if ($args)
    {
        echo "cd  $projects\$args"
        cd $projects\$args
    }
    else
    {
        echo "cd  $projects"
        cd  $projects
    }
}
function cdpw
{
    param (
        [Parameter(Mandatory = $false)]
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
            
                $dir = "$projects\walljm\$wordToComplete"			
                if ($wordToComplete -eq "")
                {
                    $dir = "$projects\a"
                }
                if ($wordToComplete.EndsWith("\"))
                {
                    $dir = $dir + "a"
                }
                $examine = split-path -path $dir
                $pre = $examine.Substring($projects.length)
                if ($pre.length -gt 0)
                {
                    $pre = "$pre\"
                }
                if ($pre.StartsWith("\"))
                {
                    $pre = $pre.Substring(1)
                }
                $test = $wordToComplete.split('\') | Select-Object -last 1
                Get-ChildItem $examine | Where-Object { $_.PSIsContainer } | Select-Object Name | Where-Object { $_ -like "*$test*" } | ForEach-Object { "$($pre)$($_.Name)\" }

            } )]
        $args
    )
    if ($args)
    {
        echo "cd  $projects\$args"
        cd $projects\$args
    }
    else
    {
        echo "cd  $projects"
        cd  $projects\walljm
    }
}

function cdpd
{
    param (
        [Parameter(Mandatory = $false)]
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
            
                $dir = "$dockerfiles\$wordToComplete"			
                if ($wordToComplete -eq "")
                {
                    $dir = "$projects\a"
                }
                if ($wordToComplete.EndsWith("\"))
                {
                    $dir = $dir + "a"
                }
                $examine = split-path -path $dir
                $pre = $examine.Substring($projects.length)
                if ($pre.length -gt 0)
                {
                    $pre = "$pre\"
                }
                if ($pre.StartsWith("\"))
                {
                    $pre = $pre.Substring(1)
                }
                $test = $wordToComplete.split('\') | Select-Object -last 1
                Get-ChildItem $examine | Where-Object { $_.PSIsContainer } | Select-Object Name | Where-Object { $_ -like "*$test*" } | ForEach-Object { "$($pre)$($_.Name)\" }

            } )]
        $args
    )
    if ($args)
    {
        echo "cd  $projects\walljm\$args"
        cd $dockerfiles\$args
    }
    else
    {
        echo "cd  $dockerfiles"
        cd  $dockerfiles
    }
}
function dc
{
    echo "docker-compose $($args -join ' ')"
    docker-compose $args
}
function ioc
{
    echo "ionic cordova $($args -join ' ')"
    ionic cordova $args
}

function gt
{
    $cmd, $other, $other2 = $args
    
    if ($cmd -eq "update")
    {
        echo "git checkout $other --force"
        git checkout $other --force
        git clean -f -d -x
        git reset --hard
    }
    elseif ($cmd -eq "heads")
    {
        git branch
    }
    elseif ($cmd -eq "clean")
    {
        git clean -f -d -x
        git reset --hard
    }
    elseif ($cmd -eq "rebase")
    {
        $t1, $t2 = $other
        git checkout $t1
        git rebase $t2
    }
    elseif (($cmd -eq "contracts") -and ($other -eq "pull"))
    {
        git subtree pull --prefix src/ITPIE.Contracts --squash contracts $other2
    }
    elseif (($cmd -eq "contracts") -and ($other -eq "push"))
    {
        git subtree push --prefix src/ITPIE.Contracts --squash contracts $other2
    }
    else
    {
        git $cmd $other
    }
}

function show
{
    $cmd, $other = $args

    if ($cmd -like "ifc*")
    {
        if ($other -like "lst")
        {
            Get-NetAdapter -IncludeHidden | `
                    Sort-Object Hidden, InterfaceIndex | `
                    Format-List -Property  InterfaceIndex, Name, InterfaceDescription, InterfaceName, MacAddress, `
                    AdminStatus, ifOperStatus, LinkSpeed, ReceiveLinkSpeed, TransmitLinkSpeed, FullDuplex, MediaType, Virtual
        }
        elseif ($other -like "hid*")
        {
            Get-NetAdapter -IncludeHidden | `
                    Sort-Object Hidden, InterfaceIndex | `
                    Format-Table -Property InterfaceIndex, InterfaceName, Name, InterfaceDescription, MacAddress, `
                    PermanentAddress, AdminStatus, ifOperStatus, LinkSpeed, FullDuplex, MediaType, Virtual, `
                    DeviceWakeUpEnable, Hidden, VlanID
        }
        elseif ($other -like "d*")
        {
            Get-NetIPConfiguration -Detailed -All -AllCompartments `
            | ForEach-Object {
                $dns = Get-DnsClientServerAddress -AddressFamily IPv4 -InterfaceAlias $_.InterfaceAlias -CimSession $_.ComputerName -erroraction 'silentlycontinue'
                $dnsv6 = Get-DnsClientServerAddress -AddressFamily IPv6 -InterfaceAlias $_.InterfaceAlias -CimSession $_.ComputerName -erroraction 'silentlycontinue'
                $ip = Get-NetIPAddress -InterfaceAlias $_.InterfaceAlias -AddressFamily IPv4 -PolicyStore ActiveStore -CimSession $_.ComputerName -erroraction 'silentlycontinue'
                $ifc = Get-NetIPInterface -InterfaceAlias $_.InterfaceAlias -AddressFamily IPv4 -PolicyStore ActiveStore -CimSession $_.ComputerName -erroraction 'silentlycontinue'
                $gateway = Get-NetRoute -erroraction 'silentlycontinue' -DestinationPrefix '0.0.0.0/0' -InterfaceIndex $_.InterfaceIndex -PolicyStore ActiveStore -CimSession $_.ComputerName | Select-Object NextHop
                $adapter = Get-NetAdapter -Name $_.InterfaceAlias -CimSession $_.ComputerName -erroraction 'silentlycontinue'
                $profile = Get-NetConnectionProfile -InterfaceAlias  $_.InterfaceAlias -CimSession $_.ComputerName -erroraction 'silentlycontinue'

                $obj = [PSCustomObject]@{
                    InterfaceAlias       = $_.InterfaceAlias
                    InterfaceDescription = $_.InterfaceDescription
                    InterfaceIndex       = $_.InterfaceIndex
                    DHCP                 = $ifc.DHCP
                    Virtual              = $adapter.Virtual
                }

                if ($adapter.LinkLayerAddress -ne $null)
                {
                    $obj | Add-Member -NotePropertyName MAC -NotePropertyValue $adapter.LinkLayerAddress
                }
                if ($adapter.AdminStatus -ne $null)
                {
                    $obj | Add-Member -NotePropertyName AdminStatus -NotePropertyValue $adapter.AdminStatus
                }
                if ($adapter.ifOperStatus -ne $null)
                {
                    $obj | Add-Member -NotePropertyName OperStatus -NotePropertyValue $adapter.ifOperStatus
                }
                if ($adapter.LinkSpeed -ne $null)
                {
                    $obj | Add-Member -NotePropertyName Speed -NotePropertyValue $adapter.LinkSpeed
                }
                if ($adapter.FullDuplex -ne $null)
                {
                    $obj | Add-Member -NotePropertyName FullDuplex -NotePropertyValue $adapter.FullDuplex
                }
                if ($adapter.MediaType -ne $null)
                {
                    $obj | Add-Member -NotePropertyName MediaType -NotePropertyValue $adapter.MediaType
                }
                if ($adapter.VlanID -ne $null)
                {
                    $obj | Add-Member -NotePropertyName VlanID -NotePropertyValue $adapter.VlanID
                }
                if ($profile.IPv4Connectivity -ne $null)
                {
                    $obj | Add-Member -NotePropertyName IPv4Connectivity -NotePropertyValue $profile.IPv4Connectivity
                }
                if ($profile.NetworkCategory -ne $null)
                {
                    $obj | Add-Member -NotePropertyName NetworkCategory -NotePropertyValue $profile.NetworkCategory
                }
                if ($ip.IPAddress -ne $null)
                {
                    $obj | Add-Member -NotePropertyName IPv4 -NotePropertyValue "$($ip.IPAddress)/$($ip.PrefixLength)"
                    $obj | Add-Member -NotePropertyName IPv4Type -NotePropertyValue "$($ip.Type)"
                    $obj | Add-Member -NotePropertyName IPv4Origin -NotePropertyValue "$($ip.SuffixOrigin)"
                }
                if (($gateway | Join-String -Property NextHop -Separator "`n") -ne '')
                {
                    $obj | Add-Member -NotePropertyName IPv4Gateway -NotePropertyValue ($gateway | Join-String -Property NextHop -Separator "`n")
                }
                if (($dns.ServerAddresses -join "`n") -ne '')
                {
                    $obj | Add-Member -NotePropertyName IPv4DNS -NotePropertyValue ($dns.ServerAddresses -join "`n")   
                }
                if (($dnsv6.ServerAddresses -join "`n") -ne '')
                {
                    $obj | Add-Member -NotePropertyName IPv6DNS -NotePropertyValue ($dnsv6.ServerAddresses -join "`n")   
                }
                return $obj;
            } `
            | Where-Object -Property Virtual -ne False `
            | Where-Object -Property Virtual -ne $null `
            | Format-List -Property *
        }
        else
        {
            Get-NetAdapter | `
                    Sort-Object Hidden, InterfaceIndex | `
                    Format-Table -Property InterfaceIndex, InterfaceName, Name, InterfaceDescription, MacAddress, `
                    AdminStatus, ifOperStatus, LinkSpeed, FullDuplex, MediaType, Virtual, `
                    DeviceWakeUpEnable
        }
    }
    elseif ($cmd -like "route*")
    {
        if ($other -like "det*")
        {
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
        else
        {
            Get-NetRoute -IncludeAllCompartments | `
                    Format-Table -Property DestinationPrefix, NextHop, InterfaceMetric, RouteMetric, Protocol, State, Publish, TypeOfRoute, IsStatic, `
                    InterfaceAlias, InterfaceIndex, PreferredLifetime, AdminDistance
        }
        
    }
    elseif ($cmd -like "ip*")
    {
        Get-NetIPAddress -IncludeAllCompartments | `
                Sort-Object InterfaceIndex | `
                Format-Table -Property InterfaceIndex, InterfaceAlias, IPAddress, PrefixLength, PrefixOrigin, Type, ValidLifetime
    }
    elseif ($cmd -like "arp*")
    {
        Get-NetNeighbor -AddressFamily IPv4 -IncludeAllCompartments | `
                Sort-Object InterfaceIndex, State, IPAddress | `
                Format-Table -Property IPAddress, LinkLayerAddress, InterfaceIndex, InterfaceAlias, State
    }
    elseif ($cmd -like "lin*")
    {
        wsl --list --verbose --all
    }
}


# backup files from a docker volume into /tmp/backup.tar.gz
function dockerVolumeBackupCompressed()
{
    docker run --rm -v /tmp:/backup --volumes-from "$1" debian:jessie tar -czvf /backup/backup.tar.gz "${@:2}"
}

# restore files from /tmp/backup.tar.gz into a docker volume
function dockerVolumeRestoreCompressed()
{
    docker run --rm -v /tmp:/backup --volumes-from "$1" debian:jessie tar -xzvf /backup/backup.tar.gz "${@:2}"
    echo "Double checking files..."
    docker run --rm -v /tmp:/backup --volumes-from "$1" debian:jessie ls -lh "${@:2}"
}

# backup files from a docker volume into /tmp/backup.tar
function dockerVolumeBackup()
{
    docker run --rm -v /tmp:/backup --volumes-from "$1" busybox tar -cvf /backup/backup.tar "${@:2}"
}

# restore files from /tmp/backup.tar into a docker volume
function dockerVolumeRestore()
{
    docker run --rm -v /tmp:/backup --volumes-from "$1" busybox tar -xvf /backup/backup.tar "${@:2}"
    echo "Double checking files..."
    docker run --rm -v /tmp:/backup --volumes-from "$1" busybox ls -lh "${@:2}"
}



####
# Helper Functions
####

function getDirName
{
    [System.IO.Path]::GetFileName([System.IO.Path]::GetDirectoryName($args))
}

function aliases
{
    cmds
    vcmds
    mcmds
}

set-alias -Name io -Value ionic
set-alias -Name rn -Value react-native

function vs
{
    $project = (Get-ChildItem -Path $args -Name -Include *.sln);
    
    if ($project -eq "" -or $project -eq $null)
    {
        $project = (Get-ChildItem -Path $args -Name -Include *.csproj);
    }
    
    if ($project -eq "" -or $project -eq $null)
    {
        $project = ".";
    }

    devenv.exe $project
}

[System.Environment]::SetEnvironmentVariable('HOME', $ENV:USERPROFILE, 'User')
cmds

#source the work specific profiles
. C:\Projects\walljm\winprofile\vae.ps1
. C:\Projects\walljm\winprofile\migo.ps1

# https://github.com/ili101/Join-Object
. C:\Projects\walljm\winprofile\join.ps1

echo ""