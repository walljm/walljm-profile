export PS1=" \w $ "
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export GREP_OPTIONS='--color=auto'
export CLICOLOR=1
# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

alias less='less --RAW-CONTROL-CHARS'

alias dir="ls -lahFG"
alias dc="docker-compose"
alias io="ionic"
alias ioc="ionic cordova"
alias iodbga="ionic cordova run android --device -l --debug"
alias iodbgi="ionic cordova run ios --device -l --debug"
alias cdp="cd /Users/walljm/projects"

iodb() {
    #do things with parameters like $1 such as
    ionic cordova run $1 --device -l --debug
}
dsh() {
    docker exec -it $1 /bin/bash
}

eval "$(direnv hook bash)"

echoAliases(){
    echo "walljm's aliases"
    echo "----------------------------------------------------------"
    echo "    dir=\"ls -lahFG\""
    echo "     dc=\"docker-compose\""
    echo "     io=\"ionic\""
    echo "    ioc=\"ionic cordova\""
    echo " iodbga=\"ionic cordova run android --device -l --debug\""
    echo " iodbgi=\"ionic cordova run ios --device -l --debug\""
    echo "    cdp=\"cd /Users/walljm/projects\""
    echo "----------------------------------------------------------"
    echo ""
}

echoAliases
