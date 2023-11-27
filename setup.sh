#!/bin/bash

bashrc_file="$HOME/.bashrc"

# Check if ~/.bashrc exists
if [ -e "$bashrc_file" ]; then
    # Backup existing ~/.bashrc
    backup_file="$HOME/.bashrc_backup_$(date +%Y%m%d%H%M%S)"
    cp "$bashrc_file" "$backup_file"
    echo "Backup created: $backup_file"

    # Remove ~/.bashrc
    rm "$bashrc_file"
    echo "Deleted existing ~/.bashrc file."
else
    echo "No existing ~/.bashrc file found."
fi

RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

command_exists () {
    command -v $1 >/dev/null 2>&1;
}

checkEnv() {
    ## Check for requirements.
    REQUIREMENTS='curl groups sudo'
    if ! command_exists ${REQUIREMENTS}; then
        echo -e "${RED}To run me, you need: ${REQUIREMENTS}${RC}"
        exit 1
    fi

    ## Check Package Handeler
    PACKAGEMANAGER='apt yum dnf pacman zypper'
    for pgm in ${PACKAGEMANAGER}; do
        if command_exists ${pgm}; then
            PACKAGER=${pgm}
            echo -e "Using ${pgm}"
        fi
    done

    if [ -z "${PACKAGER}" ]; then
        echo -e "${RED}Can't find a supported package manager"
        exit 1
    fi


    ## Check if the current directory is writable.
    GITPATH="$(dirname "$(realpath "$0")")"
    if [[ ! -w ${GITPATH} ]]; then
        echo -e "${RED}Can't write to ${GITPATH}${RC}"
        exit 1
    fi

    ## Check SuperUser Group
    SUPERUSERGROUP='wheel sudo root'
    for sug in ${SUPERUSERGROUP}; do
        if groups | grep ${sug}; then
            SUGROUP=${sug}
            echo -e "Super user group ${SUGROUP}"
        fi
    done

    ## Check if member of the sudo group.
    if ! groups | grep ${SUGROUP} >/dev/null; then
        echo -e "${RED}You need to be a member of the sudo group to run me!"
        exit 1
    fi
    
}

installDepend() {
    ## Check for dependencies.
    DEPENDENCIES='autojump bash bash-completion tar neovim bat'
    echo -e "${YELLOW}Installing dependencies...${RC}"
    if [[ $PACKAGER == "pacman" ]]; then
        if ! command_exists yay; then
            echo "Installing yay..."
            sudo ${PACKAGER} --noconfirm -S base-devel
            $(cd /opt && sudo git clone https://aur.archlinux.org/yay-git.git && sudo chown -R ${USER}:${USER} ./yay-git && cd yay-git && makepkg --noconfirm -si)
        else
            echo "Command yay already installed"
        fi
    	yay --noconfirm -S ${DEPENDENCIES}
    else 
    	sudo ${PACKAGER} install -yq ${DEPENDENCIES}
    fi
}

installStarship(){
    if command_exists starship; then
        echo "Starship already installed"
        return
    fi

    if ! curl -sS https://starship.rs/install.sh|sh;then
        echo -e "${RED}Something went wrong during starship install!${RC}"
        exit 1
    fi
}

linkConfig() {
    ## Get the correct user home directory.
    USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
    ## Check if a bashrc file is already there.
    OLD_BASHRC="${USER_HOME}/.bashrc"
    if [[ -e ${OLD_BASHRC} ]]; then
        echo -e "${YELLOW}Moving old bash config file to ${USER_HOME}/.bashrc.bak${RC}"
        if ! mv ${OLD_BASHRC} ${USER_HOME}/.bashrc.bak; then
            echo -e "${RED}Can't move the old bash config file!${RC}"
            exit 1
        fi
    fi

    echo -e "${YELLOW}Linking new bash config file...${RC}"
    ## Make symbolic link.
    ln -svf ${GITPATH}/.bashrc ${USER_HOME}/.bashrc
    ln -svf ${GITPATH}/starship.toml ${USER_HOME}/.config/starship.toml
}

checkEnv
installDepend
installStarship

echo -e "Setting MesloLGMNerdFontMono font for the terminal"
# Set the path to your MesloLGM Nerd Font
font_path="font/MesloLGMNerdFontMono-Regular.ttf"

#!/bin/bash

# Function to check if a command is available
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to update font settings for GNOME Terminal
update_gnome_terminal() {
  profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ font 'MesloLGM Nerd Font 12'
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ use-system-font false
}


update_xfce_terminal() {
  xfce_config_file="$HOME/.config/xfce4/terminal/terminalrc"
  font_name="MesloLGM Nerd Font Mono 12"
  
  # Backup the existing configuration file
  cp "$xfce_config_file" "$xfce_config_file.backup"

  # Set the font property
  sed -i "s@^FontName=.*@FontName=$font_name@" "$xfce_config_file"
}

# Function to install the font
install_font() {
  font_file="font/MesloLGMNerdFontMono-Regular.ttf"
  install_path="$HOME/.fonts"

  # Create the font directory if it doesn't exist
  mkdir -p "$install_path"

  # Check if font file exists
  if [ -e "$font_file" ]; then
    # Copy the font file to the user font directory
    cp "$font_file" "$install_path"
    
    # Update the font cache
    fc-cache -fv
  else
    echo "Font file '$font_file' not found. Please provide the correct path."
  fi
}
# Function to install zoxide
install_zoxide() {
  sudo apt update
  echo -e "${YELLOW}Installing zoxide..${RC}"
  sudo apt install zoxide
}

# Check which terminal is available
if command_exists gnome-terminal; then
  echo "Detected GNOME Terminal."
  update_gnome_terminal
elif command_exists xfce4-terminal; then
  echo "Detected XFCE Terminal."
  update_xfce_terminal
else
  echo "Unsupported terminal. Font settings not updated."
fi


#install font
install_font
# Install zoxide
install_zoxide

if linkConfig; then
    echo -e "${GREEN}Done!\nrestart your shell to see the changes.${RC}"
else
    echo -e "${RED}Something went wrong!${RC}"
fi
