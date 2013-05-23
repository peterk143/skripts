#!/bin/bash

## link ssh private keys
if [ -d /media/${USER}/PCP/.ssh ]; then
    if ! [ -h ~/.ssh/identity.bbs ]; then
	ln -s /media/${USER}/PCP/.ssh/identity.ovt /home/${USER}/.ssh/
	ln -s /media/${USER}/PCP/.ssh/identity.bbs /home/${USER}/.ssh/
    fi
fi

## remove sshKey popup box
if [ -f /etc/xdg/autostart/gnome-keyring-ssh.desktop ]; then
    mkdir -p ~/.config/autostart
    cp /etc/xdg/autostart/gnome-keyring-ssh.desktop ~/.config/autostart/
    sed -i '/NoDisplay=true/d' ~/.config/autostart/gnome-keyring-ssh.desktop
    echo "X-GNOME-Autostart-enabled=false" >> ~/.config/autostart/gnome-keyring-ssh.desktop
fi

## create link to /cloudhome
if ! [ -h /home/${USER}/cloud ]; then
    ln -s /cloudhome/${USER}/ /home/${USER}/cloud
fi

## remove useless files
if [ -f /home/${USER}/Desktop/README.nohome ]; then
    rm /home/${USER}/Desktop/README.nohome
fi
if [ -f /home/${USER}/examples.desktop ]; then
    rm /home/${USER}/examples.desktop
fi

## create link to weechat
if ! [ -h /home/${USER}/.weechat ]; then
    ln -s /cloudhome/${USER}/.weechat /home/${USER}/
fi

## set background
result=`pgrep X`
if [ $? -eq 0 ]; then 
    gsettings set org.gnome.desktop.background picture-uri file:///cloudhome/${USER}/backgrounds/wallpaper-2459215.jpg
    if [ -d ~/.gconf ]; then 
	rm -rf ~/.gconf
    fi
    ln -s /cloudhome/${USER}/.gconf ~/
fi

## set global git variables
GIT=`git --version`
if [ $? -eq 0 ]; then
    git config --global user.email "peter.k143@gmail.com"
    git config --global user.name "Peter Kirkpatrick"
fi