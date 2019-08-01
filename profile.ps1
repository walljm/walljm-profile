
$projects = "c:\projects"


function prompt
{
    $origLastExitCode = $LASTEXITCODE

    $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path

    Write-Host $curPath -ForegroundColor DarkCyan -NoNewline
    $LASTEXITCODE = $origLastExitCode
    "$('>' * ($nestedPromptLevel + 1)) "
}

function cmds
{
    echo ""
    echo " Misc"
    echo " ----------------------------------------------------------------"
    echo "   grep == sls $args"
    echo "    nst == netstat -n -b"
    echo "    cdp == cd  $projects"
    echo "   cdop == $projects\vae\ops\packaging"
    echo "     dc == docker-compose $args"
    echo "    dco == dc -f docker-compose.yml -f docker-compose.local.yml"
    echo "     rn == react-native $args"
    echo "     io == ionic $args"
    echo "    ioc == ionic cordova $args"
    echo "    dsh == docker exec -it $args /bin/bash"
    echo "   hist == Get-History"
    echo ""
    echo "  ---------------------------------------------------------------"
    echo "  git aliases"
    echo "  ---------------------------------------------------------------"
    echo "   gt update $branch =>"
    echo "      git checkout $other --force"
    echo "      git clean -f -d -x"
    echo "      git reset --hard"
    echo ""
    echo "   gt heads =>"
    echo "      git branch"
    echo ""
    echo "   gt clean =>"
    echo "		git clean -f -d -x"
    echo "		git reset --hard"
    echo ""
    echo "   gt rebase $t1 $t2 =>"
    echo "		git checkout $t1"
    echo "		git rebase $t2"
    echo ""
    echo "-----------------------------------------------------------------"
    echo ""
    echo ""
}

function hist
{ 
    get-history
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
            Get-ChildItem $examine | Where-Object { $_.PSIsContainer } | Select-Object Name | Where-Object { $_ -like "*$test*" } | ForEach-Object { "$($pre)$($_.Name)" }

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

function dc
{
    echo "docker-compose $($args -join ' ')"
    docker-compose $args
}

function rn
{
    echo "react-native $($args -join ' ')"
    react-native $args
}

function io
{
    echo "ionic $($args -join ' ')"
    ionic $args
}

function ioc
{
    echo "ionic cordova $($args -join ' ')"
    ionic cordova $args
}

function dsh
{
    echo "docker exec -it $($args -join ' ') /bin/bash"
    docker exec -it $args /bin/bash 
}


function gt
{
    $cmd, $other = $args
    
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
    else
    {
        git $cmd $other
    }
}

echo "-----------------------------------------------------------------"
#source the work specific profiles
. C:\Projects\walljm\winprofile\vae.ps1
. C:\Projects\walljm\winprofile\migo.ps1
cmds

echo "This has loaded walljm's aliases."
echo ""
