

# Path Customization
if [ -d "$HOME/.bin" ]; then
  PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
# Sourcing custom settings
if [[ -r ~/.bash-default ]]; then
  source ~/.bash-default
else
  echo "Error: Can't find the bash-default script"
fi

# Autojump setup
if [ -f "/usr/share/autojump/autojump.sh" ]; then
  . /usr/share/autojump/autojump.sh
elif [ -f "/usr/share/autojump/autojump.bash" ]; then
  . /usr/share/autojump/autojump.bash
else
  echo "Error: Can't find the autojump script"
fi


  PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/Applications" ]; then
  PATH="$HOME/Applications:$PATH"
fi

if [ -d "/var/lib/flatpak/exports/bin/" ]; then
  PATH="/var/lib/flatpak/exports/bin/:$PATH"
fi

if [ -d "$HOME/.spicetify" ]; then
  PATH="$HOME/.spicetify:$PATH"
fi

if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
  PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
fi

# Cleanup of home dicrictory
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export DOT_FOLLDER="$HOME/.dot-follders"
export ANDROID_HOME="$DOT_FOLLDER"/android
export WINEPREFIX="$DOT_FOLLDER"/wine
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$DOT_FOLLDER"/java
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
export XDG_SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"

# Terminal Settings
export TERM="xterm-256color"
export EDITOR=nano

# Aliases for File and Directory Operations
alias ll='ls -all --color=auto -h'
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias cls='clear && colorscript -r'
alias clear='/bin/clear && colorscript -r'
alias multitail='multitail --no-repeat -c'
alias freshclam='sudo freshclam'

# Text Editors
alias vi='nvim -u ~/Documents/GitHub/dot-files/vim-nano/nano.vim'
alias svi='sudo vi'
alias vis='nvim -u ~/Documents/GitHub/dot-files/vim-nano/nano.vim "+set si"'
alias vim='nvim -u ~/Documents/GitHub/dot-files/vim-nano/nano.vim'

# Archive Aliases
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# History Aliases
alias h='history'
alias hs='history | grep'
alias hsi='history | grep -i'

# Clipboard Operations
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'
alias copydir='pwd | tr -d "\r\n" | pbcopy'

# Speed Test
# alias speedtest='speedtest-cli --secure'

# GNOME Text Editor
alias gedit='gnome-text-editor'
alias sudo-gedit='sudo gnome-text-editor'

# Neofetch Fix
alias neofetch-big='/bin/neofetch --ascii ~/.config/neofetch/cat.txt | lolcat'
alias neofetch-small='/bin/neofetch --ascii ~/.config/neofetch/cat2.txt | lolcat'
alias neofetch-big2='/bin/neofetch --ascii ~/.config/neofetch/steaven.txt | lolcat'
alias neofetch-small2='/bin/neofetch --ascii ~/.config/neofetch/steaven2.txt | lolcat'
alias neofetch-art='/bin/neofetch --caca ~/.config/neofetch/Toad_Artwork_-_Super_Mario_3D_World.png'
alias neofetch-image='/bin/neofetch --sixel ~/.config/neofetch/Toad_Artwork_-_Super_Mario_3D_World.png | lolcat'

# Antivirus Update
alias antivirus-update='freshclam'

# looking-glass
alias looking-glass-opengl='looking-glass-client -m 97 -g OpenGL'
alias looking-glass-egl='looking-glass-client -m 97 -g EGL'
# supergxctl 
alias gpulinux='supergfxctl -m Hybrid && logout'
alias gpudis='supergfxctl -m Integrated && logout'
alias gpuwindows='supergfxctl -m Vfio'

# yt-dlp Aliases
alias yta-aac="yt-dlp --extract-audio --audio-format aac --embed-metadata --embed-thumbnail "
alias yta-best="yt-dlp --extract-audio --audio-format best --embed-metadata --embed-thumbnail "
alias yta-flac="yt-dlp --extract-audio --audio-format flac --embed-metadata --embed-thumbnail "
alias yta-m4a="yt-dlp --extract-audio --audio-format m4a --embed-metadata --embed-thumbnail "
alias yta-mp3="yt-dlp --extract-audio --audio-format mp3 --embed-metadata --embed-thumbnail "
alias yta-opus="yt-dlp --extract-audio --audio-format opus --embed-metadata --embed-thumbnail "
alias yta-vorbis="yt-dlp --extract-audio --audio-format vorbis --embed-metadata --embed-thumbnail "
alias yta-wav="yt-dlp --extract-audio --audio-format wav --embed-metadata --embed-thumbnail "
alias ytv-best="yt-dlp -f bestvideo+bestaudio --embed-metadata --embed-thumbnail --embed-chapters "
alias ytv-best-mp4='yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --embed-metadata --embed-thumbnail --embed-chapters'
alias ytv-best-mp4-1080p='yt-dlp -f "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --embed-metadata --embed-thumbnail --embed-chapters'

# Play video files in current dir by type
alias playavi='vlc *.avi'
alias playmov='vlc *.mov'
alias playmp4='vlc *.mp4'

# human readable sizes
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
# udo mastake fix
alias udo='sudo'

# Colorize Grep Output
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Display Open Ports
alias openports='netstat -nape --inet'

# Reboot Aliases
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'
# GIT Customizations
gitpush() {
    git add .
    git commit -m "$*"
    git pull
    git push
}

gitupdate() {
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/github
    ssh -T git@github.com
}

git-push() {
    git add .
    git commit -m "$1"
    git push
}

gitcommit() {
    git add .
    git commit -m "$1"
}

# Aliases for GIT
alias gp='gitpush'
alias gu='gitupdate'
alias gpush='git-push'
alias gcommit='gitcommit'

# Directory and Navigation Aliases
cdgit() {
    z ~/Documents/GitHub/"$1"
}

alias cdgitf='z ~/Documents/GitHub'
alias cddot='z ~/Documents/GitHub/dot-files'

# Change directory aliases
alias web='z /var/www/html'
alias home='z ~'

# cd into the old directory
alias bd='cd "$OLDPWD"'

# Search files in the current folder
alias f="find . | grep "

# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# To see if a command is aliased, a file, or a built-in command
alias checkcommand="type -t"


# Disk Space and Usage
alias diskspace="du -S -h | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# XLS Clients Fix
alias xwayland-apps='xlsclients'
alias watch-xwayland-apps='watch xlsclients'

# Pacman and Yay Aliases
alias pacman='sudo pacman'                       # Fixs pacman when its not runed as sudo
alias pacsyu='sudo pacman -Syu'                  # update only standard pkgs
alias pacsyyu='sudo pacman -Syyu'                # Refresh pkglist & update standard pkgs
alias yaysua='yay -Sua --noconfirm'              # update only AUR pkgs (yay)
alias yaysyu='yay -Syu --noconfirm'              # update standard pkgs and AUR pkgs (yay)
alias parsua='paru -Sua --noconfirm'             # update only AUR pkgs (paru)
alias parsyu='paru -Syu --noconfirm'             # update standard pkgs and AUR pkgs (paru)
alias unlock='sudo rm /var/lib/pacman/db.lck'    # remove pacman lock
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)' # remove orphaned packages

# Flatpak Aliases
alias theme-flatpak='~/Documents/GitHub/dot-files/flatpak/stylepak install-system'
alias flatpak-update-font-cache='~/Documents/GitHub/dot-files/flatpak/flatpak-font.sh'

# SSH and System Update Aliases
updatearch="yay -Syu --noconfirm --needed && sudo flatpak update -y"
updatefedora="sudo dnf update -y && sudo flatpak update -y"
updatedebian="sudo nala upgrade -y && sudo flatpak update -y"
alias update-all="ssh -t omar-pc '${updatearch}' && ssh -t omar-gaminglaptop '${updatearch}'"
dotfiles='cd ~/Documents/GitHub/dot-files && git pull && cd'
alias update-dotfiles="ssh -t omar-pc '${dotfiles}' && ssh -t omar-gaminglaptop '${dotfiles}'"

# Cache Fix
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Konsole Fix
bash_in_konsole() {
  local IFS
  konsole -e bash --rcfile <(printf '. ~/.bashrc; set -m; %s\n' "$*")
}

# Batcat
alias cat='batcat'

# FC-list Customization
# custom fc-list
# - sort list
# - add color
# - format table output
function fc-list () {
  # if calling with arguments, call the original command
  if [[ "$#" -gt 0 ]]; then
    command fc-list "$@"
    return $?
  fi

  # prepend header
  {
    echo "FILE:FAMILY:STYLE"
    command fc-list "$@" 
  } | \
  sort | \
  # replace weird space after colon after file name
  sed -E 's/: /:/g' | \

  # pretty print the file path, and other field fixes
  command awk -F: '
  BEGIN {
    green="\033[32m";
    white="\033[0m";
    bold="\033[1m";
    reset="\033[0m";
  }
  function pretty_print_directory(path) {
    last_slash = match(path, /\/[^\/]+$/);
    directory = substr(path, 1, last_slash);
    file = substr(path, last_slash + 1);

    # print the directory in green, and the file in white and bold
    return green directory white bold file reset;
  }
  {
    # skip header row, but make every field bold
    if (NR == 1) {
      OFS=":";
      for (i = 1; i <= NF; i++) {
        $i = bold $i reset;
      }
      print $0;
      next;
    }
    OFS=":";
    $1 = pretty_print_directory($1);

    # remove "style=" prefix from 3rd field
    sub(/^style=/, "", $3);

    # if third field (styles) consist of 3+ comma separated values, print only
    # the first
    # two followed by "..."
    if (match($3, /,[^,]+,[^,]+$/)) {
      $3 = gensub(/^([^,]+,[^,]+).*/, "\\1, ...", 1, $3);
    }

    print $0;
  }' | \
  column -t -s: | \
  less -S
}

alias fonts="fc-list"

# fc-list-families
# - list only the font families in the system
function fc-list-families () {
  command fc-list : family | sort
}
alias font-families="fc-list-families"

function ix() {
  local file="$1"
  curl -F "f:1=@$file" ix.io
}

# Check for Color Script
if command -v colorscript &> /dev/null; then
  colorscript -r
else
  echo "Can't find the Shell Color script"
fi
stv-install() {
    if [[ $1 == "-v" ]]; then
        x=$@
        if [[ $2 == "arch" ]]; then
            x=${x/-v arch/}
            distrobox-enter -H arch -- sudo pacman $x
        elif [[ $2 == "ubuntu" ]]; then
            x=${x/-v ubuntu/}
            distrobox-enter -H ubuntu -- sudo apt $x
        elif [[ $2 == "fedora" ]]; then
            x=${x/-v fedora/}
            distrobox-enter -H fedora -- sudo dnf $x
        elif [[ $2 == "opensuse" ]]; then
            x=${x/-v opensuse/}
            distrobox-enter -H opensuse -- sudo zypper $x
        else
            echo "Command Not Found"
        fi
    fi
}

stv() {
    if [[ $1 == "-v" ]]; then
        x=$@
        if [[ $2 == "arch" ]]; then
            x=${x/-v arch/}
            distrobox-enter -H arch $x
        elif [[ $2 == "ubuntu" ]]; then
            x=${x/-v ubuntu/}
            distrobox-enter -H ubuntu -- $x
        elif [[ $2 == "fedora" ]]; then
            x=${x/-v fedora/}
            distrobox-enter -H fedora -- $x
        elif [[ $2 == "opensuse" ]]; then
            x=${x/-v opensuse/}
            distrobox-enter -H opensuse -- $x
        else
            echo "Command Not Found"
        fi
    fi
}
function ix {
  curl -F "f:1=@$1" ix.io
}

function 0x0 {
  curl -F "file=@$1" https://0x0.st
}

# Audio / Sound (I got sick of searching for it in my discord server at #🔥linux-tips)
alias combine-audio='pactl load-module module-combine-sink'
alias uncombine-audio='pactl unload-module module-combine-sink'

# History settings
HISTFILE=~/.bash-history
HISTSIZE=SAVEHIST=10000

# Starship prompt configuration based on Linux distribution
if [ -e /etc/os-release ]; then
    linux_distro=$(awk -F= '/^ID=/{gsub(/"/, "", $2); print tolower($2)}' /etc/os-release)
else
    # fallback to your previous method if /etc/os-release is not available
    linux_distro=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
fi

case $linux_distro in
  arch)
    export STARSHIP_CONFIG=~/.config/starship/starship-arch.toml
    ;;
  fedora)
    export STARSHIP_CONFIG=~/.config/starship/starship-fedora.toml
    ;;
  debian)
    export STARSHIP_CONFIG=~/.config/starship/starship-debian.toml
    ;;
  ubuntu)
    export STARSHIP_CONFIG=~/.config/starship/starship-ubuntu.toml
    ;;
  opensuse-tumbleweed)
    export STARSHIP_CONFIG=~/.config/starship/starship-opensuse.toml
    ;;
  *)
    export STARSHIP_CONFIG=~/.config/starship/starship.toml
    ;;
esac

# Check if Starship configuration is readable before initializing
if ! [[ -r "$STARSHIP_CONFIG" ]]; then
    echo "Error: The configuration file $STARSHIP_CONFIG is not readable!"
fi

eval "$(starship init bash)"
#eval "$(atuin init bash)"
eval "$(zoxide init bash)"

