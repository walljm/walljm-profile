
$migofolder = "$projects\migoiq"

function mcmds { 
    echo ""
    echo " Migo "
    echo "-----------------------------------------------------------------"
    echo "     mg == run git $args on every dir in $migofolder"
}

function mg {
    Set-PSDebug -Trace 2
	
	get-childitem $migofolder -directory | foreach-object {
		cd $migofolder	
		cd $_.Name
		git $args
		git status	
		cd ..
	}

	Set-PSDebug -Off
}

mcmds