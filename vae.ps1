$opsfolder = "$projects\vae\ops"
function vcmds
{ 
    echo ""
    echo " VAE "
    echo " ----------------------------------------------------------------"
    echo "   cdpo == $opsfolder\packaging"
    echo "    dco == dc -f docker-compose.yml -f docker-compose.local.yml"
    echo "    ops == demo|test|dev|help clean|pull|headless|down"
	echo "  npull == runs git pull on every director in the $opsfolder"
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
    echo "cd $opsfolder\$args"
    cd $opsfolder\$args
}
else
{
    echo "cd $opsfolder\packaging"
    cd  $opsfolder\packaging
}
}
function dco
{
    docker-compose -f docker-compose.yml -f docker-compose.local.dev.yml $args
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
            HelpMessage = "Enter one of the following: test, demo, dev")]
        [ValidateSet("test", "demo", "dev", "")]
        $cmd)
		
    if ($cmd -eq "help")
    {
        echo ""
        echo "Syntax: ops `$cmd -p|pull -c|clean -h|headless -d|down"
        echo ""
        echo " `$cmd         - one of the following: 'test', 'demo', 'dev'"
        echo " -p|pull      - If used, does a 'pull' before bring the system up."
        echo " -c|clean     - If used, does a 'down -v' before bring the system up."
        echo " -h|headless  - If used, stops the webclient and itpie-api containers, so you can run them from source."
		echo " -d|down      - If used, stops all services using docker-compose down"
        return
    }
	
    if ($cmd -eq "demo")
    {
        echo ""
        echo "Stopping OPS dev..."
        echo ""
        echo "$projects\vae\ops\packaging"
		cd "$projects\vae\ops\packaging"
		echo "dco down"
        dco down
        
        echo ""
        echo "Stopping OPS test..."
        echo ""
		echo "$projects\vae\test"
        cd "$projects\vae\test"
		echo "dco down"
        dco down
        
        echo "$projects\vae\demo"
        cd "$projects\vae\demo"
    }
    elseif ($cmd -eq "test")
    {
        echo ""
        echo "Stopping OPS dev..."
        echo ""
        echo "$projects\vae\ops\packaging"
		cd "$projects\vae\ops\packaging"
		echo "dco down"
        dco down
        
        echo ""
        echo "Stopping OPS demo..."
        echo ""
		echo "$projects\vae\demo"
        cd "$projects\vae\demo"
		echo "dco down"
        dco down
        
        echo "$projects\vae\test"
        cd "$projects\vae\test"
    }
    elseif ($cmd -eq "dev")
    {
        echo ""
        echo "Stopping OPS test..."
        echo ""
        echo "$projects\vae\test"
        cd "$projects\vae\test"
		echo "dco down"
        dco down
        
        echo ""
        echo "Stopping OPS demo..."
        echo ""
        echo "$projects\vae\demo"
        cd "$projects\vae\demo"
		echo "dco down"
        dco down
        
		echo "$projects\vae\ops\packaging"
		cd "$projects\vae\ops\packaging"
    }
    
        
    if ($c)
    {
        echo ""
        echo "Cleaning OPS $cmd..."
        echo ""
		echo "dco down -v"
        dco down -v
    }

    if ($p)
    {
        echo ""
        echo "Pulling OPS $cmd..."
        echo ""
		echo "dco pull"
        dco pull
    }

    if ($d)
    {
        echo ""
        echo "Stopping OPS $cmd..."
        echo ""
		echo "dco down"
        dco down
    }
    else 
    {
        echo ""
        echo "Starting OPS $cmd..."
        echo ""
		echo "dco up -d"
        dco up -d --remove-orphans

        if ($h)
        {
			echo "dco stop itpie-api"
            dco stop itpie-api
			echo "dco stop webclient"
            dco stop webclient
        }
    }
}


function npull {
	
	get-childitem $opsfolder -directory | where-object {$_.Name -Match "^\w"} | foreach-object { 
		cd $opsfolder; 
		cd $_.Name; 
		get-location;
		git pull;
	    cd ..;
	}
}

vcmds