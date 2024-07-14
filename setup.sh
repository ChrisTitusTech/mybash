#!/bin/sh

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

# Check if the home directory and linuxtoolbox folder exist, create them if they don't
LINUXTOOLBOXDIR="$HOME/linuxtoolbox"

if [ ! -d "$LINUXTOOLBOXDIR" ]; then
    echo "${YELLOW}Creating linuxtoolbox directory: $LINUXTOOLBOXDIR${RC}"
    mkdir -p "$LINUXTOOLBOXDIR"
    echo "${GREEN}linuxtoolbox directory created: $LINUXTOOLBOXDIR${RC}"
fi

if [ ! -d "$LINUXTOOLBOXDIR/mybash" ]; then
    echo "${YELLOW}Cloning mybash repository into: $LINUXTOOLBOXDIR/mybash${RC}"
    git clone https://github.com/ChrisTitusTech/mybash "$LINUXTOOLBOXDIR/mybash"
    if [ $? -eq 0 ]; then
        echo "${GREEN}Successfully cloned mybash repository${RC}"
    else
        echo "${RED}Failed to clone mybash repository${RC}"
        exit 1
    fi
fi

cd "$LINUXTOOLBOXDIR/mybash" || exit

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

checkEnv() {
    ## Check for requirements.
    REQUIREMENTS='curl groups sudo'
    for req in $REQUIREMENTS; do
        if ! command_exists $req; then
            echo "${RED}To run me, you need: $REQUIREMENTS${RC}"
            exit 1
        fi
    done

    ## Check Package Handler
    PACKAGEMANAGER='apt yum dnf pacman zypper'
    for pgm in $PACKAGEMANAGER; do
        if command_exists $pgm; then
            PACKAGER=$pgm
            echo "Using $pgm"
            break
        fi
    done

    if [ -z "$PACKAGER" ]; then
        echo "${RED}Can't find a supported package manager${RC}"
        exit 1
    fi

    if command_exists sudo; then
        SUDO_CMD="sudo"
    elif command_exists doas && [ -f "/etc/doas.conf" ]; then
        SUDO_CMD="doas"
    else
        SUDO_CMD="su -c"
    fi

    echo "Using ${SUDO_CMD} as privilege escalation software"
    
    ## Check if the current directory is writable.
    GITPATH=`dirname \`realpath $0\``
    if [ ! -w $GITPATH ]; then
        echo "${RED}Can't write to $GITPATH${RC}"
        exit 1
    fi

    ## Check SuperUser Group
    SUPERUSERGROUP='wheel sudo root'
    for sug in $SUPERUSERGROUP; do
        if groups | grep $sug >/dev/null; then
            SUGROUP=$sug
            echo "Super user group $SUGROUP"
            break
        fi
    done

    ## Check if member of the sudo group.
    if ! groups | grep $SUGROUP >/dev/null; then
        echo "${RED}You need to be a member of the sudo group to run me!${RC}"
        exit 1
    fi
}

installDepend() {
    ## Check for dependencies.
    DEPENDENCIES='bash bash-completion tar bat tree multitail fastfetch'
    if ! command_exists nvim; then
        DEPENDENCIES="${DEPENDENCIES} neovim"
    fi

    echo "${YELLOW}Installing dependencies...${RC}"
    if [ "$PACKAGER" = "pacman" ]; then
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
    elif [ "$PACKAGER" = "nala" ]; then
        ${SUDO_CMD} ${PACKAGER} install -y ${DEPENDENCIES}
    elif [ "$PACKAGER" = "emerge" ]; then
        ${SUDO_CMD} ${PACKAGER} -v app-shells/bash app-shells/bash-completion app-arch/tar app-editors/neovim sys-apps/bat app-text/tree app-text/multitail app-misc/fastfetch
    elif [ "$PACKAGER" = "xbps-install" ]; then
        ${SUDO_CMD} ${PACKAGER} -v ${DEPENDENCIES}
    elif [ "$PACKAGER" = "nix-env" ]; then
        ${SUDO_CMD} ${PACKAGER} -iA nixos.bash nixos.bash-completion nixos.gnutar nixos.neovim nixos.bat nixos.tree nixos.multitail nixos.fastfetch
    else
        ${SUDO_CMD} ${PACKAGER} install -yq ${DEPENDENCIES}
    fi
}

installStarship() {
    if command_exists starship; then
        echo "Starship already installed"
        return
    fi

    if ! curl -sS https://starship.rs/install.sh | sh; then
        echo "${RED}Something went wrong during starship install!${RC}"
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
        echo "${RED}Something went wrong during zoxide install!${RC}"
        exit 1
    fi
}

install_additional_dependencies() {
    case `command -v apt || command -v zypper || command -v dnf || command -v pacman` in
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
    USER_HOME=`getent passwd ${SUDO_USER:-$USER} | cut -d: -f6`
    ## Check if a bashrc file is already there.
    OLD_BASHRC="$USER_HOME/.bashrc"
    if [ -e $OLD_BASHRC ]; then
        echo "${YELLOW}Moving old bash config file to $USER_HOME/.bashrc.bak${RC}"
        if ! mv $OLD_BASHRC $USER_HOME/.bashrc.bak; then
            echo "${RED}Can't move the old bash config file!${RC}"
            exit 1
        fi
    fi

    if [ ! -d $USER_HOME/.config/fastfetch ]; then
        mkdir -p $USER_HOME/.config/fastfetch
    fi
    echo "${YELLOW}Linking new bash config file...${RC}"
    ## Make symbolic link.
    ln -svf $GITPATH/config.jsonc $USER_HOME/.config/fastfetch/config.jsonc
    ln -svf $GITPATH/.bashrc $USER_HOME/.bashrc
    ln -svf $GITPATH/starship.toml $USER_HOME/.config/starship.toml
}

checkEnv
installDepend
installStarship
installZoxide
install_additional_dependencies
create_fastfetch_config

if linkConfig; then
    echo "${GREEN}Done!\nrestart your shell to see the changes.${RC}"
else
    echo "${RED}Something went wrong!${RC}"
fi