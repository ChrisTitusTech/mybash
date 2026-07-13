#!/bin/sh -e

# Define color codes using tput for better compatibility
RC=$(tput sgr0)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)

MYBASHDIR="$HOME/.local/share/mybash"
PACKAGER=""
SUDO_CMD=""

print_colored() {
	color=$1
	message=$2
	printf "${color}%s${RC}\n" "$message"
}

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

determine_package_manager() {
	PACKAGEMANAGER='brew nala apt dnf yum pacman zypper emerge xbps-install nix-env'
	for pgm in ${PACKAGEMANAGER}; do
		if command_exists "$pgm"; then
			PACKAGER="$pgm"
			printf "Using %s\n" "$pgm"
			break
		fi
	done

	if [ -z "$PACKAGER" ]; then
		print_colored "$RED" "Can't find a supported package manager"
		exit 1
	fi
}

determine_sudo_command() {
	if command_exists sudo; then
		SUDO_CMD="sudo"
	elif command_exists doas && [ -f "/etc/doas.conf" ]; then
		SUDO_CMD="doas"
	else
		SUDO_CMD="su -c"
	fi

	printf "Using %s as privilege escalation software\n" "$SUDO_CMD"
}

run_privileged() {
	if [ "$SUDO_CMD" = "su -c" ]; then
		su -c "$*"
	else
		"$SUDO_CMD" "$@"
	fi
}

uninstall_dependencies() {
	set -- bash-completion bat tree multitail fastfetch neovim trash-cli

	print_colored "$YELLOW" "Uninstalling dependencies..."
	if [ "$PACKAGER" = "brew" ]; then
		brew uninstall --ignore-dependencies bash-completion bash-completion@2 bat tree multitail fastfetch neovim trash fzf zoxide starship || true
	elif [ "$PACKAGER" = "pacman" ]; then
		if command_exists yay; then
			yay -Rns --noconfirm "$@"
		elif command_exists paru; then
			paru -Rns --noconfirm "$@"
		else
			run_privileged pacman -Rns --noconfirm "$@"
		fi
	elif [ "$PACKAGER" = "nala" ] || [ "$PACKAGER" = "apt" ]; then
		run_privileged "$PACKAGER" purge -y "$@"
	elif [ "$PACKAGER" = "emerge" ]; then
		run_privileged "$PACKAGER" --deselect app-shells/bash-completion sys-apps/bat app-text/tree app-text/multitail app-misc/fastfetch app-editors/neovim app-misc/trash-cli
	elif [ "$PACKAGER" = "xbps-install" ]; then
		run_privileged xbps-remove -Ry "$@"
	elif [ "$PACKAGER" = "nix-env" ]; then
		run_privileged "$PACKAGER" -e "$@"
	elif [ "$PACKAGER" = "dnf" ] || [ "$PACKAGER" = "yum" ]; then
		run_privileged "$PACKAGER" remove -y "$@"
	else
		run_privileged "$PACKAGER" remove -y "$@"
	fi
}

uninstall_font() {
	FONT_NAME="MesloLGS Nerd Font Mono"
	FONT_DIR="$HOME/.local/share/fonts/$FONT_NAME"

	if [ -d "$FONT_DIR" ]; then
		print_colored "$YELLOW" "Removing font: $FONT_NAME"
		rm -rf "$FONT_DIR"
		fc-cache -fv
		print_colored "$GREEN" "Font removed: $FONT_NAME"
	else
		print_colored "$YELLOW" "Font not found: $FONT_NAME"
	fi
}

uninstall_starship_and_fzf() {
	if command_exists starship; then
		print_colored "$YELLOW" "Uninstalling Starship..."
		run_privileged rm -f "$(command -v starship)"
		print_colored "$GREEN" "Starship uninstalled"
	fi

	if [ -d "$HOME/.fzf" ]; then
		print_colored "$YELLOW" "Uninstalling fzf..."
		"$HOME/.fzf/uninstall"
		rm -rf "$HOME/.fzf"
		print_colored "$GREEN" "fzf uninstalled"
	fi
}

uninstall_zoxide() {
	if command_exists zoxide; then
		print_colored "$YELLOW" "Uninstalling Zoxide..."
		run_privileged rm -f "$(command -v zoxide)"
		print_colored "$GREEN" "Zoxide uninstalled"
	fi
}

remove_configs() {
	if command_exists getent; then
		USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
	else
		USER_HOME=${HOME}
	fi

	print_colored "$YELLOW" "Removing configuration files..."

	# Remove .bashrc symlink and restore backup if it exists
	if [ -L "$USER_HOME/.bashrc" ]; then
		rm "$USER_HOME/.bashrc"
		if [ -f "$USER_HOME/.bashrc.bak" ]; then
			mv "$USER_HOME/.bashrc.bak" "$USER_HOME/.bashrc"
			print_colored "$GREEN" "Restored original .bashrc"
		fi
	fi

	# Remove starship config
	rm -f "$USER_HOME/.config/starship.toml"

	# Remove fastfetch config
	rm -f "$USER_HOME/.config/fastfetch/config.jsonc"

	print_colored "$GREEN" "Configuration files removed"
}

remove_mybash_data() {
	if [ -d "$MYBASHDIR" ]; then
		print_colored "$YELLOW" "Removing mybash data directory..."
		rm -rf "$MYBASHDIR"
		print_colored "$GREEN" "mybash data directory removed"
	fi
}

# Main execution
determine_package_manager
determine_sudo_command
uninstall_dependencies
uninstall_font
uninstall_starship_and_fzf
uninstall_zoxide
remove_configs
remove_mybash_data

print_colored "$GREEN" "Uninstallation complete. Please restart your shell for changes to take effect."
