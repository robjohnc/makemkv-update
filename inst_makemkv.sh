#!/bin/bash

version=$(curl "http://www.makemkv.com/forum2/viewtopic.php?f=3&t=224" -s | awk 'FNR == 160 {print $4}')
MAKEMKV_KEY=$(curl "http://www.makemkv.com/forum2/viewtopic.php?f=5&t=1053" -s | awk 'FNR == 243 {print $57}' | cut -c 21-88)
makemkvcur=$(makemkvcon v 2>/dev/null):
#echo "$makemkvcur"
currver=${makemkvcur:9:6}
if [ "$1" == "key" ]; then
#    echo "Usage: $0 $version"
#    echo "to download and install MakeMKV $version"
    #echo "The latest version available is $version"
#    echo "Your current version is $currver"
    echo "The MakeMKV Key is: $MAKEMKV_KEY"
    exit 1
fi
echo "Current version installed: $currver"
echo "Latest version available: $version"
echo
read -p "Would you like to update? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # do dangerous stuff

# Collect sudo credentials
sudo -v

VER="$version"
TMPDIR=`mktemp -d`

# Install prerequisites
sudo apt-get install build-essential pkg-config libc6-dev libssl-dev libexpat1-dev libavcodec-dev libgl1-mesa-dev libqt4-dev

# Install this version of MakeMKV
pushd $TMPDIR

for PKG in bin oss; do
    PKGDIR="makemkv-$PKG-$VER"
    PKGFILE="$PKGDIR.tar.gz"

    wget "http://www.makemkv.com/download/$PKGFILE"
    tar xzf $PKGFILE

    pushd $PKGDIR
    # pre-1.8.6 version
    if [ -e "./makefile.linux" ]; then
        make -f makefile.linux
        sudo make -f makefile.linux install

    # post-1.8.6 version
    else
        if [ -e "./configure" ]; then
            ./configure
        fi
        make
        sudo make install
    fi

    popd
done

popd

# Remove temporary directory
if [ -e "$TMPDIR" ]; then rm -rf $TMPDIR; fi

echo "The MakeMKV Key is: $MAKEMKV_KEY"
fi
