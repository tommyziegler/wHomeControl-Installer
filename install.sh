#!/bin/sh
# install.sh
#
# This is the installation script for wHomeControl on a Rasbian RaspberryPi system.
#
# The script is doing following things
#  -> Updating the system
#  -> Installing wiringPi library (gpio-lib)
#  -> Installing rcswitch-pi apps (api to access remote switches Elro and Rev)


# Make sure only root can run this script
if [ $(id -u) != 0 ]; then
   echo "This script must be run as root"
   sudo "$0" "$@"
   exit
fi

# update the system
apt-get update
apt-get upgrade -y

# TODO: Check if Git and Java is installed


WIRINGPI="/usr/local/lib/libwiringPi.so"

if [ -f $WIRINGPI ];
then
   echo "wiringPi is already installed [skip]"
else
   echo "wiringPi does not exist on Pi [install...]."
   
   # install wiringPi
   git clone git://git.drogon.net/wiringPi
   cd wiringPi
   ./build
   cd ..
   rm -rf wiringPi   
   
fi

exit


# install rcswitch-pi
git clone https://github.com/tommyziegler/rcswitch-pi
cd rcswitch-pi
make
mkdir -p /opt/rcswitch-pi
mv sendRev sendElro /opt/rcswitch-pi/
cd ..
rm -rf rcswitch-pi
