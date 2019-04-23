$opsfolder = "$projects\vae\ops"
function vcmds { 
    echo ""
    echo " VAE "
    echo "-----------------------------------------------------------------"
	echo "   cdop == $opsfolder\packaging"
	echo "    dco == dc -f docker-compose.yml -f docker-compose.local.yml"
}

function cdop {
	cd $opsfolder\packaging
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

vcmds