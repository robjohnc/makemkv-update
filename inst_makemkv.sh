#!/bin/bash

function show_help {
echo
echo
echo "MakeMKV Installer/Updater"
echo "========================="
echo
echo
echo "Options:"
echo
echo "-h | --help                               Show this help screen"
echo
echo "-f | --force                              Force Reinstall"
echo
echo "-k | --key                                Show MakeMKV Trial Key and exit"
echo
echo "-v | --version                            Print current/latest version then exit"
echo
echo "-i <version> |--install <version>         Install Version specified by <version>"
echo
exit 0
}

function get_vars {
version=$(curl "http://www.makemkv.com/forum2/viewtopic.php?f=3&t=224" -s | awk 'FNR == 160 {print $4}')
MAKEMKV_KEY=$(curl "http://www.makemkv.com/forum2/viewtopic.php?f=5&t=1053" -s | awk 'FNR == 243 {print $57}' | cut -c 21-88)
makemkvcur=$(makemkvcon v 2>/dev/null):
currver=${makemkvcur:9:6}
}

function inst_mkmkv {
if [ "$MAKEMKV_KEY" == "" ]; then
	get_vars
fi
read -p "Please confirm: Would you like to update? (y/n)" -n 1 -r
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
exit 0
}


function get_ver {
	get_vars
	echo 
	echo
	echo "MakeMKV installer/updater"
	echo "========================="
	echo

	echo "Current version installed: $currver"
	echo "Latest version available: $version"
	echo

	if [ "$currver" == "$version" ]; then
		echo "You already have the latest version."
		
		if [ "$force" != "True" ]; then
			echo "Use -f or --force to force install"
			exit 0
		else
			inst_mkmkv
		fi
	else
		inst_mkmkv
	fi
}

function get_key {
if [ "$showkey" == "True" ]; then
#    MAKEMKV_KEY=$(curl "http://www.makemkv.com/forum2/viewtopic.php?f=5&t=1053" -s | awk 'FNR == 243 {print $57}' | cut -c 21-88)
    get_vars
    echo "The MakeMKV Key is: $MAKEMKV_KEY"
    exit 0
fi
}

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -f|--force)
    force="True"
    get_ver
    ;;
    -h|-\?|--help)
    show_help
    ;;
    -k|--key)
    showkey="True"
    get_key
    ;;
    -v|--ver)
    get_ver
    ;;
    -i|--install)
    get_vars
    version="$2"
    inst_mkmkv
    shift
    ;;
    *)
    show_help        # unknown option
    ;;
esac
shift # past argument or value
done

get_ver
