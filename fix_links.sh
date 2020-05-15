#!/bin/bash

NAMES="quiver-runtime-i386 quiver-runtime-amd64"

for NAME in $NAMES; do 
	[ -d $NAME ] || continue;

	# Fixup all the symlinks 
	FILES=$(find ./$NAME -type l)

	for file in $FILES; do
		# Check if the link is borked
		if [ ! -e "$file" ]; then
			old=$(readlink $file)
			ln -sfn $PWD/$NAME/$old $file
			echo "Fixed link $file"
		fi 
	done 
done 
