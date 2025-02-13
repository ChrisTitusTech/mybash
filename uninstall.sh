#!/bin/sh -e

# Define color codes using tput for better compatibility
RC=$(tput sgr0)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)

LINUXTOOLBOXDIR="$HOME/linuxtoolbox"
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
    PACKAGEMANAGER='nala apt dnf yum pacman zypper emerge xbps-install nix-env'
    for pgm in $PACKAGEMANAGER; do
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

uninstall_dependencies() {
    DEPENDENCIES='bash-completion bat tree multitail fastfetch neovim trash-cli'

    print_colored "$YELLOW" "Uninstalling dependencies..."
    if [ "$PACKAGER" = "pacman" ]; then
        if command_exists yay; then
            yay -Rns --noconfirm ${DEPENDENCIES}
        elif command_exists paru; then
            paru -Rns --noconfirm ${DEPENDENCIES}
        else
            ${SUDO_CMD} pacman -Rns --noconfirm ${DEPENDENCIES}
        fi
    elif [ "$PACKAGER" = "nala" ] || [ "$PACKAGER" = "apt" ]; then
        ${SUDO_CMD} ${PACKAGER} purge -y ${DEPENDENCIES}
    elif [ "$PACKAGER" = "emerge" ]; then
        ${SUDO_CMD} ${PACKAGER} --deselect app-shells/bash-completion sys-apps/bat app-text/tree app-text/multitail app-misc/fastfetch app-editors/neovim app-misc/trash-cli
    elif [ "$PACKAGER" = "xbps-install" ]; then
        ${SUDO_CMD} xbps-remove -Ry ${DEPENDENCIES}
    elif [ "$PACKAGER" = "nix-env" ]; then
        ${SUDO_CMD} ${PACKAGER} -e bash-completion bat tree multitail fastfetch neovim trash-cli
    elif [ "$PACKAGER" = "dnf" ] || [ "$PACKAGER" = "yum" ]; then
        ${SUDO_CMD} ${PACKAGER} remove -y ${DEPENDENCIES}
    else
        ${SUDO_CMD} ${PACKAGER} remove -y ${DEPENDENCIES}
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
        ${SUDO_CMD} rm -f "$(command -v starship)"
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
        ${SUDO_CMD} rm -f "$(command -v zoxide)"
        print_colored "$GREEN" "Zoxide uninstalled"
    fi
}

remove_configs() {
    USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
    
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

remove_linuxtoolbox() {
    if [ -d "$LINUXTOOLBOXDIR" ]; then
        print_colored "$YELLOW" "Removing linuxtoolbox directory..."
        rm -rf "$LINUXTOOLBOXDIR"
        print_colored "$GREEN" "linuxtoolbox directory removed"
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
remove_linuxtoolbox

print_colored "$GREEN" "Uninstallation complete. Please restart your shell for changes to take effect."