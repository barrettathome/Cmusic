#!/usr/bin/env bash
DISTNAME=cmusicai-1.0.1
MAKEOPTS="-j4"
BRANCH=master

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo"
   exit 1
fi

export PATH_orig=$PATH

echo "Building Linux ARM binaries"

cd ~/Cmusic/depends
make HOST=arm-linux-gnueabihf $MAKEOPTS
cd ~/Cmusic
export PATH=$PWD/depends/arm-linux-gnueabihf/native/bin:$PATH
./autogen.sh
CONFIG_SITE=$PWD/depends/arm-linux-gnueabihf/share/config.site ./configure --prefix=/ --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-glibc-back-compat --enable-reduce-exports --disable-bench --disable-gui-tests CFLAGS="-O2 -g" CXXFLAGS="-O2 -g" LDFLAGS="-static-libstdc++"
make $MAKEOPTS
make -C src check-security
mkdir -p ~/linuxARM
make install DESTDIR=~/linuxARM/$DISTNAME
cd ~/linuxARM
find . -name "lib*.la" -delete
find . -name "lib*.a" -delete
rm -rf $DISTNAME/lib/pkgconfig
find ${DISTNAME}/bin -type f -executable -exec ../Cmusic/contrib/devtools/split-debug.sh {} {} {}.dbg \;
find ${DISTNAME}/lib -type f -exec ../Cmusic/contrib/devtools/split-debug.sh {} {} {}.dbg \;
find $DISTNAME/ -not -name "*.dbg" | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > ~/release/$DISTNAME-arm-linux-gnueabihf.tar.gz
cd ~/Cmusic
rm -rf ~/linuxARM
make clean
export PATH=$PATH_orig
