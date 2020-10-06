$opsfolder = "$projects\vae\ops"
$miscfolder = "$projects\vae\misc"
$engfolder = "$projects\vae\eng"

function vcmds
{ 
    Write-Host  "   cdpo == $opsfolder\packaging"
    Write-Host  "    dco == dc -f docker-compose.yml -f docker-compose.walljm.yml"
    Write-Host  "    ops == demo|test|dev|help -c|clean -p|pull -h|headless -d|down -gp|gitpull"
    Write-Host  "    vpn == vpn enable|disable|start -i|ifIndex -v|vpn"
    Write-Host  "    dev == dev dbd|dbdate $args"
    Write-Host  ""
}

function cdpo
{
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = "If used, dumps you into the demo packing folder")]
        [Alias("demo")]
        [Switch]
        $d,
        [Parameter(Mandatory = $false,
            HelpMessage = "If used, dumps you into the test packing folder")]
        [Alias("test")]
        [Switch]
        $t,
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
    }
    else
    {
        Write-Host  "cd $opsfolder\packaging"
        cd  $opsfolder\packaging
    }
}
function dco
{
    $system, $cmds = $args;

    if (($system -eq $null) -or (!($system -eq "dev") -and ($system -eq "demo") -and ($system -eq "test")))
    {
        Write-Host "A valid cmd is required: dev, demo, test"
        return
    }

    push-location $opsfolder\packaging;
    
    $stack = "itpie_$system"

    Invoke-Expression "docker-compose -f docker-compose.yml -f docker-compose.walljm.$system.yml -p $stack $cmds"
    Pop-Location
}

function ops
{
    param(
        [Parameter(Mandatory = $false,
            HelpMessage = "If used, does a 'pull' before bring the system up.")]
        [Alias("pull")]
        [Switch]
        $p,
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
        [ValidateSet("test", "demo", "dev", "git", "help", "")]
        $cmd)

    push-location;
    
    
    if ($cmd -eq "help")
    {
        Write-Host  ""
        Write-Host  "Syntax: ops dev|test|demo|help -p|pull -c|clean -h|headless -d|down -gp|gitpull"
        Write-Host  ""
        Write-Host  " cmd         - one of the following: 'test', 'demo', 'dev', 'help', ''"
        Write-Host  " -p|pull      - If used, does a 'pull' before bring the system up."
        Write-Host  " -c|clean     - If used, does a 'down -v' before bring the system up."
        Write-Host  " -h|headless  - If used, stops the webclient and itpie-api containers, so you can run them from source."
        Write-Host  " -d|down      - If used, stops all services using docker-compose down"
		
        pop-location;
        return
    }
    
    
    Write-Host  "$projects\vae\ops\packaging"
    cd "$projects\vae\ops\packaging"
    
    if ($cmd -eq $null)
    {
        Write-Host "A valid cmd is required: cmd, demo, test"
        return
    }

    $stack = "itpie_$cmd"
    $dco = "docker-compose -f docker-compose.yml -f docker-compose.walljm.$cmd.yml -p $stack"
    
    if ($p)
    {
        writeHeader " Pulling OPS $stack..."
        invoke "$dco pull"
    }


    if ($d)
    {
        writeHeader " Stopping OPS $stack..."
        invoke "$dco down"
    }
    else 
    {
        if ($c)
        {
            writeHeader " Cleaning OPS $stack..."
            invoke "$dco down -v"
        }

        writeHeader " Starting OPS $stack..."
        invoke "$dco up -d --remove-orphans"

        if ($h)
        {
            invoke "$dco stop itpie-api"
            invoke "$dco stop webclient"
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
        [AllowNull()]
        [Int32]
        $ifIndex,
        [Parameter(Mandatory = $false,
            HelpMessage = "The ip address of the vpn proxy")]
        [Alias("v")]
        [AllowNull()]
        [String]
        $vpn)

    if ($cmd -eq "start")
    {
        ssh -t root@vpnproxy.home "openconnect vpn.vaeit.com --user='jason.wall'"
        return
    }

    if ($PSBoundParameters.ContainsKey('ifIndex') -eq $false)
    {
        # set a default value.
        $ifIndex = 22
    }
    
    if ($PSBoundParameters.ContainsKey('vpn') -eq $false)
    {
        # set a default value.
        $vpn = "192.168.1.54"
    }

    if ($cmd -eq "enable")
    {
        

        Set-DnsClientServerAddress -InterfaceIndex $ifIndex -ServerAddresses ($vpn)

        new-netroute -destinationprefix 10.0.0.0/8 -nexthop $vpn -interfaceindex $ifIndex -Confirm:$false
        new-netroute -destinationprefix 172.16.0.0/12 -nexthop $vpn -interfaceindex $ifIndex -Confirm:$false
        return
    }
    elseif ($cmd -eq "disable")
    {
        remove-netroute -destinationprefix 10.0.0.0/8 -Confirm:$false
        remove-netroute -destinationprefix 172.16.0.0/12 -Confirm:$false
        Set-DnsClientServerAddress -InterfaceIndex $ifIndex -ServerAddresses("192.168.1.1")
        return
    }

    Write-Host  ""
    Write-Host  "Syntax: vpn cmd -i|ifIndex -v|vpn"
    Write-Host  ""
    Write-Host  " cmd         - one of the following: 'enable', 'disable', 'help'"
    Write-Host  " -i|ifIndex  - The index of the interface to route through the vpn"
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
            gitPull $opsfolder;
            gitPull $miscfolder;
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

function gitPull
{
    $folder = $args;
    Write-Host  "";
    get-childitem $folder -directory | where-object { $_.Name -Match "^\w" } | foreach-object {
        
        push-location "$folder\$($_.Name)";
        Write-Host "---------------------------------------------"  -ForegroundColor Yellow
        Write-Host " $($_.Name)" -ForegroundColor Yellow
        Write-Host "---------------------------------------------" -ForegroundColor Yellow
        git pull;
        Write-Host  "";
        Pop-Location
    }
    return
}

function nf
{
    param(
        [String]
        [Parameter(Mandatory = $false, Position = 0,
            HelpMessage = "The name of a network: one, five, large or a cmd: enable, disable")]
        $cmd,
        [String]
        [Parameter(Mandatory = $false, Position = 1,
            HelpMessage = "Logging level: 0==none, 1=basic, 2=verbose, 3=extra verbose")]
        $loglevel,
        [Parameter(Mandatory = $false,
            HelpMessage = "The interface index")]
        [Alias("i")]
        [AllowNull()]
        [Int32]
        $ifIndex)

    if ($cmd -eq "enable")
    {
        new-netroute -destinationprefix 100.64.0.0/12 -nexthop 192.168.20.10 -interfaceindex $ifIndex -Confirm:$false
        show route
        return
    }

    if ($cmd -eq "disable")
    {
        remove-netroute -destinationprefix 100.64.0.0/12 -Confirm:$false
        show route
        return
    }

    echo $cmd
    echo $ifIndex
    if (($cmd -ne $null) -and ($ifIndex -eq 0))
    {
        ssh -t itpie@faker.dev "/bin/bash /home/itpie/fake.sh $($cmd) $($loglevel)"
        return
    }


    Write-Host  ""
    Write-Host  "Syntax: nf cmd loglevel -i"
    Write-Host  ""
    Write-Host  " cmd          - name of one of the fake networks: small, med, large or a cmd: enable, disable"
    Write-Host  " loglevel     - OPTIONAL: logging level: 0==none, 1=basic, 2=verbose, 3=extra verbose"
    Write-Host  " -i|--ifIndex - OPTIONAL: required if using the enable command.  the interface index used by the network faker"

    return

}

vcmds