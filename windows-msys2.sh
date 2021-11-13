#!/bin/bash

set -ex

# This script will cross Gargoyle for Windows using MinGW and MSYS2, and
# build an installer for it using NSIS. This script makes assumptions
# about the location of MinGW, so may need to be tweaked to get it to
# properly work.
# Set GARGOYLE64 for a 64 bit build. Additionally set GARGOYLE_UCRT to use UCRT instead of MSVCRT for 64 bit builds
# (see https://www.msys2.org/docs/environments/ for more details)

if [[ -n "${GARGOYLE64}" ]]
then
    if [[ -n "${GARGOYLE_UCRT}" ]]
    then
        target=ucrt64
    else
        target=mingw64
    fi
    libgcc=seh
else
    target=mingw32
    libgcc=dw2
fi

mingw_location=/${target}

ver=$(${mingw_location}/bin/gcc --version | head -1 | awk '{print $3}')

if [ -d build ]; then rm -rf build; fi
mkdir -p build/dist
(
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
ninja
)

cp "${mingw_location}/bin/libstdc++-6.dll" "build/dist"
cp "${mingw_location}/bin/libwinpthread-1.dll" "build/dist"
cp "${mingw_location}/bin/libgcc_s_${libgcc}-1.dll" "build/dist"
cp "build/garglk/gargoyle.exe" "build/dist"
cp "build/garglk/libgarglk.dll" "build/dist"

for dll in Qt5Core Qt5Gui Qt5Widgets SDL2 SDL2_mixer libfreetype-6 libjpeg-8 libmodplug-1 libmpg123-0 libogg-0 libopenmpt-0 libpng16-16 libvorbis-0 libvorbisfile-3 zlib1
do
    cp "${mingw_location}/bin/${dll}.dll" "build/dist"
done

find build/dist -name '*.exe' -o -name '*.dll' -exec strip --strip-unneeded {} \;

mkdir -p "build/dist/plugins/platforms"
cp "${mingw_location}/share/qt5/plugins/platforms/qwindows.dll" "build/dist/plugins/platforms"

if [[ -z "${NO_INSTALLER}" ]]
then
    makensis -V4 installer.nsi
fi
