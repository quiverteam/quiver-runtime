#!/bin/bash

# Store old path and ld lib path
export OLD_PATH="$PATH"
export OLD_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"

# Set defaults
if [ -z $QUIVER_RUNTIME_I386 ]; then
	export QUIVER_RUNTIME_I386="/valve/quiver-runtime/quiver-runtime-i386"
	echo "QUIVER_RUNTIME_I386 not set, falling back to $QUIVER_RUNTIME_I386"
fi

[ ! -d $QUIVER_RUNTIME_I386 ] && echo "Quiver runtime directory does not exist." && exit 1

# Set the LD_LIBRARY_PATH
export LD_LIBRARY_PATH="$QUIVER_RUNTIME_I386/usr/lib/i386-linux-gnu:$QUIVER_RUNTIME_I386/lib/i386-linux-gnu/:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$QUIVER_RUNTIME_I386/lib/:$QUIVER_RUNTIME_I386/lib32/:$QUIVER_RUNTIME_I386/usr/lib:$QUIVER_RUNTIME_I386/usr/lib32:$LD_LIBRARY_PATH"

# Set our path
export PATH="$QUIVER_RUNTIME_I386/bin/:$QUIVER_RUNTIME_I386/usr/bin:$PATH"

