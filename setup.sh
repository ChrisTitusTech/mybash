#!/bin/bash

gitpath=`pwd`

ln -s $gitpath/.bashrc $HOME/.bashrc
ln -s $gitpath/starship.toml $HOME/.config/starship.toml
