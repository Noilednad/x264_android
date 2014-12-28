#!/bin/bash
#  
#  by Noiled <Noiled@163.com>
#


TARGET=`pwd`/out/
SRC=`pwd`/x264

if [ -d x264 ]; then
  cd x264
else
  git clone git://git.videolan.org/x264.git
  cd x264
fi

ANDROID_NDK=/root/junz/android-ndk-r9b
TOOLCHAIN=/tmp/x264
SYSROOT=$TOOLCHAIN/sysroot/
$ANDROID_NDK/build/tools/make-standalone-toolchain.sh --platform=android-14 --install-dir=$TOOLCHAIN --toolchain=arm-linux-androideabi-4.6

export PATH=$TOOLCHAIN/bin:$PATH
export CC=arm-linux-androideabi-gcc
export LD=arm-linux-androideabi-ld
export AR=arm-linux-androideabi-ar

CFLAGS="-O3 -Wall -fpic -mthumb \
  -finline-limit=300 -ffast-math \
  -Wno-psabi -Wa,--noexecstack -fomit-frame-pointer -fno-strict-aliasing \
  -DANDROID -DNDEBUG"



for version in armeabi armeabi-v7a; do

  cd $SRC

  case $version in
    armeabi-v7a)
      EXTRA="--enable-asm"
      EXTRA_CFLAGS="-march=armv7-a -mthumb -mfpu=neon -mfloat-abi=softfp -mvectorize-with-neon-quad -D__ARM_ARCH_7__ -D__ARM_ARCH_7A__"
      EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
      ;;
    armeabi)
      EXTRA="--disable-asm"
      EXTRA_CFLAGS="-march=armv5te -mtune=xscale -msoft-float"
      EXTRA_LDFLAGS=""
      ;;
    *)
      EXTRA_CFLAGS=""
      EXTRA_LDFLAGS=""
      ;;
  esac

./configure \
	--enable-static \
	--enable-shared \
	--enable-pic \
	--host=arm-linux-androideabi \
	--cross-prefix=arm-linux-androideabi- \
	--sysroot=$SYSROOT \
	--prefix=$TARGET/$version $EXTRA\
	--extra-cflags="$CFLAGS $EXTRA_CFLAGS" --extra-ldflags="$EXTRA_LDFLAGS"
  make STRIP= || exit 1
  make install || exit 1


done













