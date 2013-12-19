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
#apt-get update
#apt-get upgrade -y

# TODO: Check if Git and Java is installed

# Check and install libWiringPi
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

# Check and install RCSwitch-Pi
RCSWITCH_REV="/opt/rcswitch-pi/sendRev"
RCSWITCH_ELRO="/opt/rcswitch-pi/sendElro"
if [[ -f $RCSWITCH_REV && -f $RCSWITCH_ELRO ]];
then
   echo "RCSwitch-Pi is already installed [skip]"
else
   echo "RCSwitch-Pi does not exist on Pi [install...]."
   
   # install rcswitch-pi
   git clone https://github.com/tommyziegler/rcswitch-pi
   cd rcswitch-pi
   make
   mkdir -p /opt/rcswitch-pi
   mv sendRev sendElro /opt/rcswitch-pi/
   cd ..
   rm -rf rcswitch-pi
fi

# 5.) Check and install wHomeControl
WHOMECONTROL_DIR="/opt/wHomeControl"
if [ -d $WHOMECONTROL_DIR ];
then
   echo "wHomeControl is already installed [skip]"
else
   echo "wHomeControl does not exist on Pi [install...]."
   
   mkdir -p $WHOMECONTROL_DIR
   cd $WHOMECONTROL_DIR
   git clone https://github.com/tommyziegler/home.pi.git
   git clone https://github.com/tommyziegler/rcswitch-rest.git

   # 5 a.) Check and install wHomeControl Deamon
   WHOMECONTROLDEAMON="/etc/init.d/whomecontrol"
   WHOMECONTROL_GITURL="https://raw.github.com/tommyziegler/wHomeControl-Installer/master/whomecontrol-deamon"
   if [ -f $WHOMECONTROLDEAMON ];
   then
      echo " -> Deamon is already installed [skip]"
   else
      echo " -> Deamon does not exist on Pi [install...]."

      curl -o $WHOMECONTROLDEAMON $WHOMECONTROL_GITURL
      update-rc.d whomecontrol defaults
      #mkdir -p $WHOMECONTROLDEAMON
   fi
fi
