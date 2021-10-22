$opsfolder = "$projects\vae\operations"
$miscfolder = "$projects\vae\misc"
$engfolder = "$projects\vae\engineering"
$dockercompose = "docker-compose -f docker-compose.yml -f docker-compose.walljm.yml"

function vcmds
{ 
    Write-Host  "   cdpo == $opsfolder\packaging"
    Write-Host  "    dco == dc -f docker-compose.yml -f docker-compose.walljm.yml"
    Write-Host  "    ops == demo|test|dev|help -c|clean -p|pull -h|headless -d|down -gp|gitpull"
    Write-Host  "    vpn == vpn enable|disable|start -i|ifIndex -v|vpn"
    Write-Host  "    dev == dev dbd|dbdate|gp|gitpull $args"
    Write-Host  ""
    Write-Host  "  ignoreDockerCompose | ignores the docker-compose file so you can make changes without running into issues"
    write-host  "            setVaeEnv | sets the vae environment variabls for the user"
    Write-Host  ""
}

function cdpo
{
    param (
        [Parameter(Mandatory = $false)]
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
            
                $dir = "$opsfolder\$wordToComplete"			
                if ($wordToComplete -eq "")
                {
                    $dir = "$opsfolder\a"
                }
                if ($wordToComplete.EndsWith("\"))
                {
                    $dir = $dir + "a"
                }
                $examine = split-path -path $dir
                $pre = $examine.Substring($opsfolder.length)
                if ($pre.length -gt 0)
                {
                    $pre = "$pre\"
                }
                if ($pre.StartsWith("\"))
                {
                    $pre = $pre.Substring(1)
                }
                $test = $wordToComplete.split('\') | Select-Object -last 1
                Get-ChildItem $examine | Where-Object { $_.PSIsContainer } | Select-Object Name | Where-Object { $_ -like "*$test*" } | ForEach-Object { "$($pre)$($_.Name)" }

            } )]
        $args
    )
    if ($args)
    {
        Write-Host  "cd $opsfolder\$args"
        cd $opsfolder\$args
        
        $host.ui.RawUI.WindowTitle = "cdpo \$args"
    }
    else
    {
        Write-Host  "cd $opsfolder"
        cd  $opsfolder
        $host.ui.RawUI.WindowTitle = "cdpo"
    }
}
function dco
{
    $cmds = $args;

    push-location $opsfolder;
    
    Invoke-Expression "$dockercompose $cmds"

    Pop-Location
}
function dc1 { Invoke-Expression "$dockercompose -p t1 $args" }
function dc2 { Invoke-Expression "$dockercompose -p t2 $args" }

function ops
{
    param(
        [Parameter(Mandatory = $false,
            HelpMessage = "If used, does a 'down -v' before bring the system up.")]
        [Alias("clean")]
        [Switch]
        $c,
        [Parameter(Mandatory = $false,
            HelpMessage = "If used, stops the webclient and itpie-api containers, so you can run them from source.")]
        [Alias("headless")]
        [Switch]
        $h,
        [Parameter(Mandatory = $false,
            HelpMessage = "If used, stops all services using docker-compose down.")]
        [Alias("down")]
        [Switch]
        $d,
        [String]
        [Parameter(Mandatory = $false, Position = 0,
            HelpMessage = "Enter one of the following: test, demo, dev, git")]
        [ValidateSet("git", "help", "")]
        $cmd)

    push-location;
    
    
    if ($cmd -eq "help")
    {
        Write-Host  ""
        Write-Host  "Syntax: ops -c|clean -h|headless -d|down -gp|gitpull"
        Write-Host  ""
        Write-Host  " cmd          - one of the following: 'help', ''"
        Write-Host  " -c|clean     - If used, does a 'down -v' before bring the system up."
        Write-Host  " -h|headless  - If used, stops the webclient and itpie-api containers, so you can run them from source."
        Write-Host  " -d|down      - If used, stops all services using $dockercompose down"
		
        pop-location;
        return
    }
    
    
    Write-Host  "$opsfolder"
    cd "$opsfolder"
        
    if ($d)
    {
        writeHeader " Stopping OPS..."
        invoke "$dockercompose down"
    }
    else 
    {
        if ($c)
        {
            writeHeader " Cleaning OPS..."
            invoke "$dockercompose down -v"
        }

        writeHeader " Starting OPS..."
        invoke "$dockercompose up -d --build --remove-orphans"

        if ($h)
        {
            invoke "$dockercompose stop itpie-api"
            invoke "$dockercompose stop webclient"
        }
    }	

    pop-location;
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

function writeHeader
{
    Write-Host "---------------------------------------------"  -ForegroundColor Yellow
    Write-Host  " $args..."  -ForegroundColor Yellow
    Write-Host "---------------------------------------------"  -ForegroundColor Yellow
}

function vpn
{
    param(
        [String]
        [Parameter(Mandatory = $false, Position = 0,
            HelpMessage = "Enter one of the following: enable, disable")]
        [ValidateSet("enable", "disable", "start")]
        $cmd,
        [Parameter(Mandatory = $false,
            HelpMessage = "The interface index")]
        [Alias("i")]
        [ValidateSet("wifi", "dock")]
        [AllowNull()]
        [String]
        $ifc,
        [Parameter(Mandatory = $false,
            HelpMessage = "The ip address of the vpn proxy")]
        [Alias("v")]
        [AllowNull()]
        [String]
        $vpn)

    if ($cmd -eq "start")
    {
        $host.ui.RawUI.WindowTitle = "vpn.vaeit.com: jason.wall"
        ssh -t root@vpnproxy.home "openconnect vpn.vaeit.com --user='jason.wall'"
        return
    }

    
    if ($PSBoundParameters.ContainsKey('vpn') -eq $false)
    {
        # set a default value.
        $vpn = "192.168.1.54"
    }

    if ($PSBoundParameters.ContainsKey('ifc') -eq $false)
    {
        # set a default value.
        $ifcName = "EthernetDock"
    }
    elseif ($ifc -eq 'dock')
    {
        $ifcName = "EthernetDock"
    }
    elseif ($ifc -eq 'wifi')
    {
        $ifcName = "WIFI"

    }

    if ($cmd -eq "enable")
    {

        $ifIndex = Get-NetIPAddress -IncludeAllCompartments | `
                Where-Object InterfaceAlias -eq $ifcName | `
                Where-Object AddressFamily -eq 'IPv4' | `
                Select-Object -ExpandProperty InterfaceIndex

        Set-DnsClientServerAddress -InterfaceIndex $ifIndex -ServerAddresses ($vpn)

        New-NetRoute -DestinationPrefix 10.0.0.0/8 -nexthop $vpn -InterfaceIndex $ifIndex -Confirm:$false
        New-NetRoute -DestinationPrefix 172.16.0.0/12 -nexthop $vpn -InterfaceIndex $ifIndex -Confirm:$false
        return
    }
    elseif ($cmd -eq "disable")
    {
        Remove-NetRoute -DestinationPrefix 10.0.0.0/8 -Confirm:$false
        Remove-NetRoute -DestinationPrefix 172.16.0.0/12 -Confirm:$false
        Set-DnsClientServerAddress -InterfaceIndex $ifIndex -ServerAddresses("192.168.1.1")
        return
    }

    Write-Host  ""
    Write-Host  "Syntax: vpn cmd -i|ifc -v|vpn"
    Write-Host  ""
    Write-Host  " cmd         - one of the following: 'enable', 'disable', 'help'"
    Write-Host  " -i|ifc      - one of the following: 'dock', 'wifi' defaults to 'dock'"
    Write-Host  " -v|vpn      - The ip address of the vpn proxy"
		
    pop-location;
    return

}

function dev
{
    param(
        [String]
        [Parameter(Mandatory = $true, Position = 0,
            HelpMessage = "Action: dbdate|dbd gp|gitpull")]
        $action,
        [String]
        [Parameter(Mandatory = $false, Position = 1,
            HelpMessage = "Additional args")]
        $args)
    if ($action -ne $null)
    {
        if (($action -eq 'dbdate') -or ($action -eq 'dbd'))
        {
            Write-Host "Migration sent to clipboard: $((Get-Date).ToUniversalTime().ToString('yyyyMMddHHmmss'))$args"
            Set-Clipboard -V "$((Get-Date).ToUniversalTime().ToString('yyyyMMddHHmmss'))$args"
            return
        }

        if (($action -eq 'gitpull') -or ($action -eq 'gp'))
        {
            gitPullFolder "$projects\walljm";

            gitPullFolder $miscfolder;

            gitPull $opsfolder;
            gitPull $engfolder;

            return
        }
    }

    Write-Host  ""
    Write-Host  "Syntax: dev cmd $args"
    Write-Host  ""
    Write-Host  " dbd|dbdate  - Creates a date stamp in the format used for migrations. "
    Write-Host  " gp|gitpull  - If used, does a gil pull inside of each directory in the $opsfolder"

    return

}

function gitPullFolder
{
    $folder = $args;
    Write-Host  "";
    get-childitem $folder -directory | where-object { $_.Name -Match "^\w" } | foreach-object {
        gitPull "$folder\$($_.Name)";
    }
    return
}

function gitPull
{
    $folder = $args;
    $name = (getDirName "$folder\");

    push-location "$folder";
    Write-Host "---------------------------------------------"  -ForegroundColor Yellow
    Write-Host "$name" -ForegroundColor Yellow
    Write-Host "---------------------------------------------" -ForegroundColor Yellow
    git pull;
    Write-Host  "";
    Pop-Location
}



$fakeNetworksPath = "/mnt/c/Projects/fake_networks"
$fakerBinary = "network-faker-251-linux-x64"
function nf
{
    param(
        [String]
        [Parameter(Mandatory = $false, Position = 0,
            HelpMessage = "The name of a network: one, five, large or a cmd: enable, disable")]
        $cmd)
    if ($cmd -eq "enable")
    {
        $ifIndex = Get-NetIPAddress -IncludeAllCompartments | `
                Where-Object InterfaceAlias -eq 'vEthernet (WSL)' | `
                Where-Object AddressFamily -eq 'IPv4' | `
                Select-Object -ExpandProperty InterfaceIndex
        New-NetRoute -DestinationPrefix 100.64.0.0/12 -NextHop "0.0.0.0" -InterfaceIndex $ifIndex -Confirm:$false
        wsl -u root -- ip addr add 100.64.0.0/12 dev lo
        return
    }
    if ($cmd -eq "disable")
    {
        remove-netroute -destinationprefix 100.64.0.0/12 -Confirm:$false
        return
    }
    if ($cmd -ne $null)
    {
        $oldTitle = $host.ui.RawUI.WindowTitle
        $host.ui.RawUI.WindowTitle = "network faker: $cmd"
        wsl -u root bash -c "cd ~ && ./$fakerBinary --NetworkPath=$fakeNetworksPath/$cmd --Logging:LogLevel:Default=Information"
        $host.ui.RawUI.WindowTitle = $oldTitle
        return
    }
    Write-Host  ""
    Write-Host  "Syntax: nf cmd"
    Write-Host  ""
    Write-Host  " cmd          - name of one of the fake networks installed in C:\Projects\fake_networks, or enable,disable to setup the route or remove it"
    return
}

function ignoreDockerCompose
{
    push-location "$opsfolder";
    git update-index --assume-unchanged .\docker-compose.override.yml
    Pop-Location
}

function setVaeEnv
{
    [System.Environment]::SetEnvironmentVariable('ITPIE_LICENSE__KEY', 'aMORtqjHzyOFQIHeGPQ8e0nT1%2BeZYanKKtZEpDF2CJ3mvQYCGYwGMIsxbvqpBLlOWRnhhO8gW1G8djUtDSLx4A%3D%3D', 'User')
    [System.Environment]::SetEnvironmentVariable('ASPNETCORE_ENVIRONMENT', 'Development', 'User')
    [System.Environment]::SetEnvironmentVariable('NEXTGEN_ENCRYPTION_KEY', 'ErbDoZ+8v/jKRFgrgZcqycU31awVnWR4C/2pIvwl/TQ=', 'User')
    [System.Environment]::SetEnvironmentVariable('NEXTGEN_ENCRYPTION_IV', 'gZ2zXALeWPLqo1Vw1ElT5w==', 'User')
}

vcmds
