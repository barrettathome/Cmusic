#!/usr/bin/env bash
DISTNAME=cmusicai-1.0.1
MAKEOPTS="-j4"
BRANCH=master

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo"
   exit 1
fi

export PATH_orig=$PATH

echo "Building Linux 32 binaries"

cd ~/
mkdir -p ~/wrapped/extra_includes/i686-pc-linux-gnu
ln -s /usr/include/x86_64-linux-gnu/asm ~/wrapped/extra_includes/i686-pc-linux-gnu/asm

for prog in gcc g++; do
rm -f ~/wrapped/${prog}
cat << EOF > ~/wrapped/${prog}
#!/usr/bin/env bash
REAL="`which -a ${prog} | grep -v $PWD/wrapped/${prog} | head -1`"
for var in "\$@"
do
  if [ "\$var" = "-m32" ]; then
    export C_INCLUDE_PATH="$PWD/wrapped/extra_includes/i686-pc-linux-gnu"
    export CPLUS_INCLUDE_PATH="$PWD/wrapped/extra_includes/i686-pc-linux-gnu"
    break
  fi
done
\$REAL \$@
EOF
chmod +x ~/wrapped/${prog}
done

export PATH=$PWD/wrapped:$PATH
export HOST_ID_SALT="$PWD/wrapped/extra_includes/i386-linux-gnu"
cd ~/Cmusic/depends
make HOST=i686-pc-linux-gnu $MAKEOPTS
unset HOST_ID_SALT
cd ~/Cmusic
export PATH=$PWD/depends/i686-pc-linux-gnu/native/bin:$PATH
./autogen.sh
CONFIG_SITE=$PWD/depends/i686-pc-linux-gnu/share/config.site ./configure --prefix=/ --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-glibc-back-compat --enable-reduce-exports --disable-bench --disable-gui-tests CFLAGS="-O2 -g" CXXFLAGS="-O2 -g" LDFLAGS="-static-libstdc++"
make $MAKEOPTS
make -C src check-security
make -C src check-symbols
mkdir -p ~/linux32
make install DESTDIR=~/linux32/$DISTNAME
cd ~/linux32
find . -name "lib*.la" -delete
find . -name "lib*.a" -delete
rm -rf $DISTNAME/lib/pkgconfig
find ${DISTNAME}/bin -type f -executable -exec ../Cmusic/contrib/devtools/split-debug.sh {} {} {}.dbg \;
find ${DISTNAME}/lib -type f -exec ../Cmusic/contrib/devtools/split-debug.sh {} {} {}.dbg \;
find $DISTNAME/ -not -name "*.dbg" | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > ~/release/$DISTNAME-i686-pc-linux-gnu.tar.gz
cd ~/Cmusic
rm -rf ~/linux32
rm -rf ~/wrapped
make clean
export PATH=$PATH_orig
