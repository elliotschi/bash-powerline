#!/usr/bin/env bash

__powerline() {
  # Unicode symbols
  readonly GIT_BRANCH_SYMBOL='⑂ '
  readonly GIT_BRANCH_CHANGED_SYMBOL='+'
  readonly GIT_NEED_PUSH_SYMBOL='⇡'
  readonly GIT_NEED_PULL_SYMBOL='⇣'
  readonly PYTHON_SYMBOL='🐍'

  readonly FG_BASE02="\[$(tput setaf 0)\]"
  readonly FG_BASE3="\[$(tput setaf 15)\]"

  readonly BG_WHITE="\[$(tput setab 15)\]"
  readonly BG_LUNA_GREEN="\[$(tput setab 23)\]"
  readonly BG_GRAY="\[$(tput setab 7)\]"

  readonly DIM="\[$(tput dim)\]"
  readonly REVERSE="\[$(tput rev)\]"
  readonly RESET="\[$(tput sgr0)\]"
  readonly BOLD="\[$(tput bold)\]"

  __git_info() {
    # Check to see whether Git is installed
    [ -x "$(which git)" ] || return

    # Force Git output to English
    local git_eng="env LANG=C git"
    # Get the current branch name or short SHA1 hash for detached head
    local branch="$($git_eng symbolic-ref --short HEAD 2>/dev/null || $git_eng describe --tags --always 2>/dev/null)"
    # Check for a Git branch
    [ -n "$branch" ] || return

    local marks

    # Show a symbol if the current Git branch has been modified
    [ -n "$($git_eng status --porcelain)" ] && marks+=" $GIT_BRANCH_CHANGED_SYMBOL"

    # Show the difference in commits between the local branch and the remote branch
    local stat="$($git_eng status --porcelain --branch | grep '^##' | grep -o '\[.\+\]$')"
    local aheadN="$(echo $stat | grep -o 'ahead [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
    local behindN="$(echo $stat | grep -o 'behind [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
    [ -n "$aheadN" ] && marks+=" $GIT_NEED_PUSH_SYMBOL$aheadN"
    [ -n "$behindN" ] && marks+=" $GIT_NEED_PULL_SYMBOL$behindN"

    # Print the git branch segment without a trailing newline
    printf " $GIT_BRANCH_SYMBOL$branch$marks "
  }

  __virtualenv() {
    if [ -z "${VIRTUAL_ENV}" ] ; then
        return
    else
        local virtualenv="$(basename $VIRTUAL_ENV)"
        printf " $PYTHON_SYMBOL $virtualenv "
    fi
  }

  ps1() {
    PS1="$BG_WHITE$FG_BASE02 \w $RESET"
    PS1+="$BG_GRAY$FG_BASE02$(__virtualenv)$RESET"
    PS1+="$BG_LUNA_GREEN$FG_BASE3$(__git_info)$RESET\n└─▪ "
  }

  # Enable the ability to open new tabs in the current working directory
  PROMPT_COMMAND="ps1 ; $PROMPT_COMMAND"
}

__powerline
unset __powerline
