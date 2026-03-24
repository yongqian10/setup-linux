BUILD_GCC11 := false
BUILD_GCC10 := false
BUILD_GCC4 := true
DOWNLOAD_PREREQUISITES := true
TOOL_HOME := /home/yongqian/tools/linux_x86_64

ifeq ($(BUILD_GCC4),true)
GCC_VERSION := 4.8.2
_GCC_VERSION_ := 482
OPENSSL_VERSION := 1.0.1f
_OPENSSL_VERSION_ := 1_0_1f
PYTHON3_VERSION := 3.6.15
PYTHON2_VERSION := 2.7.10
LIBUSB1_VERSION :=
TCL_VERSION := 8.5.9
BOOST_VERSION := 1.55.0
_BOOST_VERSION_ := 1_55_0
QT4_VERSION := 4.8.5
QT4_VERSION_ := 4.8
CMAKE_VERSION := 3.28.3
CMAKE_VERSION_ := 3.28
NINJA_VERSION := 1.13.1
NODE_VERSION := 8.17.0
PROTO_VERSION := 3.12.4
GMOCK_VERSION := 1.17.0
ABC_VERSION := master-19.12.25
YOSYS_VERSION := 0.60
endif

ifeq ($(BUILD_GCC11),true)
GCC_VERSION := 11.5.0
_GCC_VERSION_ := 115
OPENSSL_VERSION := 1.1.1w
_OPENSSL_VERSION_ := 1_1_1w
PYTHON3_VERSION := 3.13.9
PYTHON2_VERSION := 2.7.10
LIBUSB1_VERSION :=
TCL_VERSION := 8.6.10
BOOST_VERSION := 1.78.0
_BOOST_VERSION_ := 1_78_0
QT6_VERSION := 6.5.6
QT6_VERSION_ := 6.5
CMAKE_VERSION := 3.31.6
CMAKE_VERSION_ := 3.31.6
NINJA_VERSION := 1.13.1
NODE_VERSION := 20.19.5
PROTO_VERSION := 3.12.4
GMOCK_VERSION := 1.17.0
ABC_VERSION := master-19.12.25
YOSYS_VERSION := 0.60
endif


GCC_BUILD_PATH := $(TOOL_HOME)/gcc/$(GCC_VERSION)
OPENSSL_BUILD_PATH := $(TOOL_HOME)/openssl/$(OPENSSL_VERSION)_gcc$(_GCC_VERSION_)
PYTHON3_BUILD_PATH := $(TOOL_HOME)/python3/$(PYTHON3_VERSION)_gcc$(_GCC_VERSION_)
LIBUSB1_BUILD_PATH := $(TOOL_HOME)/libusb/$(LIBUSB1_VERSION)_gcc$(_GCC_VERSION_)
TCL_BUILD_PATH := $(TOOL_HOME)/tcl/$(TCL_VERSION)_gcc$(_GCC_VERSION_)
BOOST_BUILD_PATH := $(TOOL_HOME)/boost/$(BOOST_VERSION)_gcc$(_GCC_VERSION_)
QT6_BUILD_PATH := $(TOOL_HOME)/qt/$(QT6_VERSION)_gcc$(_GCC_VERSION_)
QT4_BUILD_PATH := $(TOOL_HOME)/qt/$(QT4_VERSION)_gcc$(_GCC_VERSION_)
CMAKE_BUILD_PATH := $(TOOL_HOME)/cmake/$(CMAKE_VERSION)_gcc$(_GCC_VERSION_)
NINJA_BUILD_PATH := $(TOOL_HOME)/ninja/$(NINJA_VERSION)_gcc$(_GCC_VERSION_)
NODE_BUILD_PATH := $(TOOL_HOME)/node/$(NODE_VERSION)_gcc$(_GCC_VERSION_)
PROTO_BUILD_PATH := $(TOOL_HOME)/proto/$(PROTO_VERSION)_gcc$(_GCC_VERSION_)
GMOCK_BUILD_PATH := $(TOOL_HOME)/gmock/$(GMOCK_VERSION)_gcc$(_GCC_VERSION_)
ABC_BUILD_PATH := $(TOOL_HOME)/abc/$(ABC_VERSION)_gcc$(_GCC_VERSION_)
YOSYS_BUILD_PATH := $(TOOL_HOME)/yosys/$(YOSYS_VERSION)_gcc$(_GCC_VERSION_)

NPROC := $(shell nproc 2>/dev/null || exho 4)

.DEFAULT_GOAL := all

# Stop on first error
.ONESHELL:
SHELL := /bin/bash
.SHELLFLAGS := -e -u -o pipefail -c

gcc10-lib:
	@ if [ -d $(GCC_BUILD_PATH) ]; then \
		echo 'Found GCC Build Path : $(GCC_BUILD_PATH)' ; \
		echo '**** SKIPPING GCC BUILD ****' ; \
	else \
		if [ "$(BUILD_GCC10)" = "true" ]; then \
			cd src && \
			if [ ! -e gcc-$(GCC_VERSION).tar.gz ]; then \
				wget http://mirrors.kernel.org/gnu/gcc/gcc-$(GCC_VERSION)/gcc-$(GCC_VERSION).tar.gz ; \
			fi ; \
			rm -rf gcc-$(GCC_VERSION) && \
			tar -xzvf gcc-$(GCC_VERSION).tar.gz ; \
			cd gcc-$(GCC_VERSION) ; \
			if [ "$(DOWNLOAD_PREREQUISITES)" = "true" ]; then \
				./contrib/download_prerequisites ; \
			fi ; \
			rm -rf build && \
			mkdir build && \
			cd build && \
			export CFLAGS='-fPIC' && \
			export CXXFLAGS='-fPIC' && \
			../configure \
				--prefix=$(GCC_BUILD_PATH) \
				--with-local-prefix=$(GCC_BUILD_PATH)  \
				--disable-multilib && \
			$(MAKE) -j$(NPROC) && \
			if [ $$? -eq 0 ]; then \
				echo 'Make succeeded, running make install...' ; \
				$(MAKE) install ; \
				echo Done with make gcc ; \
			else \
				echo 'ERROR: Make failed for GCC!' ; \
				exit 1 ; \
			fi ; \
		fi ; \
	fi

gcc4-lib:
	@ if [ -d $(GCC_BUILD_PATH) ]; then \
		echo 'Found GCC4 Build Path : $(GCC_BUILD_PATH)' ; \
		echo '**** SKIPPING GCC4 BUILD ****' ; \
	else \
		if [ "$(BUILD_GCC4)" = "true" ]; then \
			cd src && \
			if [ ! -e gcc-$(GCC_VERSION).tar.gz ]; then \
				wget http://mirrors.kernel.org/gnu/gcc/gcc-$(GCC_VERSION)/gcc-$(GCC_VERSION).tar.gz ; \
			fi ; \
			rm -rf gcc-$(GCC_VERSION) && \
			tar -xzvf gcc-$(GCC_VERSION).tar.gz ;
			cd gcc-$(GCC_VERSION) ; \
			patch ./libsanitizer/tsan/tsan_platform_linux.cc  < ../fix-statp-for-older-gcc.patch &&
			patch ./libsanitizer/asan/asan_linux.cc  < ../fix-sigsegv-for-older-gcc.patch &&
			patch ./libgcc/config/i386/linux-unwind.h  < ../fix-ucontent-for-older-gcc.patch &&
			patch ./gcc/cp/cfns.gperf  < ../fix-inline-for-older-gcc_cfns_gperf.patch &&
			patch ./gcc/cp/cfns.h  < ../fix-inline-for-older-gcc_cfns_h.patch &&
			patch ./gcc/cp/except.c  < ../fix-inline-for-older-gcc_except_c.patch &&
			patch ./gcc/cp/Make-lang.in  < ../fix-inline-for-older-gcc_makelang_in.patch &&
			patch ./libjava/include/x86_64-signal.h  < ../fix-ucontent-libjava-for-older-gcc-x86_64.patch &&
			patch ./libjava/include/i386-signal.h  < ../fix-ucontent-libjava-for-older-gcc-i386.patch &&
			patch ./libjava/include/s390-signal.h  < ../fix-ucontent-libjava-for-older-gcc-s390-signal.patch &&
			if [ "$(DOWNLOAD_PREREQUISITES)" = "true" ]; then \
				./contrib/download_prerequisites ; \
			fi ; \
			rm -rf build && \
			mkdir build && \
			cd build && \
			export CFLAGS='-fPIC' && \
			export CXXFLAGS='-fPIC' && \
			../configure \
				--prefix=$(GCC_BUILD_PATH) \
				--with-local-prefix=$(GCC_BUILD_PATH)  \
				--disable-multilib &&
			$(MAKE) -j$(NPROC) && \
			if [ $$? -eq 0 ]; then \
				echo 'Make succeeded, running make install...' ; \
				$(MAKE) install ; \
				echo Done with make gcc ; \
			else \
				echo 'ERROR: Make failed for old GCC!' ; \
				exit 1 ; \
			fi ; \
		fi ; \
	fi

cmake-lib:
	@ if [ -d $(CMAKE_BUILD_PATH) ]; then \
		echo 'Found CMake Build Path : $(CMAKE_BUILD_PATH)' ; \
		echo '**** SKIPPING CMAKE BUILD ****' ; \
	else \
		echo 'DID NOT FIND CMake Build Path : $(CMAKE_BUILD_PATH)' ; \
		echo 'Running CMake build...' ; \
		cd src && \
		if [ ! -e cmake-$(CMAKE_VERSION).tar.gz ]; then \
			wget https://cmake.org/files/v$(CMAKE_VERSION_)/cmake-$(CMAKE_VERSION).tar.gz ; \
		fi ; \
		rm -rf cmake-$(CMAKE_VERSION) && \
		tar -xvf cmake-$(CMAKE_VERSION).tar.gz && \
		cd cmake-$(CMAKE_VERSION) ; \
		rm -rf build && \
		mkdir build && \
		cd build && \
		../bootstrap \
			--prefix=$(CMAKE_BUILD_PATH) && \
		$(MAKE) -j$(NPROC) && \
		if [ $$? -eq 0 ]; then \
			echo 'Make succeeded, running make install...' ; \
			$(MAKE) install ; \
			echo Done with make CMake ; \
		else \
			echo 'ERROR: Make failed for CMake!' ; \
			exit 1 ; \
		fi ; \
	fi

ninja-lib:
	@ if [ -d $(NINJA_BUILD_PATH) ]; then \
		echo 'Found Ninja Build Path : $(NINJA_BUILD_PATH)' ; \
		echo '**** SKIPPING NINJA BUILD ****' ; \
	else \
		echo 'DID NOT FIND Ninja Build Path : $(NINJA_BUILD_PATH)' ; \
		echo 'Running Ninja build...' ; \
		cd src && \
		if [ ! -e v$(NINJA_VERSION).tar.gz ]; then \
			wget https://github.com/ninja-build/ninja/archive/refs/tags/v$(NINJA_VERSION).tar.gz ; \
		fi ; \
		rm -rf ninja-$(NINJA_VERSION) && \
		tar -xvf v$(NINJA_VERSION).tar.gz && \
		cd ninja-$(NINJA_VERSION) ; \
		$(CMAKE_BUILD_PATH)/bin/cmake -Bbuild -DBUILD_TESTING=OFF -DCMAKE_INSTALL_PREFIX=$(NINJA_BUILD_PATH) && \
		$(CMAKE_BUILD_PATH)/bin/cmake --build build && \
		if [ $$? -eq 0 ]; then \
			echo 'Make succeeded, running make install...' ; \
			$(CMAKE_BUILD_PATH)/bin/cmake --install build && \
			echo Done with make ninja ; \
		else \
			echo 'ERROR: Make failed for NINJA!' ; \
			exit 1 ; \
		fi ; \
	fi


openssl-lib:
	@ if [ -d $(OPENSSL_BUILD_PATH) ]; then \
		echo 'Found OpenSSL Build Path : $(OPENSSL_BUILD_PATH)' ; \
		echo '**** SKIPPING OPENSSL BUILD ****' ; \
	else \
		echo 'DID NOT FIND OpenSSL Build Path : $(OPENSSL_BUILD_PATH)' ; \
		echo 'Running OpenSSL build...' ; \
		cd src && \
		if [ ! -e openssl-$(OPENSSL_VERSION).tar.gz ]; then \
			wget https://github.com/openssl/openssl/releases/download/OpenSSL_$(_OPENSSL_VERSION_)/openssl-$(OPENSSL_VERSION).tar.gz ; \
		fi ; \
		rm -rf openssl-$(OPENSSL_VERSION) && \
		tar -xzvf openssl-$(OPENSSL_VERSION).tar.gz && \
		cd openssl-$(OPENSSL_VERSION) && \
		./config --prefix=$(OPENSSL_BUILD_PATH) shared && \
		$(MAKE) && \
		if [ $$? -eq 0 ]; then \
			echo 'Make succeeded, running make install...' ; \
			$(MAKE) install_sw || true ; \
			echo Done with make openssl ; \
		else \
			echo 'ERROR: Make failed for OpenSSL!' ; \
			exit 1 ; \
		fi ; \
	fi

tcl-lib:
	@ if [ -d $(TCL_BUILD_PATH) ]; then \
		echo 'Found TCL Build Path : $(TCL_BUILD_PATH)' ; \
		echo '**** SKIPPING TCL BUILD ****' ; \
	else \
		echo 'DID NOT FIND TCL Build Path : $(TCL_BUILD_PATH)' ; \
		echo 'Running TCL build...' ; \
		cd src && \
		if [ ! -e tcl-$(TCL_VERSION).tar.gz ]; then \
			echo 'DID NOT FIND TCL SOURCE Path' ; \
		fi ; \
		rm -rf tcl$(TCL_VERSION) && \
		tar -xzvf tcl$(TCL_VERSION)-src.tar.gz && \
		cd tcl$(TCL_VERSION)/unix && \
		rm -rf build && \
		mkdir build && \
		cd build && \
		../configure --prefix=$(TCL_BUILD_PATH) && \
		$(MAKE) -j$(NPROC) && \
		if [ $$? -eq 0 ]; then \
			echo 'Make succeeded, running make install...' ; \
			$(MAKE) install ; \
			ln -s $(TCL_BUILD_PATH)/bin/tclsh8.6 $(TCL_BUILD_PATH)/bin/tclsh
			echo Done with make tcl ; \
		else \
			echo 'ERROR: Make failed for TCL!' ; \
			exit 1 ; \
		fi ; \
	fi

proto-lib:
	@ if [ -d $(PROTO_BUILD_PATH) ]; then \
		echo 'Found PROTOBUF Build Path : $(PROTO_BUILD_PATH)' ; \
		echo '**** SKIPPING PROTOBUF BUILD ****' ; \
	else \
		echo 'DID NOT FIND PROTOBUF Build Path : $(PROTO_BUILD_PATH)' ; \
		echo 'Running PROTOBUF build...' ; \
		cd src && \
		if [ ! -e v$(PROTO_VERSION).tar.gz ]; then \
			wget https://github.com/protocolbuffers/protobuf/archive/refs/tags/v$(PROTO_VERSION).tar.gz ; \
		fi ; \
		rm -rf protobuf-$(PROTO_VERSION) && \
		tar -xzvf v$(PROTO_VERSION).tar.gz
		cd protobuf-$(PROTO_VERSION) && \
		./autogen.sh && \
		./configure --prefix=$(PROTO_BUILD_PATH) && \
		$(MAKE) -j$(NPROC) && \
		if [ $$? -eq 0 ]; then \
			echo 'Make succeeded, running protobuf install...' ; \
			$(MAKE) install && \
			echo Done with make protobuf ; \
		else \
			echo 'ERROR: Make failed for PROTOBUF!' ; \
			exit 1 ; \
		fi ; \
	fi

#--enable-shared --with-ensurepip --disable-test-modules
python3.13-lib:
	@ if [ -d $(PYTHON3_BUILD_PATH) ]; then \
		echo 'Found Python Build Path : $(PYTHON3_BUILD_PATH)' ; \
		echo '**** SKIPPING PYTHON BUILD ****' ; \
	else \
		echo 'DID NOT FIND Python Build Path : $(PYTHON3_BUILD_PATH)' ; \
		echo 'Running Python build...' ; \
		cd src && \
		if [ ! -e Python-$(PYTHON3_VERSION).tar.xz ]; then \
			wget https://python.org/ftp/python/$(PYTHON3_VERSION)/Python-$(PYTHON3_VERSION).tar.xz ; \
		fi ; \
		rm -rf Python-$(PYTHON3_VERSION) && \
		mkdir -p Python-$(PYTHON3_VERSION) && \
		tar -xvf Python-$(PYTHON3_VERSION).tar.xz -C Python-$(PYTHON3_VERSION) --strip-components=1 && \
		cd Python-$(PYTHON3_VERSION) && \
		patch ./Modules/faulthandler.c  < ../fix-python374-faulthandler-test-stuck.patch &&
		export LD_LIBRARY_PATH=$(OPENSSL_LIB_DIR):$(LD_LIBRARY_PATH):$(TCL_BUILD_PATH)/lib && \
		export PYTHONHOME='' && \
		TCLTK_LIBS='-L$(TCL_BUILD_PATH)/lib -ltk8.6 -ltcl8.6' \
		TCLTK_CFLAGS='-I$(TCL_BUILD_PATH)/include' \
		OPENSSL_LDFLAGS='-L$(OPENSSL_BUILD_PATH)/lib' \
		OPENSSL_LIBS='-lcrypto -lssl' \
		OPENSSL_INCLUDES='-I$(OPENSSL_BUILD_PATH)/include' \
		rm -rf build && \
		mkdir build && \
		cd build && \
		../configure --prefix=$(PYTHON3_BUILD_PATH) \
			--enable-shared --with-ensurepip \
			--enable-optimizations --with-openssl=$(OPENSSL_BUILD_PATH) && \
		$(MAKE) -j$(NPROC) && \
		if [ $$? -eq 0 ]; then \
			echo 'Make succeeded, running make install...' ; \
			$(MAKE) install && \
			export PYTHONHOME=$(PYTHON3_BUILD_PATH) && \
			echo 'Done with make python' ; \
		else \
			echo 'ERROR: Make failed for Python!' ; \
			exit 1 ; \
		fi ; \
	fi

python3.6-lib:
	@ if [ -d $(PYTHON3_BUILD_PATH) ]; then \
		echo 'Found Python Build Path : $(PYTHON3_BUILD_PATH)' ; \
		echo '**** SKIPPING PYTHON BUILD ****' ; \
	else \
		echo 'DID NOT FIND Python Build Path : $(PYTHON3_BUILD_PATH)' ; \
		echo 'Running Python build...' ; \
		cd src && \
		if [ ! -e Python-$(PYTHON3_VERSION).tar.xz ]; then \
			wget https://python.org/ftp/python/$(PYTHON3_VERSION)/Python-$(PYTHON3_VERSION).tar.xz ; \
		fi ; \
		rm -rf Python-$(PYTHON3_VERSION) && \
		mkdir -p Python-$(PYTHON3_VERSION) && \
		tar -xvf Python-$(PYTHON3_VERSION).tar.xz -C Python-$(PYTHON3_VERSION) --strip-components=1 && \
		cd Python-$(PYTHON3_VERSION) && \
		export LD_LIBRARY_PATH=$(OPENSSL_LIB_DIR):$(LD_LIBRARY_PATH):$(TCL_BUILD_PATH)/lib && \
		export PYTHONHOME='' && \
		TCLTK_LIBS='-L$(TCL_BUILD_PATH)/lib -ltk8.5 -ltcl8.5' \
		TCLTK_CFLAGS='-I$(TCL_BUILD_PATH)/include' \
		OPENSSL_LDFLAGS='-L$(OPENSSL_BUILD_PATH)/lib' \
		OPENSSL_LIBS='-lcrypto -lssl' \
		OPENSSL_INCLUDES='-I$(OPENSSL_BUILD_PATH)/include' \
		rm -rf build && \
		mkdir build && \
		cd build && \
		../configure --prefix=$(PYTHON3_BUILD_PATH) \
			--enable-shared --with-ensurepip \
			--enable-optimizations --with-openssl=$(OPENSSL_BUILD_PATH) && \
		$(MAKE) -j$(NPROC) && \
		if [ $$? -eq 0 ]; then \
			echo 'Make succeeded, running make install...' ; \
			$(MAKE) install && \
			export PYTHONHOME=$(PYTHON3_BUILD_PATH) && \
			echo 'Done with make python' ; \
		else \
			echo 'ERROR: Make failed for Python!' ; \
			exit 1 ; \
		fi ; \
	fi

boost1.78-lib:
	@ if [ -d $(BOOST_BUILD_PATH) ]; then \
		echo 'Found BOOST Build Path : $(BOOST_BUILD_PATH)' ; \
		echo '**** SKIPPING BOOST BUILD ****' ; \
	else \
		echo 'DID NOT FIND BOOST Build Path : $(BOOST_BUILD_PATH)' ; \
		echo 'Running BOOST build...' ; \
		cd src && \
		if [ ! -e boost_$(BOOST_VERSION).tar.gz ]; then \
			wget https://archives.boost.io/release/$(BOOST_VERSION)/source/boost_$(_BOOST_VERSION_).tar.gz ; \
		fi ; \
		rm -rf boost_$(_BOOST_VERSION_) && \
		tar -xzvf boost_$(_BOOST_VERSION_).tar.gz && \
		cd boost_$(_BOOST_VERSION_) && \
		patch ./boost/thread/pthread/thread_data.hpp  < ../fix-boost-pthread.patch &&
		./bootstrap.sh --prefix=$(BOOST_BUILD_PATH) && \
		if [ $$? -eq 0 ]; then \
			echo 'Bootstrap succeeded, running b2 install...' ; \
			./b2 -j$(NPROC) install ; \
			if [ $$? -eq 0 ]; then \
				echo 'Done with make boost' ; \
			else \
				echo 'ERROR: b2 install failed for Boost!' ; \
				exit 1 ; \
			fi ; \
		else \
			echo 'ERROR: Bootstrap failed for Boost!' ; \
			exit 1 ; \
		fi ; \
	fi

boost1.55-lib:
	@ if [ -d $(BOOST_BUILD_PATH) ]; then \
		echo 'Found BOOST Build Path : $(BOOST_BUILD_PATH)' ; \
		echo '**** SKIPPING BOOST BUILD ****' ; \
	else \
		echo 'DID NOT FIND BOOST Build Path : $(BOOST_BUILD_PATH)' ; \
		echo 'Running BOOST build...' ; \
		cd src && \
		if [ ! -e boost_$(BOOST_VERSION).tar.gz ]; then \
			wget https://archives.boost.io/release/$(BOOST_VERSION)/source/boost_$(_BOOST_VERSION_).tar.gz ; \
		fi ; \
		rm -rf boost_$(_BOOST_VERSION_) && \
		tar -xzvf boost_$(_BOOST_VERSION_).tar.gz && \
		cd boost_$(_BOOST_VERSION_) && \
		./bootstrap.sh --prefix=$(BOOST_BUILD_PATH) && \
		if [ $$? -eq 0 ]; then \
			echo 'Bootstrap succeeded, running b2 install...' ; \
			./b2 -j$(NPROC) install ; \
			if [ $$? -eq 0 ]; then \
				echo 'Done with make boost' ; \
			else \
				echo 'ERROR: b2 install failed for Boost!' ; \
				exit 1 ; \
			fi ; \
		else \
			echo 'ERROR: Bootstrap failed for Boost!' ; \
			exit 1 ; \
		fi ; \
	fi

node-lib:
	@ if [ -d $(NODE_BUILD_PATH) ]; then \
		echo 'Found NODE Build Path : $(NODE_BUILD_PATH)' ; \
		echo '**** SKIPPING NODE BUILD ****' ; \
	else \
		echo 'DID NOT FIND NODE Build Path : $(NODE_BUILD_PATH)' ; \
		echo 'Running NODE build...' ; \
		cd src && \
		if [ ! -e v$(NODE_VERSION).tar.gz ]; then \
			wget https://github.com/nodejs/node/archive/refs/tags/v$(NODE_VERSION).tar.gz ; \
		fi ; \
		rm -rf node-$(NODE_VERSION) && \
		tar -xzvf v$(NODE_VERSION).tar.gz && \
		cd node-$(NODE_VERSION) && \
		./configure --prefix=$(NODE_BUILD_PATH) && \
		$(MAKE) -j$(NPROC) && \
		if [ $$? -eq 0 ]; then \
			echo 'Make succeeded, running node install...' ; \
			$(MAKE) install ; \
			ln -s $(NODE_BUILD_PATH)/bin/node $(NODE_BUILD_PATH)/bin/nodejs
			echo Done with make node ; \
		else \
			echo 'ERROR: Make failed for NODE!' ; \
			exit 1 ; \
		fi ; \
	fi

qt6-lib:
	@ if [ -d $(QT6_BUILD_PATH) ]; then \
		echo 'Found Qt6 Build Path : $(QT6_BUILD_PATH)' ; \
		echo '**** SKIPPING QT6 BUILD ****' ; \
	else \
		echo 'DID NOT FIND Qt6 Build Path : $(QT6_BUILD_PATH)' ; \
		echo 'Running Qt6 build...' ; \
		cd src && \
		if [ ! -e qt-everywhere-opensource-src-$(QT6_VERSION).tar.xz ]; then \
			wget https://cdimage.debian.org/mirror/qt.io/qtproject/archive/qt/$(QT6_VERSION_)/$(QT6_VERSION)/src/single/qt-everywhere-opensource-src-$(QT6_VERSION).tar.xz ; \
		fi ; \
		rm -rf qt-everywhere-src-$(QT6_VERSION) && \
		tar -xvf qt-everywhere-opensource-src-$(QT6_VERSION).tar.xz && \
		cd qt-everywhere-src-$(QT6_VERSION) ; \
		patch ./qtwebengine/src/3rdparty/chromium/content/browser/BUILD.gn  < ../fix-qt-spellcheck-buildflags.patch && \
		rm -rf build && \
		mkdir build && \
		cd build && \
		python3 -m pip install html5lib importlib-metadata && \
		../configure \
			-prefix $(QT6_BUILD_PATH) \
			-opensource -confirm-license \
			-nomake examples -nomake tests \
			-openssl-linked OPENSSL_ROOT_DIR=$(OPENSSL_BUILD_PATH) && \
		$(CMAKE_BUILD_PATH)/bin/cmake --build . --parallel $(NPROC) && \
		if [ $$? -eq 0 ]; then \
			$(CMAKE_BUILD_PATH)/bin/cmake --install . ; \
			echo Done with make qt6 ; \
		else \
			echo 'ERROR: Make failed for QT6!' ; \
			exit 1 ; \
		fi ; \
	fi

qt4-lib:
	@ if [ -d $(QT4_BUILD_PATH) ]; then \
		echo 'Found Qt4 Build Path : $(QT4_BUILD_PATH)' ; \
		echo '**** SKIPPING QT4 BUILD ****' ; \
	else \
		echo 'DID NOT FIND Qt4 Build Path : $(QT4_BUILD_PATH)' ; \
		echo 'Running Qt4 build...' ; \
		cd src && \
		if [ ! -e qt-everywhere-opensource-src-$(QT4_VERSION).tar.gz ]; then \
			wget https://download.qt.io/archive/qt/$(QT4_VERSION_)/$(QT4_VERSION)/qt-everywhere-opensource-src-$(QT4_VERSION).tar.gz ; \
		fi ; \
		rm -rf qt-everywhere-opensource-src-$(QT4_VERSION) && \
		tar -xvf qt-everywhere-opensource-src-$(QT4_VERSION).tar.gz && \
		cd qt-everywhere-opensource-src-$(QT4_VERSION) && \
		OPENSSL_LIBS='-L$(OPENSSL_BUILD_PATH)/lib -lssl -lcrypto' \
		CFLAGS='-I$(OPENSSL_BUILD_PATH)/include' \
		CXXFLAGS='-I$(OPENSSL_BUILD_PATH)/include' \
		LDFLAGS='-L$(OPENSSL_BUILD_PATH)/lib -Wl,-rpath,$(OPENSSL_BUILD_PATH)/lib' \
		./configure \
			-prefix $(QT4_BUILD_PATH) \
			-platform linux-g++-64 \
			-opensource -confirm-license \
			-nomake examples -nomake tests \
			-openssl-linked && \
		LD_LIBRARY_PATH=$$PWD/lib:$(OPENSSL_BUILD_PATH)/lib:$$LD_LIBRARY_PATH make -j$(NPROC) && \
		if [ $$? -eq 0 ]; then \
			make install ; \
			echo Done with make qt4 ; \
		else \
			echo 'ERROR: Make failed for QT4!' ; \
			exit 1 ; \
		fi ; \
	fi

gmock-lib:
	@ if [ -d $(GMOCK_BUILD_PATH) ]; then \
		echo 'Found GMOCK Build Path : $(GMOCK_BUILD_PATH)' ; \
		echo '**** SKIPPING GMOCK BUILD ****' ; \
	else \
		echo 'DID NOT FIND GMOCK Build Path : $(GMOCK_BUILD_PATH)' ; \
		echo 'Running GMOCK build...' ; \
		cd src && \
		if [ ! -e v$(GMOCK_VERSION).tar.gz ]; then \
			wget https://github.com/google/googletest/archive/refs/tags/v$(GMOCK_VERSION).tar.gz ; \
		fi ; \
		rm -rf googletest-$(GMOCK_VERSION) && \
		tar -xvf v$(GMOCK_VERSION).tar.gz && \
		cd googletest-$(GMOCK_VERSION) && \
		which gcc && \
		g++ -std=gnu++17 -fPIC -isystem googletest/include -isystem googletest -isystem googlemock/include -isystem googlemock -pthread -c googletest/src/gtest-all.cc && \
		g++ -std=gnu++17 -fPIC -isystem googletest/include -isystem googletest -isystem googlemock/include -isystem googlemock -pthread -c googlemock/src/gmock-all.cc && \
		ar -rv libgmock.a gtest-all.o gmock-all.o && \
		g++ -std=gnu++17 -shared gtest-all.o gmock-all.o -o libgmock.a && \
		mkdir -p $(GMOCK_BUILD_PATH)/lib && \
		mkdir -p $(GMOCK_BUILD_PATH)/googletest && \
		mkdir -p $(GMOCK_BUILD_PATH)/googlemock && \
		cp -f libgmock.a $(GMOCK_BUILD_PATH)/lib/ && \
		cp -rf googletest/include $(GMOCK_BUILD_PATH)/googletest/ && \
		cp -rf googlemock/include $(GMOCK_BUILD_PATH)/googlemock/ ; \
	fi
	@echo Done with make gmock

#abc-lib:
#	@ if [ -d $(ABC_BUILD_PATH) ]; then \
#		echo 'Found ABC Build Path : $(ABC_BUILD_PATH)' ; \
#		echo '**** SKIPPING ABC BUILD ****' ; \
#	else \
#		echo 'DID NOT FIND ABC Build Path : $(ABC_BUILD_PATH)' ; \
#		echo 'Running ABC build...' ; \
#		cd src && \
#		if [ ! -e abc ]; then \
#			git clone git@github.com:berkeley-abc/abc.git; \
#		fi ; \
#		cd abc && \
#		make && \
#		make libabc.a && \
#		mv libabc.a lib && \
#		mkdir -p $(ABC_BUILD_PATH) && \
#		mv * $(ABC_BUILD_PATH)
#	fi
#	@echo Done with make abc
#
#yosys-lib:
#	@ if [ -d $(YOSYS_BUILD_PATH) ]; then \
#		echo 'Found YOSYS Build Path : $(YOSYS_BUILD_PATH)' ; \
#		echo '**** SKIPPING YOSYS BUILD ****' ; \
#	else \
#		echo 'DID NOT FIND YOSYS Build Path : $(YOSYS_BUILD_PATH)' ; \
#		echo 'Running YOSYS build...' ; \
#		cd src && \
#		cd yosys-$(YOSYS_VERSION) && \
#		make PREFIX=$(YOSYS_BUILD_PATH) && \
#		make install PREFIX=$(YOSYS_BUILD_PATH) && \
#		cp -av *  $(YOSYS_BUILD_PATH)
#	fi
#	@echo Done with make abc

# Default target - build all libraries except gcc
all: cmake-lib openssl-lib tcl-lib node-lib python3.6-lib boost1.55-lib qt4-lib

# Declare phony targets (targets that don't produce files)
.PHONY: all gcc4-lib gcc10-lib cmake-lib openssl-lib tcl-lib proto-lib node-lib python3.13-lib python3.6-lib boost1.55-lib boost1.78-lib qt6-lib qt4-lib gmock-lib abc-lib

#cp ../python3.11_configure.patch . && \
#patch configure < python3.11_configure.patch && \
#patchelf --set-rpath \$$ORIGIN/../lib $(PYTHON_BUILD_PATH)/bin/python3.$(PYTHON_GCC_MAJOR_VERSION) && \

#sed -i 's,_LDFLAGS=-L$(OPENSSL_BUILD_PATH)/lib,_LDFLAGS=-L$(OPENSSL_BUILD_PATH)/lib64,g' Makefile && \
