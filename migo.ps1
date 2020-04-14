
$migofolder = "$projects\migoiq\migo-retail"

function mcmds
{
    echo "   cdpm == $migofolder"
}

function cdpm
{
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = "If used, dumps you into the app packing folder")]
        [Alias("app")]
        [Switch]
        $a,
        [Parameter(Mandatory = $false,
            HelpMessage = "If used, dumps you into the server packing folder")]
        [Alias("server")]
        [Switch]
        $s,
        [Parameter(Mandatory = $false)]
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
            
                $dir = "$migofolder\$wordToComplete"			
                if ($wordToComplete -eq "")
                {
                    $dir = "$migofolder\a"
                }
                if ($wordToComplete.EndsWith("\"))
                {
                    $dir = $dir + "a"
                }
                $examine = split-path -path $dir
                $pre = $examine.Substring($migofolder.length)
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
    if ($a)
    {
        echo "cd $migofolder\app-retail-consumer"
        cd $migofolder\app-retail-consumer
        return
    }
    if ($s)
    {
        echo "cd $migofolder\server-retail-core\MigoIQ.Retail.Server\"
        cd $migofolder\server-retail-core\MigoIQ.Retail.Server\
        return
    }

    if ($args)
    {
        echo "cd $migofolder\$args"
        cd $migofolder\$args
    }
    else
    {
        echo "cd $migofolder"
        cd  $migofolder
    }
}
mcmds