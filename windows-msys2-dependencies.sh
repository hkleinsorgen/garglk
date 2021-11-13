#!/bin/bash

# Install packages required for building Gargoyle on Windows with MSYS2
# Set GARGOYLE64 to install 64 bit dependencies. Additionally set GARGOYLE_UCRT to use UCRT instead of MSVCRT for 64 bit builds
# (see https://www.msys2.org/docs/environments/ for more details)

if [[ -n "${GARGOYLE64}" ]]
then
    if [[ -n "${GARGOYLE_UCRT}" ]]
    then
        ARCH=mingw-w64-ucrt-x86_64
    else
        ARCH=mingw-w64-x86_64
    fi
else
   ARCH=mingw-w64-i686
fi
pacman -S --needed --noconfirm  \
    ${ARCH}-cmake  \
    ${ARCH}-fontconfig  \
    ${ARCH}-freetype  \
    ${ARCH}-gcc  \
    ${ARCH}-libmodplug  \
    ${ARCH}-libjpeg-turbo  \
    ${ARCH}-libogg  \
    ${ARCH}-libopenmpt  \
    ${ARCH}-libpng  \
    ${ARCH}-libpng  \
    ${ARCH}-libvorbis  \
    ${ARCH}-libvorbis  \
    ${ARCH}-mpg123  \
    ${ARCH}-ninja  \
    ${ARCH}-nsis \
    ${ARCH}-pkgconf  \
    ${ARCH}-qt5  \
    ${ARCH}-SDL2  \
    ${ARCH}-SDL2_mixer  \
    ${ARCH}-zlib
