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
export PATH=${mingw_location}/bin:$PATH

ver=$(${mingw_location}/bin/gcc --version | head -1 | awk '{print $3}')

if [ -d build ]; then rm -rf build; fi
mkdir -p build/dist
(
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -WITH_BABEL=true -DBUILD_SHARED_LIBS=true -DWITH_INTERPRETERS=true -DWITH_LAUNCHER=true -DSOUND=true
ninja
)

cp "${mingw_location}/bin/libstdc++-6.dll" "build/dist"
cp "${mingw_location}/bin/libwinpthread-1.dll" "build/dist"
cp "${mingw_location}/bin/libgcc_s_${libgcc}-1.dll" "build/dist"
cp "build/garglk/gargoyle.exe" "build/dist"
cp "build/garglk/libgarglk.dll" "build/dist"

# The list of required DLLs was determined by running 'ldd build/dist/gargoyle.exe' after compilation. It might change in future versions of MSYS
for dll in Qt5Core Qt5Core Qt5Gui Qt5Widgets libbrotlicommon libbrotlidec libbz2-1 libdouble-conversion libfreetype-6 libgcc_s_seh-1 libglib-2.0-0 libgraphite2 libharfbuzz-0 libiconv-2 libicudt69 libicuin69 libicuuc69 libintl-8 libjpeg-8 libmd4c libpcre-1 libpcre2-16-0 libpng16-16 libstdc++-6 libwinpthread-1 libwinpthread-1 libzstd zlib1
do
    cp "${mingw_location}/bin/${dll}.dll" "build/dist"
done

for interpreter in terps tads
do
    if [ -d "build/${interpreter}" ]; then
        cp "build/${interpreter}/"*.exe "build/dist"
    fi
done


find build/dist -name '*.exe' -o -name '*.dll' -exec strip --strip-unneeded {} \;

mkdir -p "build/dist/platforms"
cp "${mingw_location}/share/qt5/plugins/platforms/qwindows.dll" "build/dist/platforms"

if [[ -z "${NO_INSTALLER}" ]]
then
    makensis -V4 installer.nsi
fi
