#!/usr/bin/env bash

MASON_NAME=earcut
MASON_VERSION=0.10.1
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
    https://github.com/mapbox/earcut.hpp/archive/v${MASON_VERSION}.tar.gz \
    f741208c3304b4f8bc2bc619d706d71c8e459b74
    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/earcut.hpp-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/mapbox
    cp -v include/*.hpp ${MASON_PREFIX}/include/mapbox
    cp -v README.md LICENSE ${MASON_PREFIX}
}

function mason_cflags {
    echo -isystem ${MASON_PREFIX}/include -I${MASON_PREFIX}/include
}

function mason_ldflags {
    :
}

function mason_static_libs {
    :
}

mason_run "$@"
