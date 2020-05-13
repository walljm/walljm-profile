
$projects = "c:\projects"


function prompt
{
    $origLastExitCode = $LASTEXITCODE

    $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path

    Write-Host $curPath -ForegroundColor Yellow -NoNewline
    $LASTEXITCODE = $origLastExitCode
    "$('>' * ($nestedPromptLevel + 1)) "
}

# function sudo {
# param (
# [ScriptBlock]
# $code
# ) 
# # Elevate our permissions for this first.
# Start-Process "pwsh.exe" -ArgumentList "-Command $code" -WindowStyle hidded -Verb RunAs -RedirectStandardError &2 -RedirectStandardOutput &1 
# }

function cmds
{
    echo " show commands"
    echo " ---------------------------------------------------------------"
    echo "   show route"
    echo "   show route detail"
    echo "   show interfaces"
    echo "   show interfaces hidden"
    echo "   show ip"
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
    echo "    dco == dc -f docker-compose.yml -f docker-compose.local.yml"
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
        echo "cd  $projects\walljm\$args"
        cd $projects\walljm\$args
    }
    else
    {
        echo "cd  $projects"
        cd  $projects\walljm
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
    if ($cmd -like "int*")
    {
        if ($other -like "hid*")
        {
            Get-NetAdapter -IncludeHidden | `
                    Sort-Object Hidden, InterfaceIndex | `
                    Format-Table -Property InterfaceIndex, InterfaceName, Name, InterfaceDescription, MacAddress, `
                    PermanentAddress, AdminStatus, ifOperStatus, LinkSpeed, FullDuplex, MediaType, Virtual, `
                    DeviceWakeUpEnable, Hidden, VlanID
        }
        else
        {
            Get-NetAdapter | `
                    Sort-Object Hidden, InterfaceIndex | `
                    Format-Table -Property InterfaceIndex, InterfaceName, Name, InterfaceDescription, MacAddress, `
                    PermanentAddress, AdminStatus, ifOperStatus, LinkSpeed, FullDuplex, MediaType, Virtual, `
                    DeviceWakeUpEnable, Hidden, VlanID
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
}

function aliases
{
	cmds
	vcmds
	mcmds
}

set-alias -Name io -Value ionic
set-alias -Name rn -Value react-native

cmds
#source the work specific profiles
. C:\Projects\walljm\winprofile\vae.ps1
. C:\Projects\walljm\winprofile\migo.ps1

# https://github.com/ili101/Join-Object
. C:\Projects\walljm\winprofile\join.ps1

echo ""