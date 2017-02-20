# Copyright (c) 2017, Luc Michalski
# All rights reserved.

## #################################################################
## update project version with Travis-CI tagged version if set
## #################################################################

macro(hunter_init_ci_integration)
	string(COMPARE NOTEQUAL "$ENV{TRAVIS_TAG}" "" travis_deploy)
	string(COMPARE EQUAL "$ENV{APPVEYOR_REPO_TAG}" "true" appveyor_deploy)
	if(travis_deploy)
	  set(version "$ENV{TRAVIS_TAG}")
	elseif(appveyor_deploy)
	  set(version "$ENV{APPVEYOR_REPO_TAG_NAME}")
	else()
	  set(version "v${current_project_version}")
	endif()
	string(REGEX REPLACE "^v" "" version "${current_project_version}")
endmacro(hunter_init_ci_integration)

## #################################################################
## Activate a package from hunter build or local package
## #################################################################

# hunter_append_new_modules_path(
#	PATHS ""
#)

macro(hunter_append_new_modules_path2)
	set(h_append_value APPEND_PATHS SET_PATH)
	# parse args
	cmake_parse_arguments(h "" "${h_append_value}" "" ${ARGN})
	if(h_UNPARSED_ARGUMENTS)
		MESSAGE(FATAL_ERROR "unexpected argument: ${h_UNPARSED_ARGUMENTS}")
	endif()
	# check required args no-empty
	if(NOT h_APPEND_PATHS)
		MESSAGE(FATAL_ERROR "APPEND_PATHS can't be empty.")
	endif() # ${HUNTER_MODULES_PATH}	
	IF(DEFINED h_APPEND_PATHS)
		FOREACH(_addPath ${h_APPEND_PATHS})
			LIST(APPEND CMAKE_MODULE_PATH "${_addPath}")
		ENDFOREACH()
	ENDIF(DEFINED h_APPEND_PATHS)	
	# not recommended
	#IF(DEFINED h_SET_PATH)
	#	SET(CMAKE_MODULE_PATH ${h_SET_PATH})
	#ENDIF(DEFINED h_SET_PATH)
endmacro(hunter_append_new_modules_path2)

## #################################################################
## Activate a package from hunter build or local package
## #################################################################

macro(hunter_activate_package)
	# define allowed args
	set(h_one_value 
			# required
			HUNTER_NAME 			# (string) hunter_add_package (case sensitive)
			INTERFACE_NAMESPACE 	# (string) eg. JPEG::jpeg (case sensitive)
			FIND_BYNAME 			# (string) find_package (case sensitive)
			# optional
			FIND_BYPATH 			# (string) find_library (case sensitive)
			INCLUDE_DIRS 			# (bool) only if compatibility mode is activated
			COMPATIBILITY_MODE 		# (bool)
			# compatibility mode
			FIND_REQUIRED  			# (bool), default: yes/true
			FIND_QUIET  			# (bool), default: no/false
			FIND_PREFIX_PATH  		# optional
			# build opts/flags
			OPTFLAGS  				# (string)
			HOST_CXXFLAGS   		# (string)
			MARCH_OPTS) 			# (string)
	# parse args
	cmake_parse_arguments(h "" "${h_one_value}" "" ${ARGV})
	if(h_UNPARSED_ARGUMENTS)
		MESSAGE(FATAL_ERROR "unexpected argument: ${h_UNPARSED_ARGUMENTS}")
	endif()
	# check required args no-empty
	if(NOT h_HUNTER_NAME)
		MESSAGE(FATAL_ERROR "HUNTER_NAME can't be empty. (required by hunter_add_package() function).")
	endif()
	if(NOT h_INTERFACE_NAMESPACE)
		MESSAGE(FATAL_ERROR "INTERFACE_NAMESPACE can't be empty, as it is required by target_link_libraries() function. (eg target_link_libraries(foo rabbitmq-c::rabbitmq-static)).")
	endif()
	if(NOT h_FIND_BYNAME)
		MESSAGE(FATAL_ERROR "FIND_BYNAME can't be empty. (required by find_package() function).")
	endif()
	# defaults
	if(NOT DEFINED h_COMPATIBILITY)
		SET(h_COMPATIBILITY FALSE)
	endif(NOT DEFINED h_COMPATIBILITY)
	if(NOT DEFINED h_FIND_REQUIRED)
		SET(h_FIND_REQUIRED TRUE)
	endif(NOT DEFINED h_FIND_REQUIRED)

	# Add new package
	MESSAGE(STATUS "[Hunter] Add new package: ${HUNTER_NAME}")
	hunter_add_package(${HUNTER_NAME})
	IF(HUNTER_ENABLED)
		if(h_FIND_REQUIRED)
			MESSAGE(STATUS "[Hunter] Find package by name: ${FIND_BYNAME} [REQUIRED]")
			find_package(${FIND_BYNAME} CONFIG REQUIRED)
		else()
			MESSAGE(STATUS "[Hunter] Find package by name: ${FIND_BYNAME} [QUIET]")
			find_package(${FIND_BYNAME} CONFIG QUIET)
		endif()
	ENDIF(HUNTER_ENABLED)

	if(h_COMPATIBILITY) # Compatibility mode
		if(h_FIND_REQUIRED)
			find_package(${FIND_BYNAME} REQUIRED)
		else()
			find_package(${FIND_BYNAME} QUIET)
		endif()
	endif(h_COMPATIBILITY) # Compatibility mode

	if(h_COMPATIBILITY_TEST) # Compatibility mode test (check it variables are colliding with hunter)
	endif(h_COMPATIBILITY_TEST)

	IF(${FIND_BYNAME}_FOUND)
		add_definitions(-DUSE_LIB${FIND_BYNAME})
		LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS ${h_INTERFACE_NAMESPACE})
		LIST(APPEND ${PROJECT_NAME}_INCLUDE_DIR ${${FIND_BYNAME}_INCLUDE_DIRS})
		LIST(APPEND ${PROJECT_NAME}_LIBRARIES 	${${FIND_BYNAME}_LIBS})
		LIST(APPEND ${PROJECT_NAME}_LINK_DIR 	${${FIND_BYNAME}_ROOT})
		MESSAGE(STATUS "[Hunter] Register package interface namespace: ${h_INTERFACE_NAMESPACE}")
		MESSAGE(STATUS "[Hunter] Usage example: target_link_libraries(foo ${h_INTERFACE_NAMESPACE})")
		IF(h_INCLUDE_DIRS)
			INCLUDE_DIRECTORIES(${${FIND_BYNAME}_INCLUDE_DIRS})
		ENDIF(h_INCLUDE_DIRS)
	ENDIF(${FIND_BYNAME}_FOUND)

endmacro(hunter_activate_package)

## #################################################################
## Register new suggestions in a global context project graph
## #################################################################
#
# hunter_register_new_suggestions()
#
macro(hunter_register_new_suggestions)
	# define allowed args
	set(h_one_value 
			# required
			PLATFORM 				# (string) android, iphoneos, wsa
			SDK 					# (string) eg: sdk8-1, ios-10-2, osx-10-12
			ARCH 					# (string) eg: armv7, arm64, x86
			ALIASES  				# (string) eg: i386, x86
			OPTFLAGS  				# (string) 
			HOST_CXXFLAGS   		# (string)
			MARCH_OPTS) 			# (string)
	# parse args
	cmake_parse_arguments(h "" "${h_one_value}" "" ${ARGV})
	if(h_UNPARSED_ARGUMENTS)
		MESSAGE(FATAL_ERROR "unexpected argument: ${h_UNPARSED_ARGUMENTS}")
	endif()
	# check required args no-empty
	if(NOT h_PLATFORM)
		MESSAGE(FATAL_ERROR "PLATFORM can't be empty.")
	endif()
	if(NOT h_ARCH)
		MESSAGE(FATAL_ERROR "ARCH can't be empty.")
	endif()
	MESSAGE(STATUS "under construction...")
endmacro(hunter_register_new_suggestions)	

## #################################################################
## Find all variables with a prefix 
## #################################################################
#
# eg. hunter_find_package_vars(KEYWORD "OpenCV")
#
macro(hunter_find_package_vars)
	# define allowed args
	set(h_one_value 
			# required
			KEYWORD 				# (string) OpenCV, OPENcV works if case insensitive
			CASE_SENSITIVE 			# (bool) disabled conversaion of the keyword in UPPERCASE, LOWERCASE and UCFIRST
		) 			
	# parse args
	cmake_parse_arguments(h "" "${h_one_value}" "" ${ARGV})
	if(h_UNPARSED_ARGUMENTS)
		MESSAGE(FATAL_ERROR "unexpected argument: ${h_UNPARSED_ARGUMENTS}")
	endif()
	# check required args no-empty
	if(NOT h_KEYWORD)
		MESSAGE(FATAL_ERROR "KEYWORD can't be empty.")
	endif()
	MESSAGE(STATUS "under construction...")
endmacro(hunter_find_package_vars)

## #################################################################
## Set a CMake variable from a file content
## #################################################################

function(set_variable_from_file_content file_path output_variable)
	SET(cat_prog cat)
	IF(WIN32)
	  IF(NOT UNIX)
	    SET(cat_prog type)
	  ELSE(NOT UNIX)
	ENDIF(WIN32)
	EXEC_PROGRAM(${cat_prog} ARGS ${file_path} OUTPUT_VARIABLE ariable)
	MESSAGE("Content of file is: ${variable}")
	SET(output_variable ${variable} PARENT_SCOPE)
endfunction(set_variable_from_file_content)

## #################################################################
## Set default platform flags for conditional components builds
## #################################################################

macro(hunter_target_platform_prepare)

	SET(SUGGEST_ANDROID_ARCH "")

	# ┌──────────────────────────────────────────────────────────────────┐
	# │  Apple/Darwin ?                                                  │
	# └──────────────────────────────────────────────────────────────────┘
	STRING(COMPARE NOTEQUAL "${APPLE}" "" is_platform_apple)
	# additional env variables for darwin workstations
	IF(is_apple AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Experimental/hunter_utils_platform_darwin.cmake")
	  INCLUDE("${CMAKE_CURRENT_SOURCE_DIR}/cmake/Experimental/hunter_utils_platform_darwin.cmake")
	ENDIF(is_apple AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Experimental/hunter_utils_platform_darwin.cmake")

	# ┌──────────────────────────────────────────────────────────────────┐
	# │  Xcode                                                           │
	# └──────────────────────────────────────────────────────────────────┘
	STRING(COMPARE EQUAL "${CMAKE_GENERATOR}" "Xcode" is_generator_xcode)

	# ┌──────────────────────────────────────────────────────────────────┐
	# │  iOS/iPAD                                                        │
	# └──────────────────────────────────────────────────────────────────┘
	# polly cmd: build.py --toolchain=ios-10-2 --clear --reconfig --install --config=Release --jobs 4 --fwd HUNTER_CONFIGURATION_TYPES=Release
	STRING(COMPARE EQUAL "${CMAKE_OSX_SYSROOT}" "iphoneos" is_platform_ios)

		## Compilation flags, options, suggestions based on machine learning (another project based on deep learning ^^)
		IF(is_platform_ios AND h_SUGGEST_OPTS)
			SET(SUGGEST_iphoneos_OPTFLAGS "-O3")
		ENDIF(is_platform_ios AND h_SUGGEST_OPTS)

	# ┌──────────────────────────────────────────────────────────────────┐
	# │  MacOSX                                                          │
	# └──────────────────────────────────────────────────────────────────┘
	# polly cmd: build.py --toolchain=osx-10-12 --clear --reconfig --install --config=Release --jobs 4 --fwd HUNTER_CONFIGURATION_TYPES=Release
	IF(is_generator_xcode AND NOT is_platform_ios)
	  SET(is_platform_osx TRUE)
	ELSE()
	  SET(is_platform_osx FALSE)
	ENDIF()

		## Compilation flags, options, suggestions based on machine learning (another project based on deep learning ^^)
		IF(is_platform_osx AND h_SUGGEST_FLAGS)
			SET(SUGGEST_iphoneos_OPTFLAGS "-O3")
		ENDIF(is_platform_osx AND h_SUGGEST_OPTS)

	# ┌──────────────────────────────────────────────────────────────────┐
	# │  Linux                                                           │
	# └──────────────────────────────────────────────────────────────────┘
	#  build.py --toolchain=dockercross-gcc --clear --reconfig --install --config=Release --jobs 4 --fwd HUNTER_CONFIGURATION_TYPES=Release
	STRING(COMPARE EQUAL "${CMAKE_SYSTEM_NAME}" "Linux" is_platform_linux)

		## Compilation flags, options, suggestions based on machine learning (another project based on deep learning ^^)
		IF(is_platform_linux AND h_SUGGEST_OPTS)
			SET(SUGGEST_linux_OPTFLAGS "-O3 -march=native")
			SET(SUGGEST_linux_HOST_CXXFLAGS "--std=c++11 -march=native")
		ENDIF(is_platform_linux AND h_SUGGEST_OPTS)

	# ┌──────────────────────────────────────────────────────────────────┐
	# │  Android                                                         │
	# └──────────────────────────────────────────────────────────────────┘
	# forced by the user, passed as a variable
	IF(ANDROID)
	  SET(is_platform_android ${ANDROID}) # syntax compatibility (passed through the command line as an argument)
	# case: dockercross-android-arm
	ELSE()
	  # Android
	  STRING(COMPARE EQUAL "${CMAKE_SYSTEM_NAME}" "Android" is_platform_android)
	ENDIF()

	## common compilation flags, options, suggestions based on machine learning (another project based on deep learning ^^)
	IF(is_platform_android AND h_SUGGEST_OPTS)
		MESSAGE(STATUS "none for the moment")
		#SET(SUGGEST_android_OPTFLAGS "-O3 -march=native")
		#SET(SUGGEST_android_HOST_CXXFLAGS "--std=c++11 -march=native")
	ENDIF(is_platform_android AND h_SUGGEST_OPTS)

	# Android:
	# - https://github.com/tensorflow/tensorflow/blob/master/tensorflow/contrib/makefile/build_all_android.sh#L21
	# - https://github.com/tensorflow/tensorflow/blob/master/tensorflow/contrib/makefile/compile_android_protobuf.sh#L97
	STRING(COMPARE NOTEQUAL "${ARCHITECTURE}" "arm64-v8a" 			is_platform_arch_arm64-v8a)
	STRING(COMPARE NOTEQUAL "${ARCHITECTURE}" "armeabi" 			is_platform_arch_armeabi)
	STRING(COMPARE NOTEQUAL "${ARCHITECTURE}" "armeabi-v7a" 		is_platform_arch_armeabi-v7a)
	STRING(COMPARE NOTEQUAL "${ARCHITECTURE}" "armeabi-v7a-hard" 	is_platform_arch_armeabi-v7a-hard)
	STRING(COMPARE NOTEQUAL "${ARCHITECTURE}" "armeabi" 			is_platform_arch_armeabi)
	STRING(COMPARE NOTEQUAL "${ARCHITECTURE}" "mips" 				is_platform_arch_mips)
	STRING(COMPARE NOTEQUAL "${ARCHITECTURE}" "mips64" 				is_platform_arch_mips64)
	STRING(COMPARE NOTEQUAL "${ARCHITECTURE}" "x86" 				is_platform_arch_x86)
	STRING(COMPARE NOTEQUAL "${ARCHITECTURE}" "x86_64" 				is_platform_arch_x86_64)

	# arm64
	IF(is_platform_arch_arm64-v8a AND is_platform_android)

		## common compilation flags, options, suggestions based on machine learning (another project based on deep learning ^^)
		IF(h_SUGGEST_OPTS)
			# special delimeters for variable name split for later
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_TOOLCHAIN 					"aarch64-linux-android-4.9")
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_SYSROOT_ARCH 				"arm64")
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_GENERATED_OUTPUT_PREFIX 	"aarch64-linux-android")
		ENDIF(h_SUGGEST_OPTS)

	# armv7 and armv7a
	ELSEIF(is_armeabi AND is_platform_android)

		## common compilation flags, options, suggestions based on machine learning (another project based on deep learning ^^)
		IF(h_SUGGEST_OPTS)
			# special delimeters for variable name split for later
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_TOOLCHAIN 					"arm-linux-androideabi-4.9")
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_SYSROOT_ARCH 				"arm")
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_GENERATED_OUTPUT_PREFIX 	"arm-linux-androideabi")
		ENDIF(h_SUGGEST_OPTS)

		# armeabi-v7a
		IF(is_armeabi-v7a OR is_armeabi-v7a-hard AND h_SUGGEST_OPTS)
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_MARCH_OPTS 					"-march=armv7-a")
		ENDIF()

	# mips32
	ELSEIF(is_mips AND is_android)

		## common compilation flags, options, suggestions based on machine learning (another project based on deep learning ^^)
		IF(h_SUGGEST_OPTS)
			# special delimeters for variable name split for later
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_TOOLCHAIN 					"mipsel-linux-android-4.9")
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_SYSROOT_ARCH 				"mips")
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_GENERATED_OUTPUT_PREFIX 	"mipsel-linux-android")
		ENDIF(h_SUGGEST_OPTS)

	# mips64
	ELSEIF(is_mips64 AND is_android)

		## common compilation flags, options, suggestions based on machine learning (another project based on deep learning ^^)
		IF(h_SUGGEST_OPTS)
			# special delimeters for variable name split for later
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_TOOLCHAIN 					"mips64el-linux-android-4.9")
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_SYSROOT_ARCH 				"mips64")
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_GENERATED_OUTPUT_PREFIX 	"mips64el-linux-android")
		ENDIF(h_SUGGEST_OPTS)

	# x86
	ELSEIF(is_x86 AND is_android)

		## common compilation flags, options, suggestions based on machine learning (another project based on deep learning ^^)
		IF(h_SUGGEST_OPTS)
			# special delimeters for variable name split for later
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_TOOLCHAIN 					"x86-4.9")
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_SYSROOT_ARCH 				"x86")
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_GENERATED_OUTPUT_PREFIX 	"i686-linux-android")
		ENDIF(h_SUGGEST_OPTS)

	# x86_64
	ELSEIF(is_x86_64 AND is_android)

		## common compilation flags, options, suggestions based on machine learning (another project based on deep learning ^^)
		IF(h_SUGGEST_OPTS)
			# special delimeters for variable name split for later
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_TOOLCHAIN 					"x86_64-4.9")
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_SYSROOT_ARCH 				"x86_64")
			SET(SUGGEST_ANDROID_${ARCHITECTURE}_GENERATED_OUTPUT_PREFIX 	"x86_64-linux-android")
		ENDIF(h_SUGGEST_OPTS)

	# unkown/incomplete setup
	ELSE()
		MESSAGE(FATAL_ERROR "Target build architecture info incomplete, aborting build operations NOW !")

	ENDIF()

	#  build.py --toolchain=android-ndk... --clear --reconfig --install --config=Release --jobs 4 --fwd HUNTER_CONFIGURATION_TYPES=Release
	# eg:
	# android-ndk-r11c-api-21-armeabi-v7a-neon
	# android-ndk-r11c-api-21-x86
	# android-ndk-r11c-api-21-x86-64
	# android-ndk-r11c-api-21-arm64-v8a
	# android-ndk-r10e-api-21-arm64-v8a-clang-35
	# android-ndk-r10e-api-21-arm64-v8a-gcc-49-hid-sections
	# android-ndk-r10e-api-21-arm64-v8a-gcc-49-hid
	# android-ndk-r10e-api-21-arm64-v8a-gcc-49
	# android-ndk-r10e-api-21-arm64-v8a
	# android-ndk-r10e-api-21-armeabi-v7a-neon-clang-35
	# android-ndk-r10e-api-21-armeabi-v7a-neon-hid-sections
	# android-ndk-r10e-api-21-armeabi-v7a-neon
	# android-ndk-r10e-api-21-armeabi-v7a
	# android-ndk-r10e-api-21-armeabi
	# android-ndk-r10e-api-21-mips
	# android-ndk-r10e-api-21-mips64
	# android-ndk-r10e-api-21-x86-64-hid-sections
	# android-ndk-r10e-api-21-x86-64-hid
	# android-ndk-r10e-api-21-x86-64
	# android-ndk-r10e-api-21-x86

	# ┌──────────────────────────────────────────────────────────────────┐
	# │  Windows (WSA)                                                   │
	# └──────────────────────────────────────────────────────────────────┘
	string(COMPARE EQUAL "${CMAKE_CXX_COMPILER_ID}" "MSVC" is_compiler_msvc)    

	# define ?!
	# WINDOWS_STORE
	# INDOWS_PHONE
	# WSA
	IF(WIN32 OR WIN64 OR is_compiler_msvc)
	  MESSAGE(STATUS "is_compiler_msvc? ${is_compiler_msvc}")
	  MESSAGE(STATUS "WIN32? ${WIN32}")
	  MESSAGE(STATUS "WIN64? ${WIN64}")
	  MESSAGE(STATUS "MXE_TARGETS: ${MXE_TARGETS}")

	  SET(is_msvc TRUE)

	  IF( CMAKE_SIZEOF_VOID_P EQUAL 8 )
	    SET(PLATFORM win64)
	    SET(is_platform_arch_x86_64 TRUE)
	    SET(is_msvc_64 TRUE)
	  ELSE()
	    SET(is_platform_arch_x86 TRUE)
	    SET(PLATFORM win32)
	    SET(is_msvc_32 TRUE)
	  ENDIF()
	ENDIF(WIN32 OR WIN64 OR is_compiler_msvc)

endmacro(hunter_target_platform_prepare)


