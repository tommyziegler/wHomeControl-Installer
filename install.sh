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

#Install NodeJS
NODEJS_DIR="/opt/node"
if [ -d $NODEJS_DIR ];
then
   echo "NodeJS is already installed [skip]"
else
   echo "NodeJS does not exist on Pi [install...]."
   
   NODEJS_VERSION=v0.10.22

   wget http://nodejs.org/dist/$NODEJS_VERSION/node-$NODEJS_VERSION-linux-arm-pi.tar.gz
   tar xvzf node-$NODEJS_VERSION-linux-arm-pi.tar.gz
   
   mkdir -p $NODEJS_DIR
   sudo cp -r node-$NODEJS_VERSION-linux-arm-pi/* $NODEJS_DIR
   
   
   rm -rf node-$NODEJS_VERSION-linux-arm-pi
   rm node-$NODEJS_VERSION-linux-arm-pi.tar.gz
   
   
   # Not needed yet
   #
   # NODE_JS_HOME="/opt/node"
   # PATH="$PATH:$NODE_JS_HOME/bin"
   # export PATH
   
fi

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
   echo "wHomeControl is already installed [check updates]"
   
   cd $WHOMECONTROL_DIR
   
   cd home.pi
   git pull
   cd ..
   
   cd rcswitch-rest
   git pull
   cd ..   
   
else
   echo "wHomeControl does not exist on Pi [install...]."
   
   mkdir -p $WHOMECONTROL_DIR
   cd $WHOMECONTROL_DIR
   
   
   git clone https://github.com/tommyziegler/home.pi.git
   cd home.pi
   # nothing needed yet
   cd ..
   
   git clone https://github.com/tommyziegler/rcswitch-rest.git
   cd rcswitch-rest
   /opt/node/bin/npm install
   cd ..


fi

# 5 a.) Check and install wHomeControl Deamon
WHOMECONTROL_DEAMON_NAME="whomecontrol"
WHOMECONTROL_DEAMON_PATH="/etc/init.d/$WHOMECONTROL_DEAMON_NAME"
WHOMECONTROL_DEAMON_GITURL="https://raw.github.com/tommyziegler/wHomeControl-Installer/master/whomecontrol-deamon"
if [ -f $WHOMECONTROL_DEAMON_NAME ];
then
   echo " -> Deamon is already installed [skip]"
else
   echo " -> Deamon does not exist on Pi [install...]."

   curl -o $WHOMECONTROL_DEAMON_PATH $WHOMECONTROL_DEAMON_GITURL
   chmod +x $WHOMECONTROL_DEAMON_PATH
   update-rc.d $WHOMECONTROL_DEAMON_NAME defaults
fi
