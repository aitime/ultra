# The code for this theme is hheavily influenced by Tyler Reckart's hyperzsh theme: https://github.com/tylerreckart/hyperzsh

# The prompt
PROMPT='%*%{$fg[orange]%} $(_user_host)$(_python_venv)%{$fg[cyan]%}%c $(git_prompt_info)%{$reset_color%}$(_git_time_since_commit)$(git_prompt_status)$(_git_status_short)${_return_status}➜ '

# Prompt with SHA
# PROMPT='$(_user_host)$(_python_venv)%{$fg[cyan]%}%c $(git_prompt_info)%{$reset_color%}$(git_prompt_short_sha)%{$fg[magenta]%}$(_git_time_since_commit)$(git_prompt_status)${_return_status}➜ '

local _return_status="%{$fg[red]%}%(?..⍉ )%{$reset_color%}"

function _user_host() {
  if [[ $(who am i) =~ \([-a-zA-Z0-9\.]+\) ]]; then
    me="%n"
  elif [[ logname != $USER ]]; then
    me="%n"
  fi
  if [[ -n $me ]]; then
    echo "%{$fg_bold[cyan]%}$me%{$reset_color%}:"
  fi
}

# Determine if there is an active Python virtual environment
function _python_venv() {
  if [[ $VIRTUAL_ENV != "" ]]; then
    echo "%{$fg[blue]%}(${VIRTUAL_ENV##*/})%{$reset_color%} "
  fi
}

# Format for git_prompt_long_sha() and git_prompt_short_sha()
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$reset_color%} "

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}✗%{$reset_color%} "
# ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg[red]%}US" # This is not working 

ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[red]%}??"
ZSH_THEME_GIT_PROMPT_CLEAN=" "
# ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[cyan]%}A"
# ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}M"
# ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}D"
# ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}R"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[cyan]%}⎇"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[blue]%}▲"
# TODO: add behinde here

ZSH_THEME_GIT_STATUS_CHANGES_TO_BE_COMMITED="%{$fg[green]%}"
ZSH_THEME_GIT_STATUS_CHANGES_NOT_STAGED_FOR_THE_COMMIT="%{$fg[red]%}"

ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[grey]%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[white]%}"


function _git_time_since_commit2() {
# Only proceed if there is actually a commit.
  if git log -1 > /dev/null 2>&1; then
    echo "%{$ZSH_THEME_GIT_STATUS_CHANGES_TO_BE_COMMITED%}"
  fi
}
#
# Determine changes to be committed and changes not staged.
function _git_status_short() {
# Only proceed if there are changes to be committed or changes not staged for the commit.
# TODO: will proceed if untrancked (??). Should not proceed in this case since you are using 
  if git status --short > /dev/null 2>&1; then
    # Determine if changes to be committed are Modified(M), Added(A), Renamed(R) or Deleted(D).
    if git status --short | grep  -i "^[MARD]" > /dev/null 2>&1; then
      COLOR="$ZSH_THEME_GIT_STATUS_CHANGES_TO_BE_COMMITED"
      if git status --short | grep  -i "^[M]" > /dev/null 2>&1; then
        echo -n "%{$COLOR%}M"
      fi
      if git status --short | grep  -i "^[A]" > /dev/null 2>&1; then
        echo -n "%{$COLOR%}A"
      fi
      if git status --short | grep  -i "^[R]" > /dev/null 2>&1; then
        echo -n "%{$COLOR%}R"
      fi
      if git status --short | grep  -i "^[D]" > /dev/null 2>&1; then
        echo -n "%{$COLOR%}D"
      fi
    fi
    # Determine if changes not staged are Modified(M) or Deleted(D).
    if git status --short | grep  -i "^.[MD]" > /dev/null 2>&1; then
      # Changes not staged
      COLOR="$ZSH_THEME_GIT_STATUS_CHANGES_NOT_STAGED_FOR_THE_COMMIT"
      if git status --short | grep  -i "^.[M]" > /dev/null 2>&1; then
        echo -n "%{$COLOR%}M"
      fi
      if git status --short | grep  -i "^.[D]" > /dev/null 2>&1; then
        echo -n "%{$COLOR%}D"
      fi

    fi
  fi
}

# Determine the time since last commit. If branch is clean,
# use a neutral color, otherwise colors will vary according to time.
function _git_time_since_commit() {
# Only proceed if there is actually a commit.
  if git log -1 > /dev/null 2>&1; then
    # Get the last commit.
    last_commit=$(git log --pretty=format:'%at' -1 2> /dev/null)
    now=$(date +%s)
    seconds_since_last_commit=$((now-last_commit))

    # Totals
    minutes=$((seconds_since_last_commit / 60))
    hours=$((seconds_since_last_commit/3600))

    # Sub-hours and sub-minutes
    days=$((seconds_since_last_commit / 86400))
    sub_hours=$((hours % 24))
    sub_minutes=$((minutes % 60))

    if [ $hours -ge 24 ]; then
      commit_age="${days}d "
    elif [ $minutes -gt 60 ]; then
      commit_age="${sub_hours}h${sub_minutes}m "
    else
      commit_age="${minutes}m "
    fi
    if [[ -n $(git status -s 2> /dev/null) ]]; then
        if [ "$hours" -gt 4 ]; then
            COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG"
        elif [ "$minutes" -gt 30 ]; then
            COLOR="$ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM"
        else
            COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT"
        fi
    else
        COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
    fi


    echo "$COLOR$commit_age%{$reset_color%}"
  fi
}

