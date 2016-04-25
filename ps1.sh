#!/bin/bash

export PS1_COLOR_RED=$(tput setaf 1)
export PS1_COLOR_GREEN=$(tput setaf 2)
export PS1_COLOR_YELLOW=$(tput setaf 3)
export PS1_COLOR_RESET=$(tput sgr0)

PS1_has_git() { $(which git >/dev/null); }
PS1_exit_code_store() { echo $? > "$HOME/.ps1_exit_code"; }
PS1_exit_code_value() { cat "$HOME/.ps1_exit_code"; }
PS1_exit_code_color()
{
    case $(PS1_exit_code_value) in
        0)   echo $PS1_COLOR_GREEN ;;
        148) echo $PS1_COLOR_YELLOW ;;
        *)   echo $PS1_COLOR_RED ;;
    esac
}
PS1_jobs_value() { jobs > /dev/null; jobs | wc -l; }
PS1_jobs_color()
{
    case $(PS1_jobs_value) in
        0) echo $PS1_COLOR_RESET ;;
        1) echo $PS1_COLOR_GREEN ;;
        *) echo $PS1_COLOR_YELLOW ;;
    esac
}
PS1_git_color()
{
    PS1_has_git || return
    __git_ps1 | grep --silent MERGING && { echo $PS1_COLOR_RED; return; }
    __git_ps1 | grep --silent REBASE  && { echo $PS1_COLOR_RED; return; }
    git diff-index --quiet HEAD -- 2> /dev/null && {
        echo $PS1_COLOR_GREEN
    } || {
        echo $PS1_COLOR_YELLOW
    }
}
PS1_git_value()
{
    PS1_has_git || return
    __git_ps1 | sed -e 's/^ (//' -e 's/)$//'
}
PS1_path_value()
{
    [ "$(pwd)" == "$HOME" ] && {
        echo '~'
    } || {
        local path=$(pwd | sed -r "s#^$HOME#~#")
        local route=$(dirname $path | sed -r 's#/(.)[^/]*?#\1#g')
        echo "$route/$(basename $path)" | sed -r 's#/+#/#g'
    }
}

export PS1='$(PS1_exit_code_store)[\[$(PS1_jobs_color)\]$(PS1_jobs_value)\[$PS1_COLOR_RESET\]:\[$(PS1_git_color)\]$(PS1_git_value)\[$PS1_COLOR_RESET\]:\[$(PS1_exit_code_color)\]$(PS1_exit_code_value)\[$PS1_COLOR_RESET\]] \u@\h:$(PS1_path_value)\$ '
