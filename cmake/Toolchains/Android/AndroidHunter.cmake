# Copyright (c) 2017, Luc Michalski
# All rights reserved.

macro(hunter_init_android_cmake)

# ---[ Android-Apk

	# * https://github.com/ruslo/hunter/wiki/pkg.android.apk
	hunter_add_package(Android-Apk)
	list(APPEND CMAKE_MODULE_PATH "${ANDROID-APK_ROOT}")
	include(AndroidApk) # android_create_apk

# ---[ Android-SDK

	hunter_add_package(Android-SDK)
	message("Path to `android`: ${ANDROID-SDK_ROOT}/android-sdk/tools/android")
	message("Path to `emulator`: ${ANDROID-SDK_ROOT}/android-sdk/tools/emulator")
	message("Path to `adb`: ${ANDROID-SDK_ROOT}/android-sdk/platform-tools/adb")

# ---[ Android-SDK-Tools

	hunter_add_package(Android-SDK-Tools)

# ---[ Android-SDK-Platform-tools

	# * https://github.com/ruslo/hunter/wiki/pkg.android.apk
	hunter_add_package(Android-SDK-Platform-tools)
	#list(APPEND CMAKE_MODULE_PATH "${ANDROID-APK_ROOT}")
	#include(AndroidApk) # android_create_apk

# ---[ Android-SDK-Platform

	# -- Emulate toolchain
	# set(ANDROID TRUE)
	# set(CMAKE_SYSTEM_VERSION 21)
	# -- end

	hunter_add_package(Android-SDK-Platform)

# ---[ Android-Modules

	# * https://github.com/ruslo/hunter/wiki/pkg.android.modules
	# * https://github.com/hunter-packages/android-cmake
	hunter_add_package(Android-Modules)
	list(APPEND CMAKE_MODULE_PATH "${ANDROID-MODULES_ROOT}")
	include(AndroidNdkModules) # android_ndk_import_module_native_app_glue

# ---[ Android-Build-Tools

	hunter_add_package(Android-Build-Tools)

	if(NOT EXISTS "${ANDROID_BUILD_TOOLS_ROOT}")
	  message(FATAL_ERROR "ANDROID_BUILD_TOOLS_ROOT")
	endif()

	if(NOT EXISTS "${ANDROID-BUILD-TOOLS_ROOT}")
	  message(FATAL_ERROR "ANDROID-BUILD-TOOLS_ROOT")
	endif()

endmacro(hunter_init_android_cmake)