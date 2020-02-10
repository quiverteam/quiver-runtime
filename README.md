## Quiver Runtime

This is a blatant copy of the steam-runtime! This runtime can be used to build quiver reliably on any Linux distro.

### Installation

First clone this repo to wherever you want and download a release tarball for the runtime.

Now, extract the tarball to some directory using `tar -xf quiver-runtime-i386.tgz` 

You'll need to change ownership of the files using `sudo chown username:username -R quiver-runtime-i386`

Finally, you'll need to set a pair of env vars that point to your install directory. Place this into your bashrc:

```bash
export QUIVER_RUNTIME_I386=/path/to/runtime/top
export QUIVER_RUNTIME_AMD64=/path/to/runtime/bot
```

Make sure to source your bashrc after adding these lines.

### Usage

To use the runtime, source either `env-i386.sh` or `env-amd64.sh` to bring the changes into your shell.
Now, executing some commands such as `gcc`, `clang`, `tar` will actually invoke programs inside the runtime.

Building programs using `gcc` after sourcing `env-xxx.sh` will link the program against libraries within the runtime, ensuring portability.

To restore your shell to the previous state, source `restore.sh`, and probably your bashrc again.

### Rolling your own

The scripts for building the runtime are pretty portable, though a bit odd. You can roll your own custom runtime by editing `packages.txt` and `make-runtime.sh`. 
In the future this will be made easier.

### Notes

This is pretty new, so it'll need a lot of tweaks. 

A runtime for aarch32 and aarch64 is in the works, just don't have enough time to test it yet.
