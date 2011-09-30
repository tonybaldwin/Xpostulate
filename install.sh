#!/bin/bash

##########################################################3
# This script will install eXp0stulate on a gnu/linux system.
# If you're using BSD or Mac OS, I believe it should also work fine.
# If you are using Windows, I can't help you.
# I'm trying to find someone to write an appropriate install script for Windows.
##########################################################3

name=$(whoami)

if [ $name != "root" ]; then
echo "You must be root or sudo to continue installation"
echo "Please log in as root or sudo and try again."


else

echo "Installing Xpostulate..."

echo "Enter your non-root username:"

read hdir


echo "Creating config files..."

mkdir /home/root/.xpost
mkdir /home/$hdir/.xpost
chmod $hidr+rw /home/$hdir/.xpost
cp xpost.conf /home/$hdir/.xpost
cp xpost.conf /home/root/.xpost
chmod $hdir+rw /home/$hdir/.xpost/xpost.conf

echo "Moving files"

cp xpostul8.tcl /usr/local/bin/xpostul8
cp tdict.tcl /usr/local/bin/tdict
cp ticklecal /usr/local/bin/ticklecal
cp tcalcu.tcl /usr/local/bin/tcalcu

echo "Configuring permissions"

cd /usr/local/bin
chmod a+x xpostul8
chmod a+x tdict
chmod a+x ticklecal
chmod a+x tcalcu

echo "Installation complete!"
echo "Thank you, $hdir, for using Xpostulate"
echo "To run Xpostulate, in terminal type xpostul8, or make an icon/menu item/short cut to /usr/local/bin/xpostul8"
echo "Enjoy!"

fi
exit
