#!/bin/bash
#Buzzcoin-Pi Installer v0.4
# based on NEBL-Pi-Installer

echo "================================================================================"
echo "================= Welcome to the Ofiicial Buzzcoin-Pi Installer ================"
echo "This script will install all necessary dependencies to run or compile buzzcoind"
echo "and/or buzzcoin-qt, download the binaries or source code, and then optionally"
echo "compile buzzcoind, buzzcoin-qt or both. buzzcoind and/or buzzcoin-qt will be"
echo "copied to your Desktop when done."
echo ""
echo "Note that even on a new Raspberry Pi 3, the compile process can take 30 minutes"
echo "or more for buzzcoind and over 45 minutes for buzzcoin-qt."
echo ""
echo "Pass -c to compile from source"
echo "Pass -d to install buzzcoind"
echo "Pass -q to install buzzcoin-qt"
echo "Pass -dq to install both"
echo "Pass -x to disable QuickSync"
echo ""
echo "You can safely ignore all warnings during the compilation process, but if you"
echo "run into any errors, please report them"
echo "================================================================================"

USAGE="$0 [-d | -q | -c | -dqc]"

BUZZCOINDIR=~/buzzcoin-source
DEST_DIR=~/Desktop/
BUZZCOIND=false
BUZZCOINQT=true
COMPILE=true
JESSIE=false
QUICKSYNC=true

# check if we have a Desktop, if not, use home dir
if [ ! -d "$DEST_DIR" ]; then
    DEST_DIR=~/
fi

# check if we have ~/.buzzcoin
if [ ! -d "~/.buzzcoin" ]; then
    mkdir ~/.buzzcoin
fi

# check if we are running on Raspbian Jessie
if grep -q jessie "/etc/os-release"; then
    echo "Jessie detected, following Jessie install routine"
    JESSIE=true
fi

while getopts ':dqcx' opt
do
    case $opt in
        c) echo "Will compile all from source"
           COMPILE=true;;
        d) echo "Will Install buzzcoind"
	       BUZZCOIND=true;;
        q) echo "Will Install buzzcoin-qt"
	       BUZZCOINQT=true;;
        x) echo "Disabling Quick Sync and using traditional sync"
           QUICKSYNC=false;;
        \?) echo "ERROR: Invalid option: $USAGE"
        echo "-c            Compile all from source (default true)"
	    echo "-d            Install buzzcoind (default false)"
	    echo "-q            Install buzzcoin-qt (default true)"
	    echo "-dq           Install both"
        echo "-x            Disable QuickSync"
            exit 1;;
    esac
done

# get sudo
if [ "$COMPILE" = true ]; then
    sudo whoami
fi

if [ "$QUICKSYNC" = true ]; then
    echo "Will use QuickSync"
fi

# update and install dependencies
sudo apt-get update -y
sudo apt-get install build-essential -y
sudo apt-get install libboost-all-dev -y
sudo apt-get install libdb++-dev -y
sudo apt-get install libminiupnpc-dev -y
sudo apt-get install libqrencode-dev -y
if [ "$BUZZCOINQT" = true ]; then
    sudo apt-get install qt5-default -y
    sudo apt-get install qt5-qmake -y
    sudo apt-get install qtbase5-dev-tools -y
    sudo apt-get install qttools5-dev-tools -y
fi
if [ "$JESSIE" = true ]; then
    sudo apt-get install libssl-dev -y
else
    sudo aptitude install libssl1.0-dev -y
fi
sudo apt-get install wget -y
sudo apt-get install git -y

if [ "$COMPILE" = true ]; then
    # delete our src folder and then remake it
    sudo rm -rf $BUZZCOINDIR
    mkdir $BUZZCOINDIR
    cd $BUZZCOINDIR

    # clone our repo, then create some necessary directories
    git clone https://github.com/buzzcoin-project/BUZZ
fi

# start our build
if [ "$BUZZCOIND" = true ]; then
    if [ "$COMPILE" = true ]; then
        make "STATIC=1" -B -w -f makefile.unix
        strip buzzcoind
        cp ./buzzcoind $DEST_DIR
    else
        cd $DEST_DIR
        VERSION=$( wget -qO- "https://api.github.com/repos/buzzcoin-project/BUZZ/releases/latest" | grep -o 'tag/[v.0-9]*' | awk -F/ '{print $2}' )
        wget --quiet https://github.com/buzzcoin-project/BUZZ/releases/download/$VERSION/buzzcoind-RaspbianStretch-v$VERSION.zip
        unzip buzzcoind-RaspbianStretch*
        mv buzzcoind buzzcoind
        sudo chmod 775 buzzcoind
    fi
    if [ ! -f ~/.buzzcoin/buzzcoin.conf ]; then
        echo rpcuser=$USER >> ~/.buzzcoin/buzzcoin.conf
        RPCPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        echo rpcpassword=$RPCPASSWORD >> ~/.buzzcoin/buzzcoin.conf
        echo rpcallowip=127.0.0.1 >> ~/.buzzcoin/buzzcoin.conf
    fi
fi
cd ..
if [ "$BUZZCOINQT" = true ]; then
    if [ "$COMPILE" = true ]; then
        wget 'https://fukuchi.org/works/qrencode/qrencode-3.4.4.tar.bz2'
        tar -xvf qrencode-3.4.4.tar.bz2 
        cd qrencode-3.4.4/
        ./configure --enable-static --disable-shared --without-tools --disable-dependency-tracking
        sudo make install
	    cd ..
        qmake "USE_UPNP=1" "USE_QRCODE=1" "RELEASE=1" buzzcoin-qt.pro
        make -B -w
        cp ./buzzcoin-qt $DEST_DIR
    else
        cd $DEST_DIR
        VERSION=$( wget -qO- "https://api.github.com/repos/buzzcoin-project/BUZZ/releases/latest" | grep -o 'tag/[v.0-9]*' | awk -F/ '{print $2}' )
        wget --quiet https://github.com/buzzcoin-project/BUZZ/releases/download/$VERSION/BuzzCoin-Qt-RaspbianStretch-v$VERSION.zip
        unzip BuzzCoin-Qt-RaspbianStretch*
        mv buzzcoin-qt* buzzcoin-qt
        sudo chmod 775 buzzcoin-qt
    fi
fi

if [ "$QUICKSYNC" = true ]; then
    if [ ! -f ~/.buzzcoin/blk0001.dat ]; then
        echo "Downloading Blockchain Data for QuickSync"

        cd $HOME
        mkdir buzzcoin-blockchain-data
        cd buzzcoin-blockchain-data
        wget 'https://download.buzzcoin.info/bootstrap-latest.zip'
        mkdir data
        cd data
        unzip ../bootstrap-latest.zip
        cp -R ./data/* $HOME/.buzzcoin/
        cd ../..
        rm -rf buzzcoin-blockchain-data
    fi
fi

echo ""
echo "================================================================================"
echo "======================== Buzzcoin-Pi Installer Finished ========================"
echo ""
echo "If there were no errors during download or compilation buzzcoind and/or buzzcoin-qt"
echo "should now be on your desktop (if you are using a CLI-only version of Raspbian"
echo "without a desktop the binaries have been copied to your home directory instead)."
echo "Enjoy!"
echo ""
echo "================================================================================"
