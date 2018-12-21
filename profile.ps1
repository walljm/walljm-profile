echo "This has loaded walljm's aliases."
echo ""

function prompt {
    $origLastExitCode = $LASTEXITCODE

    $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path

    Write-Host $curPath -ForegroundColor DarkCyan -NoNewline
    $LASTEXITCODE = $origLastExitCode
    "$('>' * ($nestedPromptLevel + 1)) "
}

function cmds { 
    echo ""
    echo " Misc"
    echo "-----------------------------------------------------------------"
    echo "   grep == sls $args"
    echo "    nst == netstat -n -b"
	echo "    cdp == cd  e:\projects\"
	echo "builddb == builds the dynamicbible android app"
	echo "     mg == runs git $args in every migoiq project dir."
	echo "     dc == docker-compose $args"
	echo "     rn == react-native $args"
	echo "     io == ionic $args"
	echo "    dsh == docker exec -it $args /bin/bash"
	echo "    psh == docker exec -it predictionio_pio_1 /bin/bash"
    echo ""
	echo "---------------------------------------------------------------------"
	echo ""
	echo ""
}

function grep { 
    sls $args
}

function nst {
    echo "netstat -n $($args -join ' ')"
    netstat -n $args
}

function cdp {
    echo "cd  e:\projects\"
    cd  e:\projects\
}

function builddb {
	cddb
    cd ..
	.\build_android.bat $args
}

function dc {
	echo "docker-compose $($args -join ' ')"
	docker-compose $args
}

function rn {
	echo "react-native $($args -join ' ')"
	react-native $args
}

function io {
	echo "ionic $($args -join ' ')"
	ionic $args
}

function dsh {
	echo "docker exec -it $($args -join ' ') /bin/bash"
	docker exec -it $args /bin/bash 
}

function psh {
	docker exec -it predictionio_pio_1 /bin/bash 
}

function mg {
    Set-PSDebug -Trace 2
	
	get-childitem e:\projects\migoiq -directory | foreach-object {
		cd e:\projects\migoiq	
		cd $_.Name
		git $args
		git status	
		cd ..
	}

	Set-PSDebug -Off
}

function evars {
	echo ""
	echo "Environment Variables Defined in Shell"
	echo "---------------------------------------------------------------------"
	echo ""
	$env:PRISMA_SECRET="asd;lkjsapoifuasdfpoiusad;ljsadf"
	Write-Host "PRISMA_SECRET: " $env:PRISMA_SECRET
	$env:PRISMA_ENDPOINT="http://localhost:4466/walljm-prisma/local"
	Write-Host "PRISMA_ENDPOINT: " $env:PRISMA_ENDPOINT
	$env:APP_SECRET="asdf;lkjsad;lkjsdafl;kdjsf"
	Write-Host "APP_SECRET: " $env:APP_SECRET
	$env:FLEET_TRACKING="true"
	Write-Host "FLEET_TRACKING: " $env:FLEET_TRACKING
	$env:ADMIN_TOKEN="Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7InNlcnZpY2UiOiJ3YWxsam0tcHJpc21hQGxvY2FsIiwicm9sZXMiOlsiYWRtaW4iXX0sImlhdCI6MTUzOTYyNDI5NCwiZXhwIjoxNTQwMjI5MDk0fQ.kHs7jYN1uZfseTSlU2t1hmIQAEjAdVQ7fMZv42mcUZA"
	Write-Host "ADMIN_TOKEN: " $env:ADMIN_TOKEN
	$env:ANDROID_HOME="C:\Users\walljm\AppData\Local\Android\Sdk"
	Write-Host "ANDROID_HOME: " $env:ANDROID_HOME
	$env:JAVA_HOME="C:\Program Files\Java\jdk1.8.0_121"
	Write-Host "JAVA_HOME: " $env:JAVA_HOME
	echo "---------------------------------------------------------------------"
	echo ""
}

#evars
cmds
