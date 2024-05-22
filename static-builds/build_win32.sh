#!/usr/bin/env bash
DISTNAME=cmusicai-1.0.1
MAKEOPTS="-j4"
BRANCH=master

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo"
   exit 1
fi

export PATH_orig=$PATH

echo "Building Windows 32 binaries"

cd ~/Cmusic/depends
make HOST=i686-w64-mingw32 $MAKEOPTS
cd ~/Cmusic
export PATH=$PWD/depends/i686-w64-mingw32/native/bin:$PATH
./autogen.sh
CONFIG_SITE=$PWD/depends/i686-w64-mingw32/share/config.site ./configure --prefix=/ --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-glibc-back-compat --enable-reduce-exports --disable-bench --disable-gui-tests CFLAGS="-O2 -g" CXXFLAGS="-O2 -g"
make $MAKEOPTS
mkdir -p ~/win32
make install DESTDIR=~/win32/$DISTNAME
cd ~/win32
find . -name "lib*.la" -delete
find . -name "lib*.a" -delete
rm -rf $DISTNAME/lib/pkgconfig
find ${DISTNAME}/bin -type f -executable -exec ../Cmusic/contrib/devtools/split-debug.sh {} {} {}.dbg \;
find ${DISTNAME}/lib -type f -exec ../Cmusic/contrib/devtools/split-debug.sh {} {} {}.dbg \;
find $DISTNAME/ -not -name "*.dbg" | sort | zip -X@9n > ~/release/$DISTNAME-win32.zip
cd ~/Cmusic
rm -rf ~/win32
make clean
export PATH=$PATH_orig
