#!/bin/sh

set -eu

SCRIPT_DIR=$(unset CDPATH && cd -- "$(dirname -- "$0")" && pwd -P)
OS_NAME=$(uname -s 2>/dev/null || echo unknown)
MYBASHDIR="$HOME/.local/share/mybash"
NERD_FONT_FAMILY="JetBrainsMono Nerd Font"
NERD_FONT_SIZE=12
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"

if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
	RC=$(tput sgr0)
	RED=$(tput setaf 1)
	YELLOW=$(tput setaf 3)
	GREEN=$(tput setaf 2)
else
	RC=
	RED=
	YELLOW=
	GREEN=
fi

print_colored() {
	color=$1
	message=$2
	printf '%s%s%s\n' "$color" "$message" "$RC"
}

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

find_brew() {
	if command_exists brew; then
		command -v brew
	elif [ -x /opt/homebrew/bin/brew ]; then
		printf '%s\n' /opt/homebrew/bin/brew
	elif [ -x /usr/local/bin/brew ]; then
		printf '%s\n' /usr/local/bin/brew
	else
		return 1
	fi
}

sudo_cmd() {
	if command_exists sudo; then
		sudo "$@"
	elif command_exists doas && [ -f /etc/doas.conf ]; then
		doas "$@"
	else
		su -c "$*"
	fi
}

ensure_homebrew_macos() {
	brew_path=$(find_brew 2>/dev/null || true)
	if [ -z "$brew_path" ]; then
		if ! command_exists curl; then
			print_colored "$RED" "curl is required to install Homebrew on macOS."
			return 1
		fi

		print_colored "$YELLOW" "Installing Homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		brew_path=$(find_brew 2>/dev/null || true)
	fi

	if [ -z "$brew_path" ]; then
		print_colored "$RED" "Homebrew installation finished, but brew was not found."
		return 1
	fi

	brew_prefix=$("$brew_path" --prefix)
	PATH="$brew_prefix/bin:$brew_prefix/sbin:$PATH"
	export PATH
	hash -r 2>/dev/null || true
}

brew_install_missing() {
	missing=
	for formula in "$@"; do
		if ! brew list --formula "$formula" >/dev/null 2>&1; then
			missing="${missing:+$missing }$formula"
		fi
	done

	if [ -n "$missing" ]; then
		# shellcheck disable=SC2086
		brew install $missing
	fi
}

brew_install_cask_if_available() {
	cask=$1
	if brew info --cask "$cask" >/dev/null 2>&1 &&
		! brew list --cask "$cask" >/dev/null 2>&1; then
		brew install --cask "$cask"
	fi
}

prepare_bash_completion_macos() {
	if brew list --formula bash-completion >/dev/null 2>&1 &&
		! brew list --formula bash-completion@2 >/dev/null 2>&1; then
		print_colored "$YELLOW" "Unlinking bash-completion 1.x before installing bash-completion@2..."
		brew unlink bash-completion
	fi
}

install_dependencies_macos() {
	ensure_homebrew_macos

	print_colored "$YELLOW" "Installing macOS dependencies with Homebrew..."
	prepare_bash_completion_macos
	brew_install_missing bash bash-completion@2 bat tree multitail fastfetch neovim trash fzf zoxide starship
	brew_install_cask_if_available font-meslo-lg-nerd-font
}

ensure_homebrew_bash_macos() {
	[ "$OS_NAME" = Darwin ] || return 0

	ensure_homebrew_macos
	brew_prefix=$(brew --prefix)
	brew_bash="$brew_prefix/bin/bash"

	if [ ! -x "$brew_bash" ]; then
		print_colored "$RED" "Homebrew Bash was not found at $brew_bash."
		return 1
	fi

	if ! grep -qxF "$brew_bash" /etc/shells; then
		print_colored "$YELLOW" "Adding $brew_bash to /etc/shells..."
		printf '%s\n' "$brew_bash" | sudo tee -a /etc/shells >/dev/null
	fi

	if [ "${SHELL:-}" != "$brew_bash" ]; then
		print_colored "$YELLOW" "Changing default shell to $brew_bash..."
		chsh -s "$brew_bash"
	fi
}

install_dependencies_linux() {
	if command_exists nala; then
		sudo_cmd nala install -y bash-completion bat tree multitail fastfetch neovim trash-cli fzf zoxide curl fontconfig tar xz-utils
	elif command_exists apt-get; then
		sudo_cmd apt-get update
		sudo_cmd apt-get install -y bash-completion bat tree multitail fastfetch neovim trash-cli fzf zoxide curl fontconfig tar xz-utils
	elif command_exists dnf; then
		sudo_cmd dnf install -y bash-completion bat tree multitail fastfetch neovim trash-cli fzf zoxide curl fontconfig tar xz
	elif command_exists yum; then
		sudo_cmd yum install -y bash-completion bat tree multitail fastfetch neovim trash-cli fzf zoxide curl fontconfig tar xz
	elif command_exists pacman; then
		sudo_cmd pacman -S --needed bash-completion bat tree multitail fastfetch neovim trash-cli fzf zoxide curl fontconfig tar xz
	elif command_exists zypper; then
		sudo_cmd zypper install -y bash-completion bat tree multitail fastfetch neovim trash-cli fzf zoxide curl fontconfig tar xz
	elif command_exists emerge; then
		sudo_cmd emerge --ask=n app-shells/bash-completion sys-apps/bat app-text/tree app-text/multitail app-misc/fastfetch app-editors/neovim app-misc/trash-cli app-shells/fzf app-shells/zoxide net-misc/curl media-libs/fontconfig app-arch/tar app-arch/xz-utils
	elif command_exists xbps-install; then
		sudo_cmd xbps-install -Sy bash-completion bat tree multitail fastfetch neovim trash-cli fzf zoxide curl fontconfig tar xz
	elif command_exists nix-env; then
		nix-env -iA nixpkgs.bash-completion nixpkgs.bat nixpkgs.tree nixpkgs.multitail nixpkgs.fastfetch nixpkgs.neovim nixpkgs.trash-cli nixpkgs.fzf nixpkgs.zoxide nixpkgs.curl nixpkgs.fontconfig nixpkgs.gnutar nixpkgs.xz
	else
		print_colored "$RED" "Can't find a supported package manager."
		return 1
	fi
}

install_dependencies() {
	case $OS_NAME in
	Darwin)
		install_dependencies_macos
		;;
	Linux)
		install_dependencies_linux
		;;
	*)
		print_colored "$RED" "Unsupported operating system: $OS_NAME"
		return 1
		;;
	esac
}

install_starship_linux() {
	[ "$OS_NAME" = Linux ] || return 0

	if command_exists starship; then
		return 0
	fi

	print_colored "$YELLOW" "Installing Starship..."
	mkdir -p "$HOME/.local/bin"
	starship_installer=$(mktemp)
	if ! curl -fsSL https://starship.rs/install.sh -o "$starship_installer"; then
		rm -f "$starship_installer"
		print_colored "$RED" "Failed to download the Starship installer."
		return 1
	fi
	if ! sh "$starship_installer" -y -b "$HOME/.local/bin"; then
		rm -f "$starship_installer"
		print_colored "$RED" "Starship installation failed."
		return 1
	fi
	rm -f "$starship_installer"
}

install_nerd_font_linux() {
	[ "$OS_NAME" = Linux ] || return 0

	if fc-list 2>/dev/null | grep -qi "$NERD_FONT_FAMILY"; then
		return 0
	fi

	print_colored "$YELLOW" "Installing $NERD_FONT_FAMILY..."
	font_temp_dir=$(mktemp -d)
	font_archive="$font_temp_dir/JetBrainsMono.tar.xz"
	font_unpack_dir="$font_temp_dir/unpacked"
	font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
	mkdir -p "$font_unpack_dir" "$font_dir"

	if ! curl -fsSL "$NERD_FONT_URL" -o "$font_archive"; then
		rm -rf "$font_temp_dir"
		print_colored "$RED" "Failed to download $NERD_FONT_FAMILY."
		return 1
	fi
	if ! tar -xJf "$font_archive" -C "$font_unpack_dir"; then
		rm -rf "$font_temp_dir"
		print_colored "$RED" "Failed to extract $NERD_FONT_FAMILY."
		return 1
	fi

	find "$font_unpack_dir" -type f -name 'JetBrainsMonoNerdFont-*.ttf' -exec cp {} "$font_dir"/ \;
	font_found=
	for font_file in "$font_dir"/*.ttf; do
		if [ -f "$font_file" ]; then
			font_found=1
			break
		fi
	done
	rm -rf "$font_temp_dir"

	if [ -z "$font_found" ]; then
		print_colored "$RED" "No standard JetBrainsMono Nerd Font files were found in the archive."
		return 1
	fi

	fc-cache -f >/dev/null 2>&1
	print_colored "$GREEN" "$NERD_FONT_FAMILY installed."
}

configure_terminal_font_linux() {
	[ "$OS_NAME" = Linux ] || return 0

	if ! command_exists gsettings; then
		print_colored "$YELLOW" "Set your terminal font to '$NERD_FONT_FAMILY' manually."
		return 0
	fi

	terminal_schemas=$(gsettings list-schemas 2>/dev/null || true)
	terminal_configured=0

	if printf '%s\n' "$terminal_schemas" | grep -q '^org.gnome.Ptyxis$'; then
		ptyxis_backup="$MYBASHDIR/terminal-font-ptyxis.backup"
		if [ ! -f "$ptyxis_backup" ]; then
			{
				printf 'use-system-font=%s\n' "$(gsettings get org.gnome.Ptyxis use-system-font)"
				printf 'font-name=%s\n' "$(gsettings get org.gnome.Ptyxis font-name)"
			} >"$ptyxis_backup"
		fi
		gsettings set org.gnome.Ptyxis use-system-font false
		gsettings set org.gnome.Ptyxis font-name "$NERD_FONT_FAMILY $NERD_FONT_SIZE"
		terminal_configured=1
	fi

	if printf '%s\n' "$terminal_schemas" | grep -q '^org.gnome.Terminal.ProfilesList$'; then
		gnome_profile=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")
		if [ -n "$gnome_profile" ]; then
			gnome_schema="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$gnome_profile/"
			gnome_backup="$MYBASHDIR/terminal-font-gnome.backup"
			if [ ! -f "$gnome_backup" ]; then
				{
					printf 'profile=%s\n' "$gnome_profile"
					printf 'use-system-font=%s\n' "$(gsettings get "$gnome_schema" use-system-font)"
					printf 'font=%s\n' "$(gsettings get "$gnome_schema" font)"
				} >"$gnome_backup"
			fi
			gsettings set "$gnome_schema" use-system-font false
			gsettings set "$gnome_schema" font "$NERD_FONT_FAMILY $NERD_FONT_SIZE"
			terminal_configured=1
		fi
	fi

	if [ "$terminal_configured" -eq 1 ]; then
		print_colored "$GREEN" "Configured the terminal to use $NERD_FONT_FAMILY."
	else
		print_colored "$YELLOW" "Set your terminal font to '$NERD_FONT_FAMILY' manually."
	fi
}

backup_existing() {
	target=$1
	if [ -e "$target" ] || [ -L "$target" ]; then
		backup="$target.bak.$(date +%Y%m%d%H%M%S)"
		mv "$target" "$backup"
		print_colored "$YELLOW" "Backed up $target to $backup"
	fi
}

link_file() {
	source=$1
	target=$2
	target_dir=$(dirname -- "$target")

	mkdir -p "$target_dir"

	if [ -L "$target" ]; then
		if [ "$(readlink "$target")" = "$source" ]; then
			return 0
		fi
		rm "$target"
	elif [ -e "$target" ]; then
		backup_existing "$target"
	fi

	ln -s "$source" "$target"
	print_colored "$GREEN" "Linked $target"
}

ensure_bash_profile_sources_bashrc() {
	[ "$OS_NAME" = Darwin ] || return 0

	profile=$HOME/.bash_profile
	if [ -f "$profile" ] && grep -q 'HOME/.bashrc' "$profile"; then
		return 0
	fi

	{
		printf '\n# Source .bashrc for interactive bash shells\n'
		printf '%s\n' "if [ -f \"\$HOME/.bashrc\" ]; then"
		printf '%s\n' ". \"\$HOME/.bashrc\""
		printf 'fi\n'
	} >>"$profile"
	print_colored "$GREEN" "Updated $profile to source .bashrc"
}

ensure_bash_profile_brew_shellenv() {
	[ "$OS_NAME" = Darwin ] || return 0

	profile=$HOME/.bash_profile
	if [ -f "$profile" ] && grep -q 'brew shellenv' "$profile"; then
		return 0
	fi

	{
		printf '\n# Configure Homebrew for login shells\n'
		printf 'if [ -x /opt/homebrew/bin/brew ]; then\n'
		printf '%s\n' "eval \"\$(/opt/homebrew/bin/brew shellenv)\""
		printf 'elif [ -x /usr/local/bin/brew ]; then\n'
		printf '%s\n' "eval \"\$(/usr/local/bin/brew shellenv)\""
		printf 'fi\n'
	} >>"$profile"
	print_colored "$GREEN" "Updated $profile with Homebrew shellenv"
}

install_configs() {
	mkdir -p "$MYBASHDIR"
	cp -p "$SCRIPT_DIR/.bashrc" "$MYBASHDIR/.bashrc"
	cp -p "$SCRIPT_DIR/starship.toml" "$MYBASHDIR/starship.toml"
	cp -p "$SCRIPT_DIR/config.jsonc" "$MYBASHDIR/config.jsonc"
	cp -p "$SCRIPT_DIR/README.md" "$MYBASHDIR/README.md"
	cp -p "$SCRIPT_DIR/setup.sh" "$MYBASHDIR/setup.sh"
	cp -p "$SCRIPT_DIR/uninstall.sh" "$MYBASHDIR/uninstall.sh"
	cp -p "$SCRIPT_DIR/starship-theme" "$MYBASHDIR/starship-theme"
	chmod +x "$MYBASHDIR/setup.sh" "$MYBASHDIR/uninstall.sh" "$MYBASHDIR/starship-theme"

	link_file "$MYBASHDIR/.bashrc" "$HOME/.bashrc"
	link_file "$MYBASHDIR/starship.toml" "$HOME/.config/starship.toml"
	link_file "$MYBASHDIR/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
	link_file "$MYBASHDIR/starship-theme" "$HOME/.local/bin/starship-theme"
	ensure_homebrew_bash_macos
	ensure_bash_profile_brew_shellenv
	ensure_bash_profile_sources_bashrc
}

install_dependencies
install_starship_linux
install_nerd_font_linux
install_configs
configure_terminal_font_linux

print_colored "$GREEN" "Installation complete. Restart your shell or run: source ~/.bashrc"
