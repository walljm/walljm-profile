$opsfolder = "$projects\vae\ops"
function vcmds { 
    echo ""
    echo " VAE "
    echo " ----------------------------------------------------------------"
	echo "   cdpo == $opsfolder\packaging"
	echo "    dco == dc -f docker-compose.yml -f docker-compose.local.yml"
	echo "    ops == demo|test|dev clean|pull"
}

function cdpo {
	param (
        [Parameter(Mandatory=$false)]
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
			$test = $wordToComplete.split('\') | select -last 1
			Get-ChildItem $examine | ?{ $_.PSIsContainer } | select Name | where {$_ -like "*$test*"} | Foreach {"$($pre)$($_.Name)"}

        } )]
        $args
      )
	echo $args
	echo $args
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
function dco {
 docker-compose -f docker-compose.yml -f docker-compose.local.yml $args
}

function gto {
    #Set-PSDebug -Trace 1
	echo "git $($args -join ' ')"
	$dirs = get-childitem $opsfolder -directory

	foreach ($dir in $dirs) {
		cd $opsfolder	
		cd $dir.Name
		pwd
		echo "git $($args -join ' ')"
		gt $args
		echo ""
		cd ..
	}

	#Set-PSDebug -Off
}

function ops {
     param(
         [Parameter(Mandatory=$false,
			HelpMessage="If used, does a 'pull' before bring the system up.")]
		 [Alias("pull")]
		 [Switch]
         $p,
         [Parameter(Mandatory=$false,
			HelpMessage="If used, does a 'down -v' before bring the system up.")]
		 [Alias("clean")]
		 [Switch]
         $c,
		 [String]
		 [Parameter(Mandatory=$true, Position=0,
			HelpMessage="Enter one of the following: test, demo, dev")]
		 [ValidateSet("test", "demo", "dev")]
		 $cmd)
	
	if ($cmd -eq "demo")
	{
		echo ""
		echo "Stopping OPS dev..."
		echo ""
		cd "$projects\vae\ops\packaging"
		dco down
		
		echo ""
		echo "Stopping OPS test..."
		echo ""
		cd "$projects\vae\test"
		dco down
		
		echo ""
		echo "Starting OPS demo..."
		echo ""
		cd "$projects\vae\demo"
		if ($c)
		{
			dco down -v
		}
		if ($p)
		{
			dco pull
		}
		dco up -d
	}
	elseif ($cmd -eq "test")
	{
		echo ""
		echo "Stopping OPS dev..."
		echo ""
		cd "$projects\vae\ops\packaging"
		dco down
		
		echo ""
		echo "Stopping OPS demo..."
		echo ""
		cd "$projects\vae\demo"
		dco down
		
		echo ""
		echo "Starting OPS test..."
		echo ""
		cd "$projects\vae\test"
		if ($c)
		{
			dco down -v
		}
		if ($p)
		{
			dco pull
		}
		dco up -d
	}
	elseif ($cmd -eq "dev")
	{
		echo ""
		echo "Stopping OPS test..."
		echo ""
		cd "$projects\vae\test"
		dco down
		
		echo ""
		echo "Stopping OPS demo..."
		echo ""
		cd "$projects\vae\demo"
		dco down
		
		echo ""
		echo "Starting OPS dev..."
		echo ""
		cd "$projects\vae\ops\packaging"
		if ($c)
		{
			dco down -v
		}
		if ($p)
		{
			dco pull
		}
		dco up -d
	}
}

vcmds