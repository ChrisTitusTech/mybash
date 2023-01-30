#!/bin/bash

RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

checkEnv(){
    ## Check if the current directory is writable.
    GITPATH="$(dirname "$(realpath "$0")")"
    if [[ ! -w ${GITPATH} ]];then
        echo -e "${RED}Can't write to ${GITPATH}${RC}"
        exit 1
    fi

    ## Check for requirements.
    REQUIREMENTS='curl yay sudo'
    if ! which ${REQUIREMENTS}>/dev/null;then
        echo -e "${RED}To run me,https://github.com/fearlessgeekmedia/mybash you need: ${REQUIREMENTS}${RC}"
        exit 1
    fi

    ## Check if member of the wheel group.
    if ! groups|grep wheel>/dev/null;then
        echo -e "${RED}You need to be a member of the wheel to run me!"
        exit 1
    fi
}

installDepend(){
    ## Check for dependencies.
    # For some reason, if I put autojump in the original DEPENDENCIES variable, 
    # it skips the installation and just does bash and bash completion. So I
    # put autojump in a separate variable and separate yay command.
    DEPENDENCIES1='bash bash-completion'
    DEPENDENCIES2='autojump'
    DEPENDENCIES2='autojump-git'
    echo -e "${YELLOW}Installing dependencies...${RC}"
    yay -S ${DEPENDENCIES1}
    yay -S ${DEPENDENCIES2}
    yay -S ${DEPENDENCIES3}
    sudo mkdir /usr/local/bin/autojump
    sudo ln -s /etc/profile.d/autojump.sh /usr/share/autojump/autojump.sh
}

installStarship(){
    if ! curl -sS https://starship.rs/install.sh|sh;then
        echo -e "${RED}Something went wrong during starship install!${RC}"
        exit 1
    fi
}

linkConfig(){
    ## Check if a bashrc file is already there.
    OLD_BASHRC="${HOME}/.bashrc"
    if [[ -e ${OLD_BASHRC} ]];then
        echo -e "${YELLOW}Moving old bash config file to ${HOME}/.bashrc.bak${RC}"
        if ! mv ${OLD_BASHRC} ${HOME}/.bashrc.bak;then
            echo -e "${RED}Can't move the old bash config file!${RC}"
            exit 1
        fi
    fi

    echo -e "${YELLOW}Linking new bash config file...${RC}"
    ## Make symbolic link.
    ln -svf ${GITPATH}/.bashrc ${HOME}/.bashrc
    ln -svf ${GITPATH}/starship.toml ${HOME}/.config/starship.toml
}

checkEnv
installDepend
installStarship
if linkConfig;then
    echo -e "${GREEN}Done!\nrestart your shell to see the changes.${RC}"
else
    echo -e "${RED}Something went wrong!${RC}"
fi
