#!/bin/bash
# ./configure --host=x86-64-linux-gnu --prefix=/home/rd/tools/libusb/0.1

function usage
{
    echo "Usage: source commonenv.cshrc <build_dir>"
    echo "- <build_dir> is an absolute path to a build directory containing env and rtf"
    echo "  The <build_dir> argument can be omitted if COMMONENV_BUILDDIR is set"
    echo "  to a valid build directory"
    echo "- Set COMMONENV_QUIET to suppress the printed summary upon successful setup"
    echo "- Set COMMONENV_VERBOSE to print more variables in the summary"
    echo "- Set COMMONENV_PROCEED to proceed past non-fatal errors"
}

################################################################################
# Set build directory
################################################################################

__builddir=""

if [[ $# -eq 1 ]]; then
    if [[ ! -d $1 ]] || [[ ! -d $1/env ]] || [[ ! -d $1/rtf ]]; then
        if [[ ! -z ${COMMONENV_PROCEED+x} ]]; then
            [[ -z ${COMMONENV_QUIET+x} ]] && echo "Error: $1 is not a valid build directory" && usage
        else
            echo "Error: $1 is not a valid build directory"
            usage
            return 1
        fi
    fi
    __builddir=$1
elif [[ ! -z ${COMMONENV_BUILDDIR+x} ]]; then
    if [[ ! -d $COMMONENV_BUILDDIR ]] || [[ ! -d $COMMONENV_BUILDDIR/env ]] || [[ ! -d $COMMONENV_BUILDDIR/rtf ]]; then
        if [[ ! -z ${COMMONENV_PROCEED+x} ]]; then
            [[ -z ${COMMONENV_QUIET+x} ]] && echo "Error: $COMMONENV_BUILDDIR is not a valid build directory" && usage
        else
            echo "Error: $COMMONENV_BUILDDIR is not a valid build directory"
            usage
            return 1
        fi
    fi
    __builddir=$COMMONENV_BUILDDIR
else
    echo "Error: no build specified"
    usage
    return 1
fi

if [[ ${__builddir:0:1} != "/" ]]; then
    echo "Error: $__builddir is not an absolute path"
    return 1
fi


#################
# Locally built Qt setup from source qt-everywhere-opensource-src-5.3.1.tar.gz
# Does not have ICU support built in like the run install
#################

export RADIANT_HOME="$__builddir"
export ENV="$RADIANT_HOME/env/fpga"
export RTF="$RADIANT_HOME/rtf/ispfpga"
export FOUNDRY="$RTF"
export TOOLENV="$RADIANT_HOME/env/tools"
export TOOLRTF="$RADIANT_HOME/rtf"
export TCL_LIBRARY="$TOOLRTF/tcltk/linux/lib/tcl8.6"
export SYNPLIFY_PATH="$TOOLRTF/tptools/synplify/linux"
#export NCS_PATH="/home/rel/ncs-ub8.2/lin64"
#export LSC_PATH="/home/rel/lsc-ub8.2/lin64"

export TOOL_HOME=/home/yongqian/tools/linux_x86_64
export WORKERS=8
export QT_DEBUG_PLUGINS=1

#export QMAKESPEC="linux-g++-64"
#export NINJADIR=$TOOL_HOME/ninja/1.8.2


#################
# Standard QT5 setup info
# We must disable to build the old GUI which will not work with QT5
#################

export arch=lin64

# make release default make type

export BUILD_TYPE=release
export VPR_STACK_TRACES=true
export GTEST_WORKERS=8
export TCLLIBPATH=/usr/share/tcltk

export INSTALL_PATH_USE_GIT_BRANCH=true
export INSTALL_PATH_USE_CC=true
export SET_CC_FROM_ENV=true
export UNIFIED_MAKE=false

export ASAN_OPTIONS='detect_leaks=1'
export LSAN_OPTIONS='max_leaks=10:exitcode=0'
export UBSAN_OPTIONS='print_stacktrace=1'

export BUILD_DELAYM_CUTOFF=1000

#export SQUISH_VERSION='squish-for-qt-6.5.2/'

function efxfb {
    make BUILD_TYPE=release clean
    make BUILD_TYPE=release uninstall
    make BUILD_TYPE=release -j4
}

function efxfb_dbg {
    make BUILD_TYPE=debug clean
    make BUILD_TYPE=debug uninstall
    make BUILD_TYPE=debug -j4
}

function gcc6env {
    export GCCDIR=$TOOL_HOME/gcc/6.1.0
    #export LD_LIBRARY_PATH=$GCCDIR/lib64:$QTDIR/lib:$QTDIR/plugins/platforms
    #export PATH=$GCCDIR/bin:$QTDIR/bin:/tools/bin:/opt/Xilinx/Vivado/2017.4/bin:$TOOL_HOME/ghdl/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    export CC_VER=61
    export CC=gcc
    export CXX=g++
    unset GCC_COLORS
}

function gcc4env {
    export QTDIR=$TOOL_HOME/qt/4.8.5_gcc482
    export GCCDIR=$TOOL_HOME/gcc/4.8.2
    #export CMAKEDIR=$TOOL_HOME/cmake/4.00.0-rc2_gcc482
    export CMAKEDIR=$TOOL_HOME/cmake/3.31.6_gcc482
    export TCL_DIR=$TOOL_HOME/tcl/8.5.9_gcc482
    export TCL="$TCL_DIR"
    export BOOST_DIR=$TOOL_HOME/boost/1_55_0_gcc482
    export SWIG=$TOOL_HOME/swig/3.0.3_gcc482
    export PYTHON2DIR=$TOOL_HOME/python/2.7.10_gcc482
    export PYTHON3DIR=$TOOL_HOME/python3/3.6.15_gcc482
    export OPENSSLDIR=$TOOL_HOME/openssl/1.0.1f_gcc482
    export LIBUSB1DIR=$TOOL_HOME/libusb/1.0/1.0.20_gcc482
    export LIBUSB0DIR=$TOOL_HOME/libusb/0.1/0.1.4_gcc102
    export QMAKESPEC=$QTDIR/mkspecs/linux-g++-64
    export MAKEDIR=$TOOL_HOME/make/3.82_gcc482
    export BINUTILSDIR=$TOOL_HOME/binutils/2.26_gcc482
    export GLIBCDIR=$TOOL_HOME/glibc/2.17_gcc482
    export LD_LIBRARY_PATH=$GCCDIR/lib64:$MAKEDIR/lib:$MAKEDIR/lib:$PYTHON3DIR/lib:$BINUTILSDIR/lib:$QTDIR/lib:$QTDIR/plugins/platforms:$FOUNDRY/bin/lin64:$TOOLRTF/bin/lin64:$TCLDIR/lib:$NODEDIR/lib::$PYTHON2DIR/lib:$TCL_DIR/lib:$BOOST_DIR/lib:$OPENSSLDIR/lib:$LIBUSB0DIR:/lib:/usr/lib64:/usr/local/lib64:/usr/local/lib:/usr/local/ssl/lib:/usr/lib/x86_64-linux-gnu
    export PATH=$NINJADIR:$MAKEDIR/bin:$BINUTILSDIR/bin:$CMAKEDIR/bin:$GCCDIR/bin:$LIBUSB0DIR:$OPENSSLDIR/bin:$QTDIR/bin:$PYTHON2DIR/bin:$PYTHON3DIR/bin:$TCLDIR/bin:$NODEDIR/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin
    export CC_VER=482
    export CC=gcc
    export CXX=g++
    unset GCC_COLORS

    #export CFLAGS="-I/home/yongqian/tools/linux_x86_64/glibc/2.17_gcc482/include"
    #export LDFLAGS="-L/home/yongqian/tools/linux_x86_64/glibc/2.17_gcc482/lib -Wl,-rpath,/home/yongqian/tools/linux_x86_64/glibc/2.17_gcc482/lib -Wl,--dynamic-linker,/home/yongqian/tools/linux_x86_64/glibc/2.17_gcc482/lib/ld-linux-x86-64.so.2"
}

function gcc5env {
    export GCCDIR=$TOOL_HOME/gcc/5.4.0
    #export LD_LIBRARY_PATH=$GCCDIR/lib64:$QTDIR/lib:$QTDIR/plugins/platforms
    #export PATH=$GCCDIR/bin:$QTDIR/bin:/tools/bin:/opt/Xilinx/Vivado/2017.4/bin:$TOOL_HOME/ghdl/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    export CC_VER=54
    export CC=gcc
    export CXX=g++
    unset GCC_COLORS
}

function gcc7env {
    export GCCDIR=$TOOL_HOME/gcc/7.3.0
    #export LD_LIBRARY_PATH=$GCCDIR/lib64:$QTDIR/lib:$QTDIR/plugins/platforms
    #export PATH=$GCCDIR/bin:$QTDIR/bin:/tools/bin:/opt/Xilinx/Vivado/2017.4/bin:$TOOL_HOME/ghdl/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    export CC_VER=73
    export CC=gcc
    export CXX=g++
    unset GCC_COLORS
}

function gcc9env {
	export GCCDIR=$TOOL_HOME/gcc/9.2.0
	#export LD_LIBRARY_PATH=$GCCDIR/lib64
	#export PATH=$GCCDIR/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools/bin:
	export CC_VER=92
	export CC=gcc
	export CXX=g++
}

function gcc10env {
    export QTDIR=$TOOL_HOME/qt/6.8.3_gcc102
    export GCCDIR=$TOOL_HOME/gcc/10.2.0
    export CMAKEDIR=$TOOL_HOME/cmake/3.28.3_gcc102
    export TCLDIR=$TOOL_HOME/tcl/8.6.10_gcc102
    export TCL="$TCLDIR"
    export BOOSTDIR=$TOOL_HOME/boost/1.70.0_gcc102
    export SWIG=$TOOL_HOME/swig/3.0.3_gcc102
    export PYTHON3DIR=$TOOL_HOME/python3/3.7.4_gcc102
    export OPENSSLDIR=$TOOL_HOME/openssl/3.5.6_gcc102
    export LIBUSB1DIR=$TOOL_HOME/libusb/1.0/1.0.27_gcc102
    export LIBUSB0DIR=$TOOL_HOME/libusb/0.1/0.1.12_gcc102
    export QMAKESPEC=$QTDIR/mkspecs/linux-g++
    export NINJADIR=$TOOL_HOME/ninja/1.13.1_gcc102
    export NODEDIR=$TOOL_HOME/node/20.19.5_gcc102
    export PROTODIR=$TOOL_HOME/proto/3.12.4_gcc102
    export PATCHELFDIR=$TOOL_HOME/patchelf/0.18.0_gcc102
    export LD_LIBRARY_PATH=$GCCDIR/lib64:$OPENSSLDIR/lib64:$PYTHON3DIR/lib:$QTDIR/lib:$QTDIR/plugins/platforms:$FOUNDRY/bin/lin64:$TOOLRTF/bin/lin64:$TCLDIR/lib:$NODEDIR/lib:$PROTODIR/lib:$BOOSTDIR/lib:$LIBUSB1DIR/lib:/lib:/usr/lib64:/usr/local/lib64:/usr/local/lib:/usr/lib/x86_64-linux-gnu
    export PATH=$PATCHELFDIR/bin:$NINJADIR/bin:$CMAKEDIR/bin:$PYTHON3DIR/bin:$GCCDIR/bin:$QTDIR/bin:$OPENSSLDIR/bin:$TCLDIR/bin:$NODEDIR/bin:$PROTODIR/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/tools/bin:/sbin:/bin:/home/yongqian/.local/bin
    export CC_VER=102
    export CC=gcc
    export CXX=g++
    unset GCC_COLORS

    #export CFLAGS="-I/home/yongqian/tools/linux_x86_64/glibc/2.17_gcc482/malloc"
    #export LDFLAGS="-L/home/yongqian/tools/linux_x86_64/glibc/2.17_gcc482/lib -Wl,-rpath,/home/yongqian/tools/linux_x86_64/glibc/2.17_gcc482/lib -Wl,--dynamic-linker,/home/yongqian/tools/linux_x86_64/glibc/2.17_gcc482/lib/ld-linux-x86-64.so.2"
}

function gcc11env {
    export QTDIR=$TOOL_HOME/qt/6.5.6_gcc115
    export GCCDIR=$TOOL_HOME/gcc/11.5.0
    export CMAKEDIR=$TOOL_HOME/cmake/3.28.3_gcc115
    export TCLDIR=$TOOL_HOME/tcl/8.6.10_gcc115
    export TCL="$TCLDIR"
    export BOOSTDIR=$TOOL_HOME/boost/1.78.0_gcc115
    export SWIG=$TOOL_HOME/swig/3.0.3_gcc115
    export PYTHON3DIR=$TOOL_HOME/python3/3.13.9_gcc115
    export OPENSSLDIR=$TOOL_HOME/openssl/1.1.1w_gcc115
    export LIBUSB1DIR=$TOOL_HOME/libusb/1.0/1.0.27_gcc115
    export LIBUSB0DIR=$TOOL_HOME/libusb/0.1/0.1.12_gcc115
    export QMAKESPEC=$QTDIR/mkspecs/linux-g++
    export NINJADIR=$TOOL_HOME/ninja/1.13.1_gcc115
    export NODEDIR=$TOOL_HOME/node/20.19.5_gcc115
    export PROTODIR=$TOOL_HOME/proto/3.12.4_gcc115
    export ABCDIR=$TOOL_HOME/abc/master-19.12.25_gcc115
    export YOSYSDIR=$TOOL_HOME/yosys/0.60_gcc115

    export LD_LIBRARY_PATH=$GCCDIR/lib64:$OPENSSLDIR/lib:$PYTHON3DIR/lib:$QTDIR/lib:$QTDIR/plugins/platforms:$FOUNDRY/bin/lin64:$TOOLRTF/bin/lin64:$TCLDIR/lib:$NODEDIR/lib:$PROTODIR/lib:$BOOSTDIR/lib:$LIBUSB1DIR/lib:/lib:/usr/lib64:/usr/local/lib64:/usr/local/lib:/usr/lib/x86_64-linux-gnu
    export PATH=$NINJADIR/bin:$CMAKEDIR/bin:$PYTHON3DIR/bin:$GCCDIR/bin:$QTDIR/bin:$OPENSSLDIR/bin:$TCLDIR/bin:$NODEDIR/bin:$PROTODIR/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/tools/bin:/sbin:/bin:/home/yongqian/.local/bin
    export CC_VER=115
    export CC=gcc
    export CXX=g++
    unset GCC_COLORS
}

function glibc217env {
    #export BINUTILSDIR=$TOOL_HOME/binutils/2.27_gcc485_glibc217
	#export GCCDIR=$TOOL_HOME/gcc/4.8.2_glibc217
	#export LD_LIBRARY_PATH=$GCCDIR/lib64
	#export PATH=$GCCDIR/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/tools/bin:/sbin:/bin:
	export CC_VER=485
	export CC=gcc
	export CXX=g++

    #export LD_LIBRARY_PATH=$BINUTILSDIR/lib:/lib:/usr/lib64:/usr/local/lib64:/usr/local/lib:/usr/lib/x86_64-linux-gnu
    #export PATH=$BINUTILSDIR/bin:/libusr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/tools/bin:/sbin:/bin

    #export CPPFLAGS="-I/home/yongqian/tools/linux_x86_64/glibc/2.17_gcc482/include"
    export CFLAGS=""
    export CPPFLAGS=""
    export LDFLAGS="-L/home/yongqian/tools/linux_x86_64/glibc/2.17_gcc482/lib -Wl,-rpath,/home/yongqian/tools/linux_x86_64/glibc/2.17_gcc482/lib"
    #export LDFLAGS="-L/home/yongqian/tools/linux_x86_64/glibc/2.17_gcc482/lib -Wl,-rpath,/home/yongqian/tools/linux_x86_64/glibc/2.17_gcc482/lib -Wl,--dynamic-linker,/home/yongqian/tools/linux_x86_64/glibc/2.17_gcc482/lib/ld-linux-x86-64.so.2"
}

function tddenv {
	export GMOCK_HOME=$HOME/TDD/gtest-1.8.0/googlemock
	export CURL_HOME=$HOME/TDD/curl-7.58.0
	export JSONCPP_HOME=$HOME/TDD/jsoncpp-src-0.6.0-rc2
	export RLOG_HOME=$HOME/TDD/rlog-1.4
	export BOOST_ROOT=$HOME/TDD/boost_1_66_0
	export BOOST_VERSION=1.66.0
}

function run_eclipse {
    BUILD_TYPE=debug SANITIZE=true VERBOSE_BUILD=true SWT_GTK3=0 $HOME/tools/eclipse/eclipse &
}

alias clearmem='sudo sysctl -w vm.drop_caches=3'

export SSL_CERT_DIR=/etc/ssl/certs
gcc10env

################################################################################
# Print summary
################################################################################

if [[ -z ${COMMONENV_QUIET+x} ]]; then
    echo    "Successfully set environment for $__os $__arch"
    if [[ ! -z ${COMMONENV_VERBOSE+x} ]]; then
    echo    "ENV             = $ENV"
    echo    "FOUNDRY         = $FOUNDRY"
    echo    "RTF             = $RTF"
    echo    "TOOLENV         = $TOOLENV"
    echo    "TOOLRTF         = $TOOLRTF"
    echo    "TCL_LIBRARY     = $TCL_LIBRARY"
    echo    "TCL_DIR         = $TCL_DIR"
    echo    "TCL             = $TCL"
    echo    "QTDIR           = $QTDIR"
    echo    "QMAKESPEC       = $QMAKESPEC"
    echo    "BOOST_DIR       = $BOOST_DIR"
    echo    "SWIG            = $SWIG"
    echo    "PYTHONHOME      = $PYTHONHOME"
    echo -e "PATH            = ${PATH//:/\\n                  }"
    [[ -z ${LD_LIBRARY_PATH+x} ]] || \
    echo -e "LD_LIBRARY_PATH = ${LD_LIBRARY_PATH//:/\\n                  }"
    [[ -z ${INCLUDE+x} ]] || \
    echo -e "INCLUDE         = ${INCLUDE//;/\\n                  }"
    [[ -z ${LIB+x} ]] || \
    echo -e "LIB             = ${LIB//;/\\n                  }"
    [[ -z ${LIBPATH+x} ]] || \
    echo -e "LIBPATH         = ${LIBPATH//;/\\n                  }"
    echo    "arch            = $arch"
    else
    echo "ENV     = $ENV"
    echo "FOUNDRY = $FOUNDRY"
    fi
fi
