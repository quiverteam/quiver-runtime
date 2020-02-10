#!/bin/bash

# Makes a new runtime
set -e

TOP=$(dirname "$0")

COLOR_RED="\e[91m"
COLOR_GREEN="\e[92m"
COLOR_DEFAULT="\e[39m"

function fatal-error
{
	echo -e "$COLOR_RED$1$COLOR_DEFAULT"
	exit 1
}

[ $EUID -ne 0 ] && fatal-error "Script must be run as root" 

# Check for dpkg and debootstrap
[ -z $(which debootstrap) ] && fatal-error "Debootstrap not installed; please install it to continue"
[ -z $(which dpkg) ] && fatal-error "dpkg not installed, you can only run this script from a debian-based machine (Debian, Ubuntu, Linux Mint, etc.)" 
[ -z $(which dpkg-deb) ] && fatal-error "dpkg-deb not installed; please install it to continue"

# cd to our directory
pushd $TOP

function make-runtime
{
	for arg in "$@"; do
		case $arg in
			--arch=*)
				ARCH=$(echo $arg | sed "s/--arch=//")
				shift
				;;
			--packages=*)
				PACKAGES_FILE=$(echo $arg | sed "s/--packages=//")
				shift
				;;
			--gcc-version=*)
				GCC_VER=$(echo $arg | sed "s/--gcc-version=//")
				shift 
				;;
			--clang-version=*)
				CLANG_VER=$(echo $arg | sed "s/--clang-version=//")
				shift 
				;;
			*)
				fatal-error "Unknown arg"
				;;
		esac
	done

	case $ARCH in
		i386)
			PLATLIB="i386-linux-gnu"
			ARCHC="I386"
			;;
		amd64)
			PLATLIB="x86_64-linux-gnu"
			ARCHC="AMD64"
			;;
		arm64)
			PLATLIB=""
			ARCHC="AARCH64"
			;;
		*)
			fatal-error "invalid arch, please choose from: i386,amd64,arm64"
			;;
	esac

	# Delete old temp
	[ -d "$TOP/temp" ] && rm -rf "$TOP/temp"
	# Delete old runtime dir
	[ -d "$TOP/quiver-runtime-$ARCH" ] && rm -rf "$TOP/quiver-runtime-$ARCH"

	[ -z $PACKAGES_FILE ] && PACKAGES_FILE="packages.txt"
	for package in $(cat "$PACKAGES_FILE" | tr '\n', ' '); do
		PACKAGES="${PACKAGES},$package"
	done
	PACKAGES="${PACKAGES},gcc-$GCC_VER,g++-$GCC_VER,clang-$CLANG_VER,llvm-$CLANG_VER"

	if [ -d "$TOP/quiver-runtime-$ARCH" ]; then
		echo "quiver-runtime exists, deleting..."
		rm -rf "$TOP/quiver-runtime-$ARCH"
	fi

	debootstrap --arch=$ARCH --download-only --include=$PACKAGES sid "$TOP/temp/"


	for pkg in $(ls "$TOP/temp/var/cache/apt/archives/" -p | grep -v /); do
		echo "unpacking $pkg"
		dpkg-deb -x "$TOP/temp/var/cache/apt/archives/$pkg" "$TOP/quiver-runtime-$ARCH"
	done

	# Removed things we dont need
	rm -rf "$TOP/quiver-runtime-$ARCH/sys"
	rm -rf "$TOP/quiver-runtime-$ARCH/root"
	rm -rf "$TOP/quiver-runtime-$ARCH/proc"
	rm -rf "$TOP/quiver-runtime-$ARCH/home"
	rm -rf "$TOP/quiver-runtime-$ARCH/dev"
	rm -rf "$TOP/quiver-runtime-$ARCH/run"
	rm -rf "$TOP/quiver-runtime-$ARCH/boot"
	rm -rf "$TOP/quiver-runtime-$ARCH/tmp"
	rm -rf "$TOP/quiver-runtime-$ARCH/bin"
	rm -rf "$TOP/quiver-runtime-$ARCH/sbin"
	mkdir -p "$TOP/quiver-runtime-$ARCH/bin"

	# Symlinks to certain applications
	ln -s "$TOP/quiver-runtime-$ARCH/usr/bin/gcc-$GCC_VER" "$TOP/quiver-runtime-$ARCH/usr/bin/gcc"
	ln -s "$TOP/quiver-runtime-$ARCH/usr/bin/g++-$GCC_VER" "$TOP/quiver-runtime-$ARCH/usr/bin/g++"
	ln -s "$TOP/quiver-runtime-$ARCH/usr/bin/clang-$CLANG_VER" "$TOP/quiver-runtime-$ARCH/usr/bin/clang"
	ln -s "$TOP/quiver-runtime-$ARCH/usr/bin/clang++-$CLANG_VER" "$TOP/quiver-runtime-$ARCH/usr/bin/clang++"

	# Copy in the template shell scripts for our toolchain
	EXTRA_LIB_DIRS="-L\$QUIVER_RUNTIME_$ARCHC/lib/ -L\$QUIVER_RUNTIME_$ARCHC/lib/$PLAT_LIB -L\$QUIVER_RUNTIME_$ARCHC/lib/ -L\$QUIVER_RUNTIME_$ARCHC/lib/$PLAT_LIB"
	EXTRA_INC_DIRS="-I\$QUIVER_RUNTIME_$ARCHC/usr/include"
	echo -e "#!/bin/bash\nshift;\n\$QUIVER_RUNTIME_$ARCHC/usr/bin/gcc-$GCC_VER $EXTRA_LIB_DIRS $EXTRA_INC_DIRS \$@\n" > "$TOP/quiver-runtime-$ARCH/bin/gcc"
	chmod +rwx "$TOP/quiver-runtime-$ARCH/bin/gcc"

	echo -e "#!/bin/bash\nshift;\n\$QUIVER_RUNTIME_$ARCHC/usr/bin/g++-$GCC_VER $EXTRA_LIB_DIRS $EXTRA_INC_DIRS \$@\n" > "$TOP/quiver-runtime-$ARCH/bin/g++"
	chmod +rwx "$TOP/quiver-runtime-$ARCH/bin/g++"

	echo -e "#!/bin/bash\nshift;\n\$QUIVER_RUNTIME_$ARCHC/usr/bin/clang-$CLANG_VER $EXTRA_LIB_DIRS $EXTRA_INC_DIRS \$@\n" > "$TOP/quiver-runtime-$ARCH/bin/clang"
	chmod +rwx "$TOP/quiver-runtime-$ARCH/bin/clang"

	echo -e "#!/bin/bash\nshift;\n\$QUIVER_RUNTIME_$ARCHC/usr/bin/clang++-$CLANG_VER $EXTRA_LIB_DIRS $EXTRA_INC_DIRS \$@\n" > "$TOP/quiver-runtime-$ARCH/bin/clang++"
	chmod +rwx "$TOP/quiver-runtime-$ARCH/bin/clang++"

	# Assemblers
	echo -e "#!/bin/bash\nshift;\n\$QUIVER_RUNTIME_$ARCHC/usr/bin/nasm $EXTRA_INC_DIRS \$@\n" > "$TOP/quiver-runtime-$ARCH/bin/nasm"
	chmod +rwx "$TOP/quiver-runtime-$ARCH/bin/nasm"

	make_app_link "cmake"
	make_app_link "perl"
	make_app_link "ar"
	make_app_link "tar"
	make_app_link "gzip"
	make_app_link "gunzip"
	make_app_link "strip"
	make_app_link "objdump"
	make_app_link "nm"
	make_app_link "objcopy"
	make_app_link "make"
	make_app_link "gcov"
	make_app_link "ranlib"
	make_app_link "readelf"
	make_app_link "llc-$CLANG_VER"
	make_app_link "llvm-link-$CLANG_VER"
	make_app_link "llvm-objcopy-$CLANG_VER"
	make_app_link "llvm-objdump-$CLANG_VER"
	make_app_link "llvm-nm-$CLANG_VER"
	make_app_link "llvm-strip-$CLANG_VER"
	make_app_link "llvm-ar-$CLANG_VER"
	make_app_link "llvm-readelf-$CLANG_VER"


	# Throw it into an archive
	echo "Packing into quiver-runtime-$ARCH.tgz"
	tar -czf "$TOP/quiver-runtime-$ARCH.tgz" "$TOP/quiver-runtime-$ARCH/"

	rm -rf "$TOP/quiver-runtime-$ARCH"
}

function make_app_link
{
	ln -s "$TOP/quiver-runtime-$ARCH/usr/bin/$1" "$TOP/quiver-runtime-$ARCH/bin/$1"
}

make-runtime --arch=i386 --packages=packages.txt --gcc-version=9 --clang-version=8
make-runtime --arch=amd64 --packages=packages.txt
#make-runtime --arch=arm64 --packages=packages-arm.txt

popd
