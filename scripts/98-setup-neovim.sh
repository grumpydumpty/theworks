#!/bin/bash

# set argument defaults
USER=vlabs

##############################################################################
## setup neovim with nord theme and omarchy config

cd /home/${USER}/

git clone https://github.com/basecamp/omarchy.git

rm -rf /home/${USER}/.config/nvim

mkdir -p /home/${USER}/.config/nvim/

git clone https://github.com/LazyVim/starter /home/${USER}/.config/nvim

cp -R omarchy/config/nvim/* /home/${USER}/.config/nvim/

cp omarchy/themes/nord/neovim.lua /home/${USER}/.config/nvim/lua/plugins/theme.lua

echo "vim.opt.relativenumber = false" >> /home/${USER}/.config/nvim/lua/config/options.lua

rm -rf /home/${USER}/.config/nvim/.git/ omarchy/

## run neovim to complete installation and configuration of plugins
nvim

## NOTE: you need to run the following outside the container before exiting
echo;
echo "#############################################################################";
echo "##";
echo "## Do not forget to run the following (outside the container) before";
echo "## exiting this container:";
echo "##"
echo "##    $ docker commit <hash> <image>:<tag>";
echo "##";
echo "## where:";
echo "##";
echo "##    hash  = container hash from docker ps";
echo "##    image = name of new container";
echo "##    tag   = tag of new container";
echo "##";
echo "#############################################################################";
echo;

#############################################################################
# vim: ft=unix sync=dockerfile ts=4 sw=4 et tw=78:
