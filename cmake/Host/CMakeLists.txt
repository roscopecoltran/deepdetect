# Copyright (c) 2017, Luc Michalski
# All rights reserved.

cmake_minimum_required(VERSION 3.0)

include("../Hunter/HunterGate.cmake")

HunterGate(
    URL "${HUNTER_HOST_URL}"
    SHA1 "${HUNTER_HOST_SHA1}"
)

# ref. https://github.com/forexample/protobuf-toolchains-mix/blob/master/CMakeLists.txt#L11
project(download-Protobuf-host)

hunter_add_package(Protobuf)