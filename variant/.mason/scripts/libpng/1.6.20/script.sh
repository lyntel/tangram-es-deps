#!/usr/bin/env bash

MASON_NAME=libpng
MASON_VERSION=1.6.20
MASON_LIB_FILE=lib/libpng.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libpng.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://downloads.sourceforge.net/project/libpng/libpng16/1.6.20/libpng-${MASON_VERSION}.tar.gz \
        0b5df1201ea4b63777a9c9c49ff26a45dd87890e

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/libpng-${MASON_VERSION}
}

function mason_compile {
    export CFLAGS="${CFLAGS:-} -O3"
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --with-pic \
        --disable-shared \
        --disable-dependency-tracking

    make install -j${MASON_CONCURRENCY}
}

function mason_strip_ldflags {
    shift # -L...
    shift # -lpng16
    echo "$@"
}

function mason_ldflags {
    mason_strip_ldflags $(`mason_pkgconfig` --static --libs)
}

function mason_clean {
    make clean
}

mason_run "$@"
