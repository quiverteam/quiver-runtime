#!/bin/bash

pushd $(dirname $(realpath $0))

# Automatic download of the latest runtime build

read -p "Runtime release to download (i386, amd64): " RELTYPE

case $RELTYPE in
	i386)
		NAME=quiver-runtime-i386.tgz
		TYPE="I386"
		;;
	amd64)
		NAME=quiver-runtime-amd64.tgz
		TYPE="AMD64"
		;;
	*)
		echo "Error: unknown release type: $RELTYPE"
		popd 
		exit 1
		;;
esac

LATEST=`curl --silent "https://github.com/quiverteam/quiver-runtime/releases/latest" | sed 's#.*tag/\(.*\)\".*#\1#'`

echo "Downloading latest runtime version $LATEST"

curl -L -o $NAME https://github.com/quiverteam/quiver-runtime/releases/download/$LATEST/$NAME

echo "Extracting $LATEST..."
tar xf $NAME 

echo "...done"

read -p "Would you like to add env vars to your .bashrc? [yN]: " $YN

case $YN in
	y*)
		echo "export QUIVER_RUNTIME_$TYPE=$(pwd)/$(echo $NAME | sed "s/\.tgz//g")" > ~/.bashrc
		;;
	*)
		;;
esac


echo "Run chown on $(echo $NAME | sed "s/\.tgz//g") in order for it to work"

popd 
