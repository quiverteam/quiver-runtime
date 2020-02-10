#!/bin/bash

export OLD_PATH="$PATH"
export OLD_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"

# Set defaults
if [ -z $QUIVER_RUNTIME_AMD64 ]; then
	export QUIVER_RUNTIME_AMD64="/valve/quiver-runtime/quiver-runtime-amd64"
	echo "QUIVER_RUNTIME_AMD64 not set, falling back to $QUIVER_RUNTIME_AMD64"
fi

[ ! -d $QUIVER_RUNTIME_AMD64 ] && echo "Quiver runtime directory does not exist." && exit 1

# Set the LD_LIBRARY_PATH
export LD_LIBRARY_PATH="$QUIVER_RUNTIME_AMD64/usr/lib/x86_64-linux-gnu:$QUIVER_RUNTIME_AMD64/lib/x86_64-linux-gnu/:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$QUIVER_RUNTIME_AMD64/lib/:$QUIVER_RUNTIME_I386/lib64/:$QUIVER_RUNTIME_AMD64/usr/lib:$QUIVER_RUNTIME_AMD64/usr/lib64:$LD_LIBRARY_PATH"

# Set our path
export PATH="$QUIVER_RUNTIME_AMD64/bin/:$QUIVER_RUNTIME_AMD64/usr/bin:$PATH"
