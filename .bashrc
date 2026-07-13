#!/usr/bin/env bash
[[ $- == *i* ]] && iatest=1 || iatest=0
#######################################################
# SOURCED ALIAS'S AND SCRIPTS BY zachbrowne.me
#######################################################
if [[ $iatest -gt 0 ]] && command -v fastfetch >/dev/null 2>&1; then
	fastfetch
fi

_bashrc_os=$(uname -s 2>/dev/null || echo unknown)

if [ "$_bashrc_os" = "Darwin" ]; then
	for _bashrc_path_entry in \
		/usr/local/sbin \
		/usr/local/bin \
		/opt/homebrew/sbin \
		/opt/homebrew/bin \
		/opt/homebrew/opt/trash/bin; do
		if [ -d "$_bashrc_path_entry" ]; then
			PATH="$_bashrc_path_entry:$PATH"
		fi
	done
	unset _bashrc_path_entry
	export PATH
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
	# shellcheck source=/dev/null
	. /etc/bashrc
fi

# Enable bash programmable completion features in interactive shells
if [[ $iatest -gt 0 ]]; then
	for _bash_completion in \
		/opt/homebrew/etc/profile.d/bash_completion.sh \
		/usr/local/etc/profile.d/bash_completion.sh \
		/usr/share/bash-completion/bash_completion \
		/etc/bash_completion; do
		if [ -f "$_bash_completion" ]; then
			if [ "$_bashrc_os" = "Darwin" ] && [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
				_bashrc_completion_dir="$HOME/.cache/mybash/bash_completion.d"
				mkdir -p "$_bashrc_completion_dir"
				export BASH_COMPLETION_DIR="$_bashrc_completion_dir"
				export BASH_COMPLETION_COMPAT_DIR="$_bashrc_completion_dir"
			fi
			# shellcheck source=/dev/null
			. "$_bash_completion"
			break
		fi
	done
	unset _bash_completion _bashrc_completion_dir
fi

#######################################################
# EXPORTS
#######################################################

# Disable the bell
if [[ $iatest -gt 0 ]]; then bind "set bell-style none"; fi

# Expand the history size
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T" # add timestamp to history

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
_bashrc_history_sync() {
	history -a
	history -n
}
case ";$PROMPT_COMMAND;" in
*";_bashrc_history_sync;"*) ;;
*) PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}_bashrc_history_sync" ;;
esac

# set up XDG folders
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Seeing as other scripts will use it might as well export it
export MYBASHDIR="$HOME/.local/share/mybash"

# Allow ctrl-S for history navigation (with ctrl-R)
[[ $- == *i* ]] && [ -t 0 ] && stty -ixon

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
if [[ $iatest -gt 0 ]]; then bind "set completion-ignore-case on"; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi

# Set the default editor
if command -v nvim >/dev/null 2>&1; then
	export EDITOR=nvim
	export VISUAL=nvim
	alias vim='nvim'
	alias vi='nvim'
	alias vis='nvim "+set si"'
elif command -v vim >/dev/null 2>&1; then
	export EDITOR=vim
	export VISUAL=vim
else
	export EDITOR=vi
	export VISUAL=vi
fi
command -v pico >/dev/null 2>&1 && alias spico='sudo pico'
command -v nano >/dev/null 2>&1 && alias snano='sudo nano'
sedit() {
	sudo "${SUDO_EDITOR:-${EDITOR:-vi}}" "$@"
}

# To have colors for ls and all grep commands such as grep, egrep and zgrep
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'
#export GREP_OPTIONS='--color=auto' #deprecated

# Color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#######################################################
# MACHINE SPECIFIC ALIAS'S
#######################################################

# Alias's for SSH
# alias SERVERNAME='ssh YOURWEBSITE.com -l USERNAME -p PORTNUMBERHERE'

# Alias's to change the directory
alias web='cd /var/www/html'

# Alias's to mount ISO files
# mount -o loop /home/NAMEOFISO.iso /home/ISOMOUNTDIR/
# umount /home/NAMEOFISO.iso
# (Both commands done as root only.)

#######################################################
# GENERAL ALIAS'S
#######################################################
# To temporarily bypass an alias, we precede the command with a \
# EG: the ls command is aliased, but to use the normal ls command you would type \ls

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alert() {
	local exit_status=$? icon last_command title
	if [ "$exit_status" -eq 0 ]; then
		icon=terminal
		title=Done
	else
		icon=error
		title=Failed
	fi
	last_command=$(history 1 | sed -e 's/^[[:space:]]*[0-9]\+[[:space:]]*//;s/[;&|][[:space:]]*alert$//')

	case $_bashrc_os in
	Darwin)
		if command -v osascript >/dev/null 2>&1; then
			MYBASH_ALERT_MESSAGE=$last_command MYBASH_ALERT_TITLE=$title \
				osascript -e 'display notification (system attribute "MYBASH_ALERT_MESSAGE") with title (system attribute "MYBASH_ALERT_TITLE")'
		else
			printf '%s: %s\n' "$title" "$last_command"
		fi
		;;
	*)
		if command -v notify-send >/dev/null 2>&1; then
			notify-send --urgency=low -i "$icon" "$last_command"
		else
			printf '%s: %s\n' "$title" "$last_command"
		fi
		;;
	esac
}

# Edit this .bashrc file
ebrc() {
	"${EDITOR:-vi}" "$HOME/.bashrc"
}

# Show help for this .bashrc file
hlp() {
	if [ -f "$HOME/.bashrc_help" ]; then
		less "$HOME/.bashrc_help"
	else
		echo "No ~/.bashrc_help file found."
	fi
}

# alias to show the date
alias da='date "+%Y-%m-%d %A %T %Z"'

# Alias's to modified commands
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
if ps auxf >/dev/null 2>&1; then
	alias ps='ps auxf'
else
	alias ps='ps aux'
fi
alias ping='ping -c 10'
alias less='less -R'
alias cls='clear'

if command -v trash-put >/dev/null 2>&1; then
	alias rm='trash-put'
elif command -v trash >/dev/null 2>&1; then
	alias rm='trash -v'
elif command -v gio >/dev/null 2>&1; then
	alias rm='gio trash'
else
	alias rm='rm -i'
fi

command -v multitail >/dev/null 2>&1 && alias multitail='multitail --no-repeat -c'
command -v freshclam >/dev/null 2>&1 && alias freshclam='sudo freshclam'
svi() {
	sudo "${EDITOR:-vi}" "$@"
}
if command -v pacman >/dev/null 2>&1 && command -v yay >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
	alias yayf="yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window=down:75% | xargs -ro yay -S"
	alias yayr="yay -Qq | fzf --multi --preview 'yay -Qi {1}' --preview-window=down:75% | xargs -ro yay -Rns"
fi

if command -v dnf >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
	alias dnff="dnf --quiet list --available | cut -d ' ' -f 1 | grep '\.' | fzf --multi --preview 'dnf info {1}' --preview-window=down:75% | xargs -ro sudo dnf install"
	alias dnfr="dnf --quiet list --installed | cut -d ' ' -f 1 | grep '\.' | fzf --multi --preview 'dnf info {1}' --preview-window=down:75% | xargs -ro sudo dnf remove"
fi

# Change directory aliases
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# cd into the old directory
alias bd='cd "$OLDPWD"'

# Remove a directory and all files
if /bin/rm --recursive --force --verbose --one-file-system -- /tmp/.bashrc-rm-test-noop >/dev/null 2>&1; then
	alias rmd='/bin/rm --recursive --force --verbose --one-file-system --'
else
	alias rmd='/bin/rm -rfv --'
fi

# Alias's for multiple directory listing commands
alias la='ls -Alh' # show hidden files
if ls -d --color=always . >/dev/null 2>&1; then
	alias ls='ls -aFh --color=always' # add colors and file type extensions
else
	alias ls='ls -aFhG' # add colors and file type extensions on BSD/macOS
fi
alias lx='ls -lXBh'               # sort by extension
alias lk='ls -lSrh'               # sort by size
alias lc='ls -ltcrh'              # sort by change time
alias lu='ls -lturh'              # sort by access time
alias lr='ls -lRh'                # recursive ls
alias lt='ls -ltrh'               # sort by date
alias lm='ls -alh |more'          # pipe through 'more'
alias lw='ls -xAh'                # wide listing format
alias ll='ls -Fls'                # long listing format
alias labc='ls -lap'              # alphabetical sort
alias lf="ls -l | grep -Ev '^d'"  # files only
alias ldir="ls -l | grep -E '^d'" # directories only
alias lla='ls -Al'                # List and Hidden Files
alias las='ls -A'                 # Hidden Files
alias lls='ls -l'                 # List

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Search command line history
alias h="history | grep "

# Search running processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# Search files in the current folder
alias f="find . | grep "

# Count all files (recursively) in the current folder
countfiles() {
	local t
	for t in files links directories; do
		echo "$(find . -type "${t:0:1}" | wc -l)" "$t"
	done 2>/dev/null
}

# To see if a command is aliased, a file, or a built-in command
alias checkcommand="type -t"

# Show open ports
if command -v ss >/dev/null 2>&1; then
	alias openports='ss -tulpen'
elif command -v netstat >/dev/null 2>&1; then
	if netstat -nape --inet >/dev/null 2>&1; then
		alias openports='netstat -nape --inet'
	else
		alias openports='netstat -anv'
	fi
fi

# Alias's for safe and forced reboots
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
if du -h --max-depth=1 . >/dev/null 2>&1; then
	alias folders='du -h --max-depth=1'
else
	alias folders='du -hd 1'
fi
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
command -v tree >/dev/null 2>&1 && alias tree='tree -CAhF --dirsfirst'
command -v tree >/dev/null 2>&1 && alias treed='tree -CAFd'
if df -hT . >/dev/null 2>&1; then
	alias mountedinfo='df -hT'
else
	alias mountedinfo='df -h'
fi

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Show all logs in /var/log
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

# SHA1
alias sha1='openssl sha1'

clickpaste() {
	sleep "${1:-3}"
	if command -v wl-paste >/dev/null 2>&1 && command -v wtype >/dev/null 2>&1; then
		wl-paste | wtype -
	elif command -v xclip >/dev/null 2>&1 && command -v xdotool >/dev/null 2>&1; then
		xdotool type "$(xclip -o -selection clipboard)"
	else
		echo "clickpaste requires wl-paste+wtype on Wayland or xclip+xdotool on X11."
		return 1
	fi
}

# KITTY - alias to be able to use kitty features when connecting to remote servers(e.g use tmux on remote server)

command -v kitty >/dev/null 2>&1 && alias kssh="kitty +kitten ssh"

# alias to cleanup unused docker containers, images, networks, and volumes

docker-clean() {
	if ! command -v docker >/dev/null 2>&1; then
		echo "docker is not installed."
		return 1
	fi
	docker container prune -f
	docker image prune -f
	docker network prune -f
	docker volume prune -f
}

# alias to fix ~/.ssh permissions
alias sshperms='cd ~ && chmod 600 ~/.ssh/* && chmod 700 ~/.ssh && chmod 644 ~/.ssh/*.pub'

#######################################################
# SPECIAL FUNCTIONS
#######################################################
# Extracts any archive(s) (if unp isn't installed)
extract() {
	for archive in "$@"; do
		if [ -f "$archive" ]; then
			case $archive in
			*.tar.bz2) tar xvjf "$archive" ;;
			*.tar.gz) tar xvzf "$archive" ;;
			*.bz2) bunzip2 "$archive" ;;
			*.rar) rar x "$archive" ;;
			*.gz) gunzip "$archive" ;;
			*.tar) tar xvf "$archive" ;;
			*.tbz2) tar xvjf "$archive" ;;
			*.tgz) tar xvzf "$archive" ;;
			*.zip) unzip "$archive" ;;
			*.Z) uncompress "$archive" ;;
			*.7z) 7z x "$archive" ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

# Searches for text in all files in the current folder
ftext() {
	# -i case-insensitive
	# -I ignore binary files
	# -H causes filename to be printed
	# -r recursive search
	# -n causes line number to be printed
	# optional: -F treat search term as a literal, not a regular expression
	# optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
	grep -iIHrn --color=always "$1" . | less -r
}

_bashrc_file_size() {
	if stat -c '%s' "$1" >/dev/null 2>&1; then
		stat -c '%s' "$1"
	else
		stat -f '%z' "$1"
	fi
}

# Copy file with a progress bar
cpp() {
	if [ "$#" -ne 2 ]; then
		echo "Usage: cpp SOURCE DESTINATION"
		return 2
	fi
	if ! command -v strace >/dev/null 2>&1; then
		echo "cpp requires strace."
		return 1
	fi
	strace -q -ewrite cp -- "$1" "$2" 2>&1 |
		awk '{
		count += $NF
		if (count % 10 == 0 && total_size > 0) {
			percent = int(count / total_size * 100)
			if (percent > 100) percent = 100
			printf "%3d%% [", percent
			for (i=0;i<=percent;i++)
				printf "="
			printf ">"
			for (i=percent;i<100;i++)
				printf " "
			printf "]\r"
		}
	}
	END { print "" }' total_size="$(_bashrc_file_size "$1")" count=0
}

# Copy and go to the directory
cpg() {
	if [ -d "$2" ]; then
		cp "$1" "$2" && cd "$2" || return
	else
		cp "$1" "$2"
	fi
}

# Move and go to the directory
mvg() {
	if [ -d "$2" ]; then
		mv "$1" "$2" && cd "$2" || return
	else
		mv "$1" "$2"
	fi
}

# Create and go to the directory
mkdirg() {
	mkdir -p "$1" && cd "$1" || return
}

# Goes up a specified number of directories  (i.e. up 4)
up() {
	local d="" limit i
	limit=${1:-1}
	if ! [[ $limit =~ ^[0-9]+$ ]]; then
		echo "Usage: up [number]"
		return 2
	fi
	for ((i = 1; i <= limit; i++)); do
		d=$d/..
	done
	d=$(echo "$d" | sed 's/^\///')
	if [ -z "$d" ]; then
		d=..
	fi
	cd "$d" || return
}

# Automatically do an ls after each cd, z, or zoxide
cd() {
	if [ -n "$1" ]; then
		builtin cd "$@" && ls
	else
		builtin cd ~ && ls
	fi
}

# Returns the last 2 fields of the working directory
pwdtail() {
	pwd | awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

# Show the current distribution
distribution() {
	local dtype="unknown" # Default to unknown

	case $_bashrc_os in
	Darwin)
		dtype="macos"
		;;
	Linux)
		# Use /etc/os-release for modern distro identification
		if [ -r /etc/os-release ]; then
			# shellcheck source=/dev/null
			source /etc/os-release
			case $ID in
			fedora | rhel | centos)
				dtype="redhat"
				;;
			sles | opensuse*)
				dtype="suse"
				;;
			ubuntu | debian)
				dtype="debian"
				;;
			gentoo)
				dtype="gentoo"
				;;
			arch | manjaro | cachyos)
				dtype="arch"
				;;
			slackware)
				dtype="slackware"
				;;
			*)
				if [ -n "$ID_LIKE" ]; then
					case $ID_LIKE in
					*fedora* | *rhel* | *centos*)
						dtype="redhat"
						;;
					*sles* | *opensuse*)
						dtype="suse"
						;;
					*ubuntu* | *debian*)
						dtype="debian"
						;;
					*gentoo*)
						dtype="gentoo"
						;;
					*arch*)
						dtype="arch"
						;;
					*slackware*)
						dtype="slackware"
						;;
					esac
				fi
				;;
			esac
		fi
		;;
	esac

	echo "$dtype"
}

# Show the current version of the operating system
ver() {
	local dtype
	dtype=$(distribution)

	case $dtype in
	"macos")
		sw_vers
		uname -a
		;;
	"redhat")
		if [ -s /etc/redhat-release ]; then
			cat /etc/redhat-release
		else
			cat /etc/issue
		fi
		uname -a
		;;
	"suse")
		cat /etc/SuSE-release
		;;
	"debian")
		lsb_release -a
		;;
	"gentoo")
		cat /etc/gentoo-release
		;;
	"arch")
		cat /etc/os-release
		;;
	"slackware")
		cat /etc/slackware-version
		;;
	*)
		if [ -s /etc/issue ]; then
			cat /etc/issue
		else
			echo "Error: Unknown distribution"
			return 1
		fi
		;;
	esac
}

# Automatically install the needed support files for this .bashrc file
install_bashrc_support() {
	local dtype
	dtype=$(distribution)

	case $dtype in
	"macos")
		if command -v brew >/dev/null 2>&1; then
			brew install multitail tree zoxide trash fzf bash-completion fastfetch
		else
			echo "Homebrew is required to install support packages on macOS."
			return 1
		fi
		;;
	"redhat")
		if command -v dnf >/dev/null 2>&1; then
			sudo dnf install multitail tree zoxide trash-cli fzf bash-completion fastfetch
		else
			sudo yum install multitail tree zoxide trash-cli fzf bash-completion fastfetch
		fi
		;;
	"suse")
		sudo zypper install multitail tree zoxide trash-cli fzf bash-completion fastfetch
		;;
	"debian")
		sudo apt-get update
		sudo apt-get install multitail tree zoxide trash-cli fzf bash-completion fastfetch
		;;
	"arch")
		if command -v paru >/dev/null 2>&1; then
			paru -S --needed multitail tree zoxide trash-cli fzf bash-completion fastfetch
		elif command -v yay >/dev/null 2>&1; then
			yay -S --needed multitail tree zoxide trash-cli fzf bash-completion fastfetch
		elif command -v pacman >/dev/null 2>&1; then
			sudo pacman -S --needed multitail tree zoxide trash-cli fzf bash-completion fastfetch
		else
			printf '%s\n' "No supported Arch package installer (paru, yay, or pacman) found." >&2
			return 1
		fi
		;;
	"slackware")
		echo "No install support for Slackware"
		;;
	*)
		echo "Unknown distribution"
		;;
	esac
}

# IP address lookup
alias whatismyip="whatsmyip"
function whatsmyip() {
	# Internal IP Lookup.
	echo -n "Internal IP: "
	if command -v ip >/dev/null 2>&1; then
		ip -o -4 route get 1.1.1.1 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i == "src") {print $(i+1); exit}}'
	elif command -v ifconfig >/dev/null 2>&1; then
		ifconfig | awk '/inet / && $2 != "127.0.0.1" {print $2; exit}'
	else
		echo "unknown"
	fi

	# External IP Lookup
	echo -n "External IP: "
	if command -v curl >/dev/null 2>&1; then
		curl -4fsS --max-time 5 https://ifconfig.me || printf '%s' "unknown"
		echo
	else
		echo "curl not installed"
	fi
}

# View Apache logs
apachelog() {
	if [ -f /etc/httpd/conf/httpd.conf ]; then
		cd /var/log/httpd && ls -xAh || return
		if command -v multitail >/dev/null 2>&1; then
			multitail --no-repeat -c -s 2 /var/log/httpd/*_log
		else
			tail -f /var/log/httpd/*_log
		fi
	elif [ -d /var/log/apache2 ]; then
		cd /var/log/apache2 && ls -xAh || return
		if command -v multitail >/dev/null 2>&1; then
			multitail --no-repeat -c -s 2 /var/log/apache2/*.log
		else
			tail -f /var/log/apache2/*.log
		fi
	else
		echo "Error: Apache log directory could not be found."
	fi
}

find_config_file() {
	local name=$1
	if command -v locate >/dev/null 2>&1; then
		sudo updatedb && locate "$name"
	else
		echo "locate is not installed."
	fi
}

apacheconfig() {
	if [ -f /etc/httpd/conf/httpd.conf ]; then
		sedit /etc/httpd/conf/httpd.conf
	elif [ -f /etc/apache2/apache2.conf ]; then
		sedit /etc/apache2/apache2.conf
	else
		echo "Error: Apache config file could not be found."
		echo "Searching for possible locations:"
		find_config_file httpd.conf
		find_config_file apache2.conf
	fi
}

# Edit the PHP configuration file
phpconfig() {
	if [ -f /etc/php.ini ]; then
		sedit /etc/php.ini
	elif [ -f /etc/php/php.ini ]; then
		sedit /etc/php/php.ini
	elif [ -f /etc/php5/php.ini ]; then
		sedit /etc/php5/php.ini
	elif [ -f /usr/bin/php5/bin/php.ini ]; then
		sedit /usr/bin/php5/bin/php.ini
	elif [ -f /etc/php5/apache2/php.ini ]; then
		sedit /etc/php5/apache2/php.ini
	else
		echo "Error: php.ini file could not be found."
		echo "Searching for possible locations:"
		find_config_file php.ini
	fi
}

# Edit the MySQL configuration file
mysqlconfig() {
	if [ -f /etc/my.cnf ]; then
		sedit /etc/my.cnf
	elif [ -f /etc/mysql/my.cnf ]; then
		sedit /etc/mysql/my.cnf
	elif [ -f /usr/local/etc/my.cnf ]; then
		sedit /usr/local/etc/my.cnf
	elif [ -f /usr/bin/mysql/my.cnf ]; then
		sedit /usr/bin/mysql/my.cnf
	elif [ -f "$HOME/my.cnf" ]; then
		sedit "$HOME/my.cnf"
	elif [ -f "$HOME/.my.cnf" ]; then
		sedit "$HOME/.my.cnf"
	else
		echo "Error: my.cnf file could not be found."
		echo "Searching for possible locations:"
		find_config_file my.cnf
	fi
}

# Trim leading and trailing spaces (for scripts)
trim() {
	local var=$*
	var="${var#"${var%%[![:space:]]*}"}" # remove leading whitespace characters
	var="${var%"${var##*[![:space:]]}"}" # remove trailing whitespace characters
	echo -n "$var"
}
# GitHub Titus Additions

gcom() {
	if [ -z "$1" ]; then
		echo "Usage: gcom \"commit message\""
		return 2
	fi
	git add .
	git commit -m "$1"
}
lazyg() {
	if [ -z "$1" ]; then
		echo "Usage: lazyg \"commit message\""
		return 2
	fi
	git add .
	git commit -m "$1"
	git push
}

#######################################################
# Set the ultimate amazing command prompt
#######################################################

if command -v systemctl >/dev/null 2>&1; then
	alias hug="systemctl --user restart hugo"
	alias lanm="systemctl --user restart lan-mouse"
fi

# Check if the shell is interactive
if [[ $- == *i* ]] && command -v zoxide >/dev/null 2>&1; then
	# Bind Ctrl+f to insert 'zi' followed by a newline
	bind '"\C-f":"zi\n"'
fi

path_add_first() {
	local path_entry
	for path_entry in "$@"; do
		if [ -d "$path_entry" ]; then
			case ":$PATH:" in
			*":$path_entry:"*) ;;
			*) PATH="$path_entry:$PATH" ;;
			esac
		fi
	done
}

path_add_first \
	"$HOME/.local/bin" \
	"/home/linuxbrew/.linuxbrew/bin" \
	"/home/linuxbrew/.linuxbrew/sbin" \
	"$HOME/.linuxbrew/bin" \
	"$HOME/.linuxbrew/sbin" \
	"$HOME/.local/share/pnpm" \
	"$HOME/.npm-global/bin" \
	"$HOME/.yarn/bin" \
	"$HOME/.yarn/global/node_modules/.bin" \
	"$HOME/go/bin" \
	"$HOME/.deno/bin" \
	"$HOME/.cargo/bin" \
	"/var/lib/flatpak/exports/bin" \
	"$HOME/.local/share/flatpak/exports/bin"

if [ "$_bashrc_os" = "Darwin" ]; then
	path_add_first \
		"/opt/homebrew/opt/trash/bin" \
		"/opt/homebrew/bin" \
		"/opt/homebrew/sbin" \
		"/usr/local/bin" \
		"/usr/local/sbin"
fi

export PATH

if [[ $- == *i* ]] && command -v starship >/dev/null 2>&1; then
	eval "$(starship init bash)"
fi
if [[ $- == *i* ]] && command -v zoxide >/dev/null 2>&1; then
	eval "$(zoxide init bash)"
fi
