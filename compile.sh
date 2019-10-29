#!/bin/bash
MXE_INCLUDE_PATH=~/src/mxe/usr/i686-w64-mingw32.static/include
MXE_LIB_PATH=~/src/mxe/usr/i686-w64-mingw32.static/lib
MXE_BIN_PATH=~/src/mxe/usr/bin

export PATH=$PATH:$MXE_BIN_PATH

i686-w64-mingw32.static-qmake-qt5 \
	BOOST_LIB_SUFFIX=-mt \
	BOOST_THREAD_LIB_SUFFIX=_win32-mt \
	BOOST_INCLUDE_PATH=$MXE_INCLUDE_PATH/boost \
	BOOST_LIB_PATH=$MXE_LIB_PATH \
	OPENSSL_INCLUDE_PATH=$MXE_INCLUDE_PATH/openssl \
	OPENSSL_LIB_PATH=$MXE_LIB_PATH \
	BDB_INCLUDE_PATH=$MXE_INCLUDE_PATH \
	BDB_LIB_PATH=$MXE_LIB_PATH \
	MINIUPNPC_INCLUDE_PATH=$MXE_INCLUDE_PATH \
	MINIUPNPC_LIB_PATH=$MXE_LIB_PATH \
	QMAKE_CC=$MXE_BIN_PATH/i686-w64-mingw32.static-gcc \
	QMAKE_CXX=$MXE_BIN_PATH/i686-w64-mingw32.static-g++ \
	QMAKE_AR=$MXE_BIN_PATH/i686-w64-mingw32.static-ar \
	QMAKE_RANLIB=$MXE_BIN_PATH/i686-w64-mingw32.static-ranlib \
	QMAKE_LRELEASE=~/src/mxe/usr/i686-w64-mingw32.static/qt5/bin/lrelease buzzcoin.pro

make -j 1 -f Makefile.Release

