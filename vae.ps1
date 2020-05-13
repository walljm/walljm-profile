$opsfolder = "$projects\vae\ops"

function vcmds
{ 
    Write-Host  "   cdpo == $opsfolder\packaging"
    Write-Host  "    dco == dc -f docker-compose.yml -f docker-compose.local.yml"
    Write-Host  "    ops == demo|test|dev|help -c|clean -p|pull -h|headless -d|down -gp|gitpull"
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
    push-location $opsfolder\packaging;
    $active = [System.Environment]::GetEnvironmentVariable('ActiveOpsEnv' , [System.EnvironmentVariableTarget]::User)
    if ($active -ne "")
    {
        docker-compose -f docker-compose.yml -f docker-compose.local.yml -p $active $args
    }
    else
    {
        docker-compose -f docker-compose.yml -f docker-compose.local.yml $args
    }
    Pop-Location
}
function dcd
{
    push-location $projects\vae\disn\src\packaging;
    docker-compose -p disn -f docker-compose.yml -f docker-compose.local.dev.yml $args
    pop-location;
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
        
        [Parameter(Mandatory = $false,
            HelpMessage = "If used, does a git pull in ever folder in the ops folder.")]
        [Alias("gp")]
        [Switch]
        $GitPull,
        [String]
        [Parameter(Mandatory = $false, Position = 0,
            HelpMessage = "Enter one of the following: test, demo, dev, git")]
        [ValidateSet("test", "demo", "dev", "git", "help", "")]
        $cmd)

    push-location;
    
    if ($GitPull)
    {
        Write-Host  "";
        get-childitem $opsfolder -directory | where-object { $_.Name -Match "^\w" } | foreach-object { 
            cd "$opsfolder\$($_.Name)";
            Write-Host "---------------------------------------------"  -ForegroundColor Yellow
            Write-Host " $($_.Name)" -ForegroundColor Yellow
            Write-Host "---------------------------------------------" -ForegroundColor Yellow
            git pull;
            Write-Host  "";
        }
        pop-location;
        return
    }
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
        Write-Host  " -gp|gitpull  - If used, does a gil pull inside of each directory in the $opsfolder"
		
        pop-location;
        return
    }
    
    
    Write-Host  "$projects\vae\ops\packaging"
    cd "$projects\vae\ops\packaging"
    
    $active = [System.Environment]::GetEnvironmentVariable('ActiveOpsEnv' , [System.EnvironmentVariableTarget]::User)

    if (($cmd -ne $null) -and ($active -ne "itpie_$cmd") -and ($cmd -ne ""))
    {
        Write-Host "---------------------------------------------"  -ForegroundColor Yellow
        Write-Host  " Stopping OPS..."  -ForegroundColor Yellow
        Write-Host "---------------------------------------------"  -ForegroundColor Yellow
        if ($active -ne $null)
        {
            Write-Host  "docker-compose -f docker-compose.yml -f docker-compose.local.yml -p $active down"
            docker-compose -f docker-compose.yml -f docker-compose.local.yml -p $active down
        }
        else
        {
            if ($cmd -ne "demo")
            {
                Write-Host  "docker-compose -f docker-compose.yml -f docker-compose.local.yml -p demo down"
                docker-compose -f docker-compose.yml -f docker-compose.local.yml -p demo down
            }
            if ($cmd -ne "test")
            {
                Write-Host  "docker-compose -f docker-compose.yml -f docker-compose.local.yml -p test down"
                docker-compose -f docker-compose.yml -f docker-compose.local.yml -p test down
            }
            if ($cmd -ne "dev")
            {
                Write-Host  "docker-compose -f docker-compose.yml -f docker-compose.local.yml -p dev down"
                docker-compose -f docker-compose.yml -f docker-compose.local.yml -p dev down
            }
        }
    }

    if ($p)
    {
        Write-Host "---------------------------------------------"  -ForegroundColor Yellow
        Write-Host  " Pulling OPS $cmd..."  -ForegroundColor Yellow
        Write-Host "---------------------------------------------"  -ForegroundColor Yellow
        Write-Host  "docker-compose -f docker-compose.yml -f docker-compose.local.yml pull"
        docker-compose -f docker-compose.yml -f docker-compose.local.yml pull
    }

    $stack = "itpie_$cmd"
    if (($cmd -eq "") -and ($active -ne ""))
    {
        # if no cmd was given, then you should stop the active ops env
        $stack = $active
    }

    if ($d)
    {
        Write-Host "---------------------------------------------"  -ForegroundColor Yellow
        Write-Host  " Stopping OPS $stack..."  -ForegroundColor Yellow
        Write-Host "---------------------------------------------"  -ForegroundColor Yellow
        Write-Host  "docker-compose -f docker-compose.yml -f docker-compose.local.yml -p $stack down"
        docker-compose -f docker-compose.yml -f docker-compose.local.yml -p $stack down
        [System.Environment]::SetEnvironmentVariable('ActiveOpsEnv', "" , [System.EnvironmentVariableTarget]::User)
    }
    else 
    {
        if ($c)
        {
            Write-Host "---------------------------------------------"  -ForegroundColor Yellow
            Write-Host  " Cleaning OPS $stack..."  -ForegroundColor Yellow
            Write-Host "---------------------------------------------"  -ForegroundColor Yellow
            Write-Host  "docker-compose -f docker-compose.yml -f docker-compose.local.yml -p $stack down -v"
            docker-compose -f docker-compose.yml -f docker-compose.local.yml -p $stack down -v
        }

        Write-Host "---------------------------------------------"  -ForegroundColor Yellow
        Write-Host  " Starting OPS $stack..."  -ForegroundColor Yellow
        Write-Host "---------------------------------------------"  -ForegroundColor Yellow
        Write-Host  "docker-compose -f docker-compose.yml -f docker-compose.local.yml -p $stack up -d --remove-orphans"
        [System.Environment]::SetEnvironmentVariable('ActiveOpsEnv', $stack , [System.EnvironmentVariableTarget]::User)
        docker-compose -f docker-compose.yml -f docker-compose.local.yml -p $stack up -d --remove-orphans

        if ($h)
        {
            Write-Host  "docker-compose -f docker-compose.yml -f docker-compose.local.yml -p $stack stop itpie-api"
            docker-compose -f docker-compose.yml -f docker-compose.local.yml -p $stack stop itpie-api
            Write-Host  "docker-compose -f docker-compose.yml -f docker-compose.local.yml -p $stack stop webclient"
            docker-compose -f docker-compose.yml -f docker-compose.local.yml -p $stack stop webclient
        }
    }	

    pop-location;
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
        ssh -t root@vpnproxy.lan "openconnect vpn.vaeit.com --user='jason.wall'"
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


function nf
{
    param(
        [String]
        [Parameter(Mandatory = $true, Position = 0,
            HelpMessage = "The name of a network: one, five, large, etc...")]
        $cmd,
        [String]
        [Parameter(Mandatory = $false, Position = 1,
            HelpMessage = "Logging level: 0==none, 1=basic, 2=verbose, 3=extra verbose")]
        $loglevel)
    if ($cmd -ne $null)
    {
        ssh -t itpie@faker.dev "/bin/bash /home/itpie/fake.sh $($cmd) $($loglevel)"
        return
    }

    Write-Host  ""
    Write-Host  "Syntax: nf cmd"
    Write-Host  ""
    Write-Host  " cmd         - name of one of the fake networks: small, med, large, xlarge, etc..."
    Write-Host  " loglevel    - logging level: 0==none, 1=basic, 2=verbose, 3=extra verbose"

    return

}

vcmds