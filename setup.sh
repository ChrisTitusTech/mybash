#!/bin/bash

gitpath=`pwd`
curl -sS https://starship.rs/install.sh | sh
ln -s $gitpath/.bashrc $HOME/.bashrc
ln -s $gitpath/starship.toml $HOME/.config/starship.toml
