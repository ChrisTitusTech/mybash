#
# ~/.bashrc
#

export PATH=$PATH:"$HOME/.local/bin:$HOME/.cargo/bin:/var/lib/flatpak/exports/bin:/.local/share/flatpak/exports/bin"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

PS1='[\u@\h \W]\$ '

# Useful Functions

# Function to combine cd and ls command
cl() { 
    cd "$1" && ls -lrth; 
}

# Copy and go to the directory
cpg() {
	if [ -d "$2" ]; then
		cp "$1" "$2" && cd "$2"
	else
		cp "$1" "$2"
	fi
}

# Move and go to the directory
mvg() {
	if [ -d "$2" ]; then
		mv "$1" "$2" && cd "$2"
	else
		mv "$1" "$2"
	fi
}

# Create and go to the directory
mkdirg() {
	mkdir -p "$1"
	cd "$1"
}

lazyg() {
	git add .
	git commit -m "$1"
	git push
}

eval "$(starship init bash)"
eval "$(zoxide init bash)"
