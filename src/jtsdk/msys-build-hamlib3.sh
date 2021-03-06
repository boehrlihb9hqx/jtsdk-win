#!/bin/bash
#
# Title ........: msys-build-hamlib.sh
# Version ......: snapshot
# Description ..: Build G4WJS Hammlib3 from source
# Project URL ..: Git: git://git.code.sf.net/u/bsomervi/hamlib
# Usage ........: ./build-hamlib.sh
#
# Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
# Copyright ....: Copyright (C) 2014-2016 Joe Taylor, K1JT
# License ......: GPL-3
#
# msys-build-hamlib.sh is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation either version 3 of the
# License, or (at your option) any later version. 
#
# msys-build-hamlib.sh is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

######################################################################
#
# BUILD COMMENTS
#
# G4WJS Hamlib3 Build for JTSDK-QT using MSYS + Qt5 5.2.1 Tool-Chain
# 
# Requirements: MSYS, Autotools, Git, Bash
#               Qt5 Toolchain ( 5.2.1 tested with C/C++ 4.8.0 )
#
# MSYS includes: Git, SVN, Autotools, Bash, Make and many GNU Tools
# MSYS Link: http://sourceforge.net/projects/mingwbuilds/files/external-binary-packages/
# PACKAGE: msys+7za+wget+svn+git+mercurial+cvs-rev13.7z 2013-05-15
#
# To get changes / comits made from a previous date to today, in the 
# shell type, ( changing --since=<date> as needed )
#
# mkdir -p ~/g4wjs-hamlib/build
# git clone git://git.code.sf.net/u/bsomervi/hamlib src
# cd ~/g4wjs-hamlib/src
# git checkout integration
#
# Example-1:
# cd ~/g4wjs/src ; git log --since=1.weeks
#
# Example-2:
# git log --since=2014-04-29 --no-merges --oneline origin/integration 
#
# To create a build log:
# ./build-hamlib.sh |tee -a ~/hamlib3-build-$(date +"%d-%m-%Y").log
#
######################################################################

# Exit on errors
set -e

# General use Vars and colour
PKG_NAME=Hamlib3
today=$(date +"%d-%m-%Y")
timestamp=$(date +"%d-%m-%Y at %R")
builder=$(whoami)

# Tool-Chain Variables - Adjust to suit your QT5 Tool-Chain Locations
# $ Updated to allow for QT5.5 Testing
if [ -f C:/JTSDK/config/qt55.txt ] ;
then
	export PATH="/c/JTSDK/qt55/Tools/mingw492_32/bin:$PATH"
	TC='C:/JTSDK/qt55/Tools/mingw492_32/bin'
	PREFIX='C:/JTSDK/hamlib3-qt55'
	QTV="QT 5.5"
	BUILDD="C:/JTSDK/src/hamlib3/build-qt55"
else
	export PATH="/c/JTSDK/qt5/Tools/mingw48_32/bin:$PATH"
	TC='C:/JTSDK/qt5/Tools/mingw48_32/bin'
	PREFIX='C:/JTSDK/hamlib3'
	QTV="QT 5.2"
	BUILDD="C:/JTSDK/src/hamlib3/build"
fi


# Foreground colours
C_R='\033[01;31m'		# red
C_G='\033[01;32m'		# green
C_Y='\033[01;33m'		# yellow
C_C='\033[01;36m'		# cyan
C_NC='\033[01;37m'		# no color

# Tool Check Function ----------------------------------------------------------
tool_check() {
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y}"' CHECKING TOOL-CHAIN ( $QTV Enabled )"${C_NC}
echo '---------------------------------------------------------------'

# Setup array and perform simple version checks
echo ''
array=( 'ar' 'nm' 'ld' 'gcc' 'g++' 'ranlib' )

for i in "${array[@]}"
do
	"$i" --version >/dev/null 2>&1
	
	if [ "$?" = "1" ];
	then 
		echo -en " $i check" && echo -e ${C_R}' FAILED'${C_NC}
		echo ''
		echo ' If you have not sourced one of the two options, try'
		echo ' that first, otherwise set you path correctly:'
		echo ''
		echo ' [ 1 ] For the QT5 Tool Chain type, ..: source-qt5'
		echo ' [ 2 ] For MinGW Tool-Chain, type ....: source-mingw32'
		echo ''
		exit 1
	else
		echo -en " $i .." && echo -e ${C_G}' OK'${C_NC}
	fi
done

# List tools versions
echo -e ' Compiler ver .. '${C_G}"$(gcc --version |awk 'FNR==1')"${C_NC}
echo -e ' Binutils ver .. '${C_G}"$(ranlib --version |awk 'FNR==1')"${C_NC}
echo -e ' Libtool ver ... '${C_G}"$(libtool --version |awk 'FNR==1')"${C_NC}
echo -e ' Pkg-Config  ... '${C_G}"$(pkg-config --version)"${C_NC}

}
# Tool Check End Function ------------------------------------------------------

#--------------------------------------------------------------------#
# START MAIN SCRIPT                                                  #
#--------------------------------------------------------------------#

# Run Tool Check
cd
clsb
tool_check

if [ "$?" = "0" ];
then
echo -en " TC Path ......." && echo -e ${C_G}" $TC"${C_NC}
echo -en " TC Status ....."&& echo -e ${C_G}' OK'${C_NC}
	echo ''
else
	echo ''
	echo -e ${C_R}"TOOL CHAIN WARNING"${C_NC}
	echo 'There was a problem with the Tool-Chain.'
	echo "$0 Will now exit .."
	exit ''
	exit 1
fi

# Start Git clone
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} ' CLONING G4WJS HAMLIB3'${C_NC}
echo '---------------------------------------------------------------'
echo ''
mkdir -p $BUILDD
if [[ -f C:/JTSDK/src/hamlib3/src/autogen.sh ]];
then
	cd C:/JTSDK/src/hamlib3/src
	git pull
else
	cd C:/JTSDK/src/hamlib3
	if [ -d C:/JTSDK/src/hamlib3/src ]; then rm -rf C:/JTSDK/src/hamlib3/src ; fi
	git clone git://git.code.sf.net/u/bsomervi/hamlib src
	cd C:/JTSDK/src/hamlib3/src
	git checkout integration
fi

# Commented out for testing alternate Source Location
# Patch Hamlib autogen.sh script
# This is required for usernames with spaces
#if [[ ! -f C:/JTSDK/src/hamlib3/src/autogen-p1.mkr ]] ;
#then
#	echo ''
#	echo '---------------------------------------------------------------'
#	echo -e ${C_Y} " PATCHING AUTOGEN SCRIPT"${C_NC}
#	echo '---------------------------------------------------------------'
#	echo ''
#	echo '.. Updating User Path Variables' 
#	patch -p4 autogen.sh /scripts/msys/patch/hamlib3/autogen.p1 > /dev/null 2>&1 || {
#	echo ''
#	echo 'Autogen Patch Failed: Check JTSDK-MSYS and msys-build-hamlib3.sh script'
#	echo 'for errors and report the problem to the wsjt-devel list'
#	echo ''
#	exit 1
#	}
#	touch C:/JTSDK/src/hamlib3/src/autogen-p1.mkr
#	echo '.. Finished'
#fi

# Run configure
cd $BUILDD
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " CONFIGURING [ $PKG_NAME ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''
echo '.. This may take a several minutes to complete'

if [ "$1" = "shared" ];
then

# Build shared
echo -en ".. Build Type: " && echo -e ${C_G}'Shared'${C_NC}
echo ''
../src/autogen.sh --prefix=$PREFIX \
	--enable-shared \
	--disable-static \
	--disable-winradio \
	--without-cxx-binding \
	CC=$TC/gcc.exe \
	CXX=$TC/g++.exe \
	CFLAGS='-fdata-sections -ffunction-sections' \
	LDFLAGS='-Wl,--gc-sections'

else

# Build Static ( default )
echo -en ".. Build Type: " && echo -e ${C_G}'Static'${C_NC}
echo ''
../src/autogen.sh --prefix=$PREFIX \
	--disable-shared \
	--enable-static \
	--disable-winradio \
	--without-cxx-binding \
	CC=$TC/gcc.exe \
	CXX=$TC/g++.exe \
	CFLAGS='-fdata-sections -ffunction-sections' \
	LDFLAGS='-Wl,--gc-sections'
fi

# Make clean check
if [ -f $BUILDD/tests/rigctld.exe ];
then
	echo ''
	echo '---------------------------------------------------------------'
	echo -e ${C_Y} " RUNNING MAKE CLEAN [ $PKG_NAME ]"${C_NC}
	echo '---------------------------------------------------------------'
	echo ''
	make clean
fi

# Run make
echo ''
echo '----------------------------------------------------------------'
echo -e ${C_Y} " RUNNING MAKE ALL [ $PKG_NAME ]"${C_NC}
echo '----------------------------------------------------------------'
echo ''
make

# Run make install-strip
echo ''
echo '----------------------------------------------------------------'
echo -e ${C_Y} " INSTALLING [ $PKG_NAME ]"${C_NC}
echo '----------------------------------------------------------------'
echo ''
make install-strip

# Generate README if build finishes .. OK ..
if [ $? = "0" ];
then
	if [ -f $PREFIX/$PKG_NAME.build.info ]; then rm -f $PREFIX/$PKG_NAME.build.info ; fi

	echo ''
	echo '---------------------------------------------------------------'
	echo -e ${C_Y} " ADDING BUILD INFO [ $PKG_NAME.build.info ] "${C_NC}
	echo '---------------------------------------------------------------'
	echo ''
	echo '  Creating Hamlib3 Build Info File'

# Generate Build Info File
(
cat <<EOF

# Package Information
Build Date...: $timestamp
Builder......: $builder
Prefix.......: $PREFIX
Pkg Name.....: $PKG_NAME
Pkg Version..: development
Tool Chain...: $QTV

# Source Location and Integration
Git URL......: git://git.code.sf.net/u/bsomervi/hamlib
Git Extra....: git checkout integration'

# Configure Options <for Static>
autogen.sh --prefix=$PREFIX --disable-shared --enable-static \
--disable-winradio --without-cxx-binding CC=$TC/gcc.exe \
CXX=$TC/g++.exe CFLAGS='-fdata-sections -ffunction-sections' \
LDFLAGS='-Wl,--gc-sections'

# Configure Options <for Shared>
autogen.sh --prefix=$PREFIX --disable-static --enable-shared \
--disable-winradio --without-cxx-binding CC=$TC/gcc.exe \
CXX=$TC/g++.exe CFLAGS='-fdata-sections -ffunction-sections' \
LDFLAGS='-Wl,--gc-sections'

# Build Commands
make
make install-strip

EOF
) > $PREFIX/$PKG_NAME.build.info
	echo '  Finished'
fi

# Finished
if [ "$?" = "0" ];
then
	echo ''
	echo '----------------------------------------------------------------'
	echo -e ${C_G} " FINISHED INSTALLING [ $PKG_NAME ]"${C_NC}
	echo '----------------------------------------------------------------'
	echo ''
	touch $PREFIX/build-date-$today
	echo "  Tool-Chain........: $QTV"
	echo '  Source Location...: C:/JTSDK/src/hamlib3/src'
	echo '  Build Location....: C:/JTSDK/src/hamlib3/build'
	echo "  Install Location..: $PREFIX"
	echo "  Package Config....: $PREFIX/lib/pkgconfig/hamlib.pc"
	echo ''
	exit 0
else
	echo -e ${C_G} 'BUILD ERRORS OCCURED'${C_NC}
	echo "Check the screen and correct errors"
	echo ''
	echo "Exiting [ $0 ] with Status [ 1 ]"
	echo ''
	exit 1
fi
