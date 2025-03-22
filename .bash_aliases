# Alias's to modified commands
alias cat="bat"
alias cp="cp -i"
alias mv="mv -i"
alias rm="trash -v"
alias mkdir="mkdir -p"
alias ps="ps auxf"
alias ping="ping -c 5"
alias less="less -R"

# More useful aliases.
alias c="clear"
alias cpd="cp -ri"
alias egrep="egrep --color=auto"
alias f="find . | grep"
alias grep="grep --color=auto"
alias hist="history"
alias h="history | grep"
alias j="jobs -l"
alias mvd="mv -ri"
alias f="find . | grep "
alias p="ps aux | grep "
alias pu="pushd"
alias po="popd"
alias rmd="rm --recursive --force --verbose"

# Alias's for multiple directory listing commands
alias ls="exa"
alias la="exa -a -l --icons --git -s=type"  # show hidden files
alias l="exa -l --icons --git -s=type"

# Alias chmod commands
alias mx="chmod a+x"

# List serial devices
alias lser="l /dev/serial/by-id"

# Reboot aliases
alias reboot="systemctl reboot"
alias shutdown="systemctl poweroff"

# Alias's to show disk space and space used in a folder
alias tree="tree -CAhF --dirsfirst"
alias treed="tree -CAFd"

# Use for going back to previous directories
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# cd into the old directory
alias bd="cd '$OLDPWD'"

# Python aliases
alias py="python3"
alias venv="source venv/bin/activate"
alias dvenv="deactivate"

# Tmux aliases
alias tm="tmux"
alias tma="tmux attach"
alias tmat="tmux attach -t"
alias tmks="tmux kill-session -a"
alias tml="tmux ls"
alias tmn="tmux new-session"
alias tmns="tmux new-session -s"

# Git aliases
alias g="git"
alias gst="git status"
alias gcl="git clone --recurse-submodules"
alias gpl="git pull"
alias gdf="git diff"
alias gdfs="git diff --staged"
alias gup="git fetch && git rebase"
alias gpsh="git push"
alias gcm="git commit -v"
alias gcma="git commit -v -a"
alias gco="git checkout"
alias gcob="git checkout -b"
alias gcom="git checkout main"
alias gbr="git branch"
alias gbra="git branch -a"
alias gcount="git shortlog -sn"
alias gcp="git cherry-pick"
alias glg="git log --stat --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative --max-count=10"
alias glgg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative --max-count=10"
alias gadd="git add"
alias gmrg="git merge"
alias gmrgm="git pull origin main"
alias grb="git rebase -i"
alias grs="git reset"
alias grsh="git reset --hard"
alias grst="git restore"
alias grsts="git restore -s"
alias grsta="git restore ."
alias gsbm="git submodule update --init --remote --force --recursive"
gsa() {
    git stash apply stash@{$1}
}
gsd() {
    git stash drop stash@{$1}
}
alias gsl="stash list"
alias gss="stash save"
alias gsw="git switch"
alias gswm="git switch main"
alias gswc="git switch -c"
