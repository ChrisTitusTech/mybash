# Alias's to modified commands
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'

# Some more useful aliases.
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias c='clear'
alias f='find'
alias h='history'
alias j="jobs -l"
alias l="ls -lrth "
alias pu="pushd"
alias po="popd"
alias py="python3"

# Remove a directory and all files
alias rmd='rm --recursive --force --verbose'

# Aliases for safe and forced reboots
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

# Use for sourcing a bash script
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias update="sudo apt update && sudo apt install"
alias venv="source venv/bin/activate"
alias dvenv="deactivate"

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Aliases git
alias g='git'
alias gst='git status'
alias gcl='git clone --recurse-submodules'
alias gpl='git pull'
alias gdf='git diff'
alias gdfs='git diff --staged'
alias gup='git fetch && git rebase'
alias gpsh='git push'
alias gcm='git commit -v -m'
alias gcma='git commit -v -a -m'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcom='git checkout main'
alias gbr='git branch'
alias gbra='git branch -a'
alias gcount='git shortlog -sn'
alias gcp='git cherry-pick'
alias glg="git log --stat --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative --max-count=10"
alias glgg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative --max-count=10"
alias gadd='git add'
alias gmrg='git merge'
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias grs='git restore'
alias grsa='git restore .'
alias gsbm='git submodule update --init --remote --force --recursive'
alias gsa="!sh -c 'git stash apply stash@{$1}' -"
alias gsd="!sh -c 'git stash drop stash@{$1}' -"
alias gsl="stash list"
alias gss="stash save"

# Alias's for flatpak apps
alias code="flatpak run com.visualstudio.code"
