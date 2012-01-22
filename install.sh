#!/bin/bash

##########################################################3
# This script will install eXp0stulate on a gnu/linux system.
# If you're using BSD or Mac OS, I believe it should also work fine.
# If you are using Windows, I can't help you.
# I'm trying to find someone to write an appropriate install script for Windows.
##########################################################3

name=$(whoami)

if [ $name != "$HOME/bin/" ]; then
	mkdir $HOME/bin/
	$PATH=$PATH:/$HOME/bin/
	export PATH
else

echo "Installing Xpostulate..."

echo "Creating config files..."

mkdir $HOME/.xpost
mv xpost-tiny.gif $HOME/.xpost/
cp xpost.conf $HOME/.xpost

echo "Moving files"

cp xpostul8.tcl $HOME/bin/xpostul8
chmod _x $HOME/bin/xpostul8

echo "Installation complete!"
echo "Thank you, $name, for using Xpostulate"
echo "To run Xpostulate, in terminal type xpostul8, or make an icon/menu item/short cut to /home/$name/bin/xpostul8"
echo "Enjoy!"

fi
exit
