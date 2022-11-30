$opsfolder = "$projects\vae\operations"
$dockercompose = "docker compose -f docker-compose.yml -f docker-compose.walljm.yml"

function vcmds
{ 
    Write-Host  "      cdpo == $opsfolder"
    Write-Host  "       dco == $dockercompose"
    Write-Host  "       dc1 == $dockercompose -p t1 args"
    Write-Host  "  -----------------------------------------------------------"
    Write-Host  "       itpie | dbd|dbdate|migrate|start|dump|restore|copy args"
    Write-Host  "         vpn | vpn enable|disable|start -i|ifIndex -v|vpn"
    Write-Host  ""
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
    Push-Location $opsfolder;
    
    Invoke-Expression "$dockercompose $args"

    Pop-Location
}

function dc1
{
    Push-Location $opsfolder;
    $cmd, $arguments = $args;

    if ($cmd -eq "reset")
    {
        invoke "dc1 down -v"
        invoke "dc1 up -d --build"
        return
    }

    invoke "$dockercompose -p t1 $args" 

    Pop-Location
}
function vpn
{
    param(
        [String]
        [Parameter(Mandatory = $false, Position = 0,
            HelpMessage = "Enter one of the following: start")]
        [ValidateSet("start")]
        $cmd)

    if ($cmd -eq "start")
    {
        $host.ui.RawUI.WindowTitle = "vpn.vaeit.com: jason.wall"
        ssh -t root@vpnproxy.home "openconnect vpn.vaeit.com --user='jason.wall'"
        return
    }


    Write-Host  ""
    Write-Host  "Syntax: vpn start"

    return
}

function itpie
{
    param(
        [String]
        [Parameter(Mandatory = $false, Position = 0, HelpMessage = "Action")]
        $action,
        [String]
        [Parameter(Mandatory = $false, HelpMessage = "Additional args")]
        $args)

    if ($action -ne $null)
    {
        if (($action -eq 'dbdate') -or ($action -eq 'dbd'))
        {
            Write-Host "Migration sent to clipboard: $((Get-Date).ToUniversalTime().ToString('yyyyMMddHHmmss'))$args"
            Set-Clipboard -V "$((Get-Date).ToUniversalTime().ToString('yyyyMMddHHmmss'))$args"
            return
        }
        elseif (($action -eq 'migrate') -or ($action -eq 'm'))
        {
            Push-Location $opsfolder/source/services/itpie-api
            invoke "dotnet run -- migrate"
            Pop-Location
            return
        }
        elseif (($action -eq 'start'))
        {
            Push-Location $opsfolder/source/services/itpie-api
            invoke "dotnet run -- migrate"
            invoke "dotnet run"
            Pop-Location
            return
        }
        elseif (($action -eq 'restore'))
        {
            invoke "dco down"
            invoke "dc1 down -v"
        
            invoke "dc1 up -d postgres"
            # otherwise... it might try and fail because the server isn't up yet.
            Start-Sleep -Seconds 5 
            invoke "dc1 cp ./itpie.dump postgres:/var/lib/postgresql/itpie.dump"
            invoke "dc1 exec postgres ""su postgres -c 'pg_restore -v --clean --create --format=c -d postgres < /var/lib/postgresql/itpie.dump'"""
            invoke "dc1 up -d --build"
            return
        }
        elseif (($action -eq 'dump'))
        {
            invoke "dco down"
            invoke "dc1 down -v"
        
            invoke "dco up -d postgres"
            invoke "dco exec postgres ""su postgres -c 'pg_dump --clean --format=c itpie > /var/lib/postgresql/itpie.dump'"""
            invoke "dco cp postgres:/var/lib/postgresql/itpie.dump ./itpie.dump"
            invoke "dco down"
            return
        }
        elseif (($action -eq 'copy'))
        {
            invoke "dco down"
            invoke "dc1 down -v"
    
            invoke "dco up -d postgres"
            invoke "dco exec postgres ""su postgres -c 'pg_dump --clean --format=c itpie > /var/lib/postgresql/itpie.dump'"""
            invoke "dco cp postgres:/var/lib/postgresql/itpie.dump ./itpie.dump"
            invoke "dco down"
    
            invoke "dc1 up -d postgres"
            # otherwise... it might try and fail because the server isn't up yet.
            Start-Sleep -Seconds 5
            invoke "dc1 cp ./itpie.dump postgres:/var/lib/postgresql/itpie.dump"
            invoke "dc1 exec postgres ""su postgres -c 'pg_restore -v --clean --create --format=c -d postgres < /var/lib/postgresql/itpie.dump'"""
            invoke "dc1 up -d --build"
            invoke "rm itpie.dump"
            return
        }
    }

    Write-Host  ""
    Write-Host  "Syntax: itpie cmd $args"
    Write-Host  ""
    Write-Host  " dbd|dbdate  - Creates a date stamp in the format used for migrations. "
    Write-Host  " m|migrate   - Runs the itpie-api migration."
    Write-Host  " start       - Runs the itpie-api migration then starts the server."
    Write-Host  " dump        - Performs a database dump of the long running system."
    Write-Host  " restore     - Performs a database restore to the development system."
    Write-Host  " copy        - Performs a copy of the database from the long running to the development system."

    return

}

function setVaeEnv
{
    [System.Environment]::SetEnvironmentVariable('ITPIE_LICENSE__KEY', 'aMORtqjHzyOFQIHeGPQ8e0nT1%2BeZYanKKtZEpDF2CJ3mvQYCGYwGMIsxbvqpBLlOWRnhhO8gW1G8djUtDSLx4A%3D%3D', 'User')
    [System.Environment]::SetEnvironmentVariable('ASPNETCORE_ENVIRONMENT', 'Development', 'User')
    [System.Environment]::SetEnvironmentVariable('NEXTGEN_ENCRYPTION_KEY', 'ErbDoZ+8v/jKRFgrgZcqycU31awVnWR4C/2pIvwl/TQ=', 'User')
    [System.Environment]::SetEnvironmentVariable('NEXTGEN_ENCRYPTION_IV', 'gZ2zXALeWPLqo1Vw1ElT5w==', 'User')
}

vcmds
