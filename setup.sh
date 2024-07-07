#!/usr/bin/env bash
# use bin/env bash as cannot be sure that bash actually exists at bin/bash

RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

# Check if the home directory and linuxtoolbox folder exist, create them if they don't
LINUXTOOLBOXDIR="$HOME/linuxtoolbox"

if [[ ! -d "$LINUXTOOLBOXDIR" ]]; then
    echo -e "${YELLOW}Creating linuxtoolbox directory: $LINUXTOOLBOXDIR${RC}"
    mkdir -p "$LINUXTOOLBOXDIR"
    echo -e "${GREEN}linuxtoolbox directory created: $LINUXTOOLBOXDIR${RC}"
fi

if [[ ! -d "$LINUXTOOLBOXDIR/mybash" ]]; then
    echo -e "${YELLOW}Cloning mybash repository into: $LINUXTOOLBOXDIR/mybash${RC}"
    git clone https://github.com/ChrisTitusTech/mybash "$LINUXTOOLBOXDIR/mybash"
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Successfully cloned mybash repository${RC}"
    else
        echo -e "${RED}Failed to clone mybash repository${RC}"
        exit 1
    fi
fi

# add variables to top level so can easily be accessed by all functions
PACKAGER=""
SUDO_CMD=""
SUGROUP=""
GITPATH=""

cd "$LINUXTOOLBOXDIR/mybash" || exit

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

checkEnv() {
    ## Check for requirements.
    # use local as it is more correct bash
    # use arrays instead of splitting
    local REQUIREMENTS=(curl groups sudo)
    for req in "${REQUIREMENTS[@]}"; do
        if ! command_exists ${req}; then
            echo -e "${RED}To run me, you need: ${REQUIREMENTS}${RC}"
            exit 1
        fi
    done

    ## Check Package Handeler
    local PACKAGEMANAGER=(nala apt dnf yum pacman zypper emerge xbps-install nix-env)

    for pgm in "${PACKAGEMANAGER[@]}"; do
        if command_exists ${pgm}; then
            PACKAGER=${pgm}
            echo -e "Using ${pgm}"
            break
        fi
    done

    if [ -z "${PACKAGER}" ]; then
        echo -e "${RED}Can't find a supported package manager${RC}"
        exit 1
    fi

    if command_exists sudo; then
        SUDO_CMD="sudo"
    elif command_exists doas && [ -f "/etc/doas.conf" ]; then
        SUDO_CMD="doas"
    else
        SUDO_CMD="su -c"
    fi

    echo "Using $SUDO_CMD as privilege escalation software"

    ## Check if the current directory is writable.
    # we cd'd into this directory before this function so we can use the PWD var
    if [[ ! -w "$PWD" ]]; then
        echo -e "${RED}Can't write to ${PWD}${RC}"
        exit 1
    fi

    ## Check SuperUser Group
    local SUPERUSERGROUP=(wheel sudo root)
    for sug in "${SUPERUSERGROUP[@]}"; do
        if groups | (command_exists rg && rg -q ${sug} || grep -q ${sug}); then
            SUGROUP=${sug}
            # don't need -e as there are no escape codes to escape
            echo "Super user group ${SUGROUP}"
            break
        fi
    done

    ## Check if member of the sudo group.
    if ! groups | (command_exists rg && rg -q ${SUGROUP} || grep -q ${SUGROUP}); then
        echo -e "${RED}You need to be a member of the sudo group to run me!${RC}"
        exit 1
    fi
}

installDepend() {
    ## Check for dependencies.
    DEPENDENCIES='bash bash-completion tar bat tree multitail fastfetch'
    if ! command_exists nvim; then
        DEPENDENCIES="${DEPENDENCIES} neovim"
    fi

    echo -e "${YELLOW}Installing dependencies...${RC}"
    if [[ "$PACKAGER" == "pacman" ]]; then
        if ! command_exists yay && ! command_exists paru; then
            echo "Installing yay as AUR helper..."
            ${SUDO_CMD} ${PACKAGER} --noconfirm -S base-devel
            cd /opt && ${SUDO_CMD} git clone https://aur.archlinux.org/yay-git.git && ${SUDO_CMD} chown -R ${USER}:${USER} ./yay-git
            cd yay-git && makepkg --noconfirm -si
        else
            echo "AUR helper already installed"
        fi
        if command_exists yay; then
            AUR_HELPER="yay"
        elif command_exists paru; then
            AUR_HELPER="paru"
        else
            echo "No AUR helper found. Please install yay or paru."
            exit 1
        fi
        ${AUR_HELPER} --noconfirm -S ${DEPENDENCIES}
    elif [[ "$PACKAGER" == "nala" ]]; then
        ${SUDO_CMD} ${PACKAGER} install -y ${DEPENDENCIES}
    elif [[ "$PACKAGER" == "emerge" ]]; then
        ${SUDO_CMD} ${PACKAGER} -v app-shells/bash app-shells/bash-completion app-arch/tar app-editors/neovim sys-apps/bat app-text/tree app-text/multitail app-misc/fastfetch
    elif [[ "$PACKAGER" == "xbps-install" ]]; then
        ${SUDO_CMD} ${PACKAGER} -v ${DEPENDENCIES}
    elif [[ "$PACKAGER" == "nix-env" ]]; then
        ${SUDO_CMD} ${PACKAGER} -iA nixos.bash nixos.bash-completion nixos.gnutar nixos.neovim nixos.bat nixos.tree nixos.multitail nixos.fastfetch
    elif [[ "$PACKAGER" == "dnf" ]]; then
        ${SUDO_CMD} ${PACKAGER} install -y ${DEPENDENCIES}
    else
        ${SUDO_CMD} ${PACKAGER} install -yq ${DEPENDENCIES}
    fi
}

installStarshipAndFzf() {
    if command_exists starship; then
        echo "Starship already installed"
        return
    fi

    if ! curl -sS https://starship.rs/install.sh | sh; then
        echo -e "${RED}Something went wrong during starship install!${RC}"
        exit 1
    fi
    if command_exists fzf; then
        echo "Fzf already installed"
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install
    fi
}

installZoxide() {
    if command_exists zoxide; then
        echo "Zoxide already installed"
        return
    fi

    if ! curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
        echo -e "${RED}Something went wrong during zoxide install!${RC}"
        exit 1
    fi
}

install_additional_dependencies() {
    # we have PACKAGER so just use it
    # for now just going to return early as we have already installed neovim in `installDepend`
    # so I am not sure why we are trying to install it again
    return
   case "$PACKAGER" in
        *apt)
            curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
            chmod u+x nvim.appimage
            ./nvim.appimage --appimage-extract
            ${SUDO_CMD} mv squashfs-root /opt/neovim
            ${SUDO_CMD} ln -s /opt/neovim/AppRun /usr/bin/nvim
            ;;
        *zypper)
            ${SUDO_CMD} zypper refresh
            ${SUDO_CMD} zypper install -y neovim
            ;;
        *dnf)
            ${SUDO_CMD} dnf check-update
            ${SUDO_CMD} dnf install -y neovim
            ;;
        *pacman)
            ${SUDO_CMD} pacman -Syu
            ${SUDO_CMD} pacman -S --noconfirm neovim
            ;;
        *)
            echo "No supported package manager found. Please install neovim manually."
            exit 1
            ;;
    esac
}

create_fastfetch_config() {
    fastfetch --gen-config
}

linkConfig() {
    ## Get the correct user home directory.
    USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
    ## Check if a bashrc file is already there.
    OLD_BASHRC="${USER_HOME}/.bashrc"
    if [[ -e "${OLD_BASHRC}" ]]; then
        echo -e "${YELLOW}Moving old bash config file to ${USER_HOME}/.bashrc.bak${RC}"
        if ! mv "${OLD_BASHRC}" "${USER_HOME}/.bashrc.bak"; then
            echo -e "${RED}Can't move the old bash config file!${RC}"
            exit 1
        fi
    fi

    echo -e "${YELLOW}Linking new bash config file...${RC}"
    ## Make symbolic link.
    ln -svf "${GITPATH}/.bashrc" "${USER_HOME}/.bashrc"
    ln -svf "${GITPATH}/starship.toml" "${USER_HOME}/.config/starship.toml"
    echo -e "${YELLOW}Linking custom fastfetch config file...${RC}"
    ln -svf "${GITPATH}/config.jsonc" "${USER_HOME}/.config/fastfetch/config.jsonc"
}

checkEnv
installDepend
installStarshipAndFzf
installZoxide
install_additional_dependencies
create_fastfetch_config

if linkConfig; then
    echo -e "${GREEN}Done!\nRestart your shell to see the changes.${RC}"
else
    echo -e "${RED}Something went wrong!${RC}"
fi
