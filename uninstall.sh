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
	for FONT_DIR in \
		"$HOME/.local/share/fonts/JetBrainsMonoNerdFont" \
		"$HOME/.local/share/fonts/MesloLGS Nerd Font Mono"; do
		if [ -d "$FONT_DIR" ]; then
			print_colored "$YELLOW" "Removing font directory: $FONT_DIR"
			rm -rf "$FONT_DIR"
		fi
	done
	if command_exists fc-cache; then
		fc-cache -f >/dev/null 2>&1 || true
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

	# Remove the managed .bashrc symlink and restore the newest timestamped backup.
	if [ -L "$USER_HOME/.bashrc" ]; then
		rm "$USER_HOME/.bashrc"
		BASHRC_BACKUP=
		if [ -f "$USER_HOME/.bashrc.bak" ]; then
			BASHRC_BACKUP="$USER_HOME/.bashrc.bak"
		fi
		for BACKUP_CANDIDATE in "$USER_HOME"/.bashrc.bak.*; do
			if [ -f "$BACKUP_CANDIDATE" ]; then
				BASHRC_BACKUP=$BACKUP_CANDIDATE
			fi
		done
		if [ -n "$BASHRC_BACKUP" ]; then
			mv "$BASHRC_BACKUP" "$USER_HOME/.bashrc"
			print_colored "$GREEN" "Restored original .bashrc"
		fi
	fi

	# Remove starship config
	rm -f "$USER_HOME/.config/starship.toml"

	# Remove fastfetch config
	rm -f "$USER_HOME/.config/fastfetch/config.jsonc"
	rm -f "$USER_HOME/.local/bin/starship-theme"

	print_colored "$GREEN" "Configuration files removed"
}

restore_terminal_font() {
	if ! command_exists gsettings; then
		return 0
	fi

	FONT_BACKUP_DIR="$USER_HOME/.local/share/mybash"
	PTYXIS_BACKUP="$FONT_BACKUP_DIR/terminal-font-ptyxis.backup"
	GNOME_BACKUP="$FONT_BACKUP_DIR/terminal-font-gnome.backup"

	if [ -f "$PTYXIS_BACKUP" ]; then
		while IFS='=' read -r FONT_KEY FONT_VALUE; do
			case $FONT_KEY in
			use-system-font | font-name)
				gsettings set org.gnome.Ptyxis "$FONT_KEY" "$FONT_VALUE" 2>/dev/null || true
				;;
			esac
		done <"$PTYXIS_BACKUP"
		print_colored "$GREEN" "Restored the previous Ptyxis font settings"
	fi

	if [ -f "$GNOME_BACKUP" ]; then
		GNOME_PROFILE=
		while IFS='=' read -r FONT_KEY FONT_VALUE; do
			case $FONT_KEY in
			profile)
				GNOME_PROFILE=$FONT_VALUE
				;;
			use-system-font | font)
				if [ -n "$GNOME_PROFILE" ]; then
					GNOME_SCHEMA="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_PROFILE/"
					gsettings set "$GNOME_SCHEMA" "$FONT_KEY" "$FONT_VALUE" 2>/dev/null || true
				fi
				;;
			esac
		done <"$GNOME_BACKUP"
		print_colored "$GREEN" "Restored the previous GNOME Terminal font settings"
	fi
}

remove_mybash_data() {
	if [ -d "$MYBASHDIR" ]; then
		print_colored "$YELLOW" "Removing mybash data directory..."
		rm -rf "$MYBASHDIR"
		print_colored "$GREEN" "mybash data directory removed"
	fi
}

# Argument parsing
KEEP_DEPS=0
for ARG in "$@"; do
	case $ARG in
	--keep-deps)
		KEEP_DEPS=1
		;;
	-h | --help)
		printf '%s\n' "Usage: ./uninstall.sh [--keep-deps]"
		printf '%s\n' ""
		printf '%s\n' "  --keep-deps  Remove mybash configuration but keep installed software and fonts."
		exit 0
		;;
	*)
		printf 'Unknown option: %s\n' "$ARG" >&2
		exit 2
		;;
	esac
done

# Main execution
if [ "$KEEP_DEPS" -eq 0 ]; then
	determine_package_manager
	determine_sudo_command
	uninstall_dependencies
	uninstall_font
	uninstall_starship_and_fzf
	uninstall_zoxide
else
	print_colored "$YELLOW" "Keeping installed software and fonts."
fi
remove_configs
restore_terminal_font
remove_mybash_data

print_colored "$GREEN" "Uninstallation complete. Please restart your shell for changes to take effect."
