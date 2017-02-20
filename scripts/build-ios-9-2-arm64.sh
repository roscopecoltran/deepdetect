#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/common.sh

EXTRA_ARGS=""
if [ $# -ge 1 ]; then
	EXTRA_ARGS="--clear"
fi

TOOLCHAIN=ios-9-2-arm64

rename_tab deepdetect $TOOLCHAIN

function build_all
{
    COMMANDS=(
        "--toolchain ${TOOLCHAIN} "
        "--verbose "
        "--fwd HUNTER_CONFIGURATION_TYPES=Release "
        "USE_OGLES_GPGPU=ON "
        "${DEEPDETECT_BUILD_ARGS[*]} "
        "CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET=8.0 "
        "--config Release "
        "--jobs 4 "
        "--open "
        "--reconfig "
        "--nobuild "
        "${EXTRA_ARGS}"
    )
    
	build.py ${COMMANDS[*]}
}

(cd ${DIR}/.. && build_all)



