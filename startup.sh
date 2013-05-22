#!/bin/bash

## link ssh private keys
if [ -d /media/PCP/.ssh ]; then
    if ! [ -h ~/.ssh/identity.bbs ]; then
	ln -s /media/PCP/.ssh/identity.ovt /home/pkirkpat/.ssh/
	ln -s /media/PCP/.ssh/identity.bbs /home/pkirkpat/.ssh/
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
if ! [ -h /home/pkirkpat/cloud ]; then
    ln -s /cloudhome/pkirkpat/ /home/pkirkpat/cloud
fi

## remove useless files
if [ -f /home/pkirkpat/Desktop/README.nohome ]; then
    rm /home/pkirkpat/Desktop/README.nohome
fi
if [ -f /home/pkirkpat/examples.desktop ]; then
    rm /home/pkirkpat/examples.desktop
fi

## create link to weechat
if ! [ -h /home/pkirkpat/.weechat ]; then
    ln -s /cloudhome/pkirkpat/.weechat /home/pkirkpat/
fi

## set background
result=`pgrep X`
if [ $? -eq 0 ]; then 
    gsettings set org.gnome.desktop.background picture-uri file:///cloudhome/pkirkpat/backgrounds/wallpaper-2459215.jpg
    if [ -d ~/.gconf ]; then 
	rm -rf ~/.gconf
    fi
    ln -s /cloudhome/pkirkpat/.gconf ~/
fi

## set global git variables
GIT=`git --version`
if [ $? -eq 0 ]; then
    git config --global user.email "peter.k143@gmail.com"
    git config --global user.name "Peter Kirkpatrick"
fi