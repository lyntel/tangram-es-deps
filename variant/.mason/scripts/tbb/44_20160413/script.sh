#!/usr/bin/env bash

MASON_NAME=tbb
MASON_VERSION=44_20160413
MASON_LIB_FILE=bin/tbb

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://www.threadingbuildingblocks.org/sites/default/files/software_releases/source/tbb${MASON_VERSION}oss_src.tgz \
        9c1b4238b2fddeb260dd7725d8fe291066f70ce3

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}${MASON_VERSION}oss
}

function create_links() {
    libname=$1
    if [ -f ${MASON_PREFIX}/lib/${libname}.so ]; then rm ${MASON_PREFIX}/lib/${libname}.so; fi
    cp $(pwd)/build/BUILDPREFIX_release/${libname}.so.2 ${MASON_PREFIX}/lib/
    (cd ${MASON_PREFIX}/lib/ && ln -s ${libname}.so.2 ${libname}.so)
}

function mason_compile {
    mason_step "Loading patch ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff"
    patch -N -p1 < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff
    CXXFLAGS="${CXXFLAGS} -Wno-attributes"
    # libtbb does not support -fvisibility=hidden
    CXXFLAGS="${CXXFLAGS//-fvisibility=hidden}"
    #patch -N -p1 <  ${PATCHES}/tbb_compiler_override.diff || true
    # note: static linking not allowed: http://www.threadingbuildingblocks.org/faq/11
    if [[ $(uname -s) == 'Darwin' ]]; then
      make -j${MASON_CONCURRENCY} tbb_build_prefix=BUILDPREFIX arch=intel64 cpp0x=1 stdlib=libc++ compiler=clang tbb_build_dir=$(pwd)/build
    else
      LDFLAGS="${LDFLAGS} "'-Wl,-z,origin -Wl,-rpath=\$$ORIGIN'
      make -j${MASON_CONCURRENCY} tbb_build_prefix=BUILDPREFIX cfg=release arch=intel64 cpp0x=1 tbb_build_dir=$(pwd)/build
    fi

    # custom install
    mkdir -p ${MASON_PREFIX}/lib/
    mkdir -p ${MASON_PREFIX}/include/
    mkdir -p ${MASON_PREFIX}/bin/

    if [[ $(uname -s) == "Darwin" ]]; then
        cp $(pwd)/build/BUILDPREFIX_release/lib*.* ${MASON_PREFIX}/lib/
    else
        # the linux libraries are funky: the lib.so.2 is the real lib
        # and the lib.so is an ascii text file, so we need to only copy
        # the lib.so.2 and then recreate the lib.so as a relative symlink
        # to the lib.so.2
        create_links libtbbmalloc_proxy
        create_links libtbbmalloc
        create_links libtbb
    fi
    cp -r $(pwd)/include/tbb ${MASON_PREFIX}/include/
    touch ${MASON_PREFIX}/bin/tbb
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    echo "-L${MASON_PREFIX}/lib -lluabind"
}

function mason_clean {
    make clean
}

mason_run "$@"
