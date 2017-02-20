# Copyright (c) 2017, Luc Michalski
# All rights reserved.

include(CMakeParseArguments) # cmake_parse_arguments

OPTION(HUNTER_UNITY3D_NATIVE_PLUGIN "Bundle and deploy Unity Native Plugins with Hunter"  ON) # create .dll, .bundke,.framework, .so, .a libraries for Unity3D for most popular CMake driven projects
OPTION(HUNTER_UNITY3D_NATIVE_PLUGIN_DEPLOY "Deploy Unity Native Plugins with CMake"       ON) # deploy and copy generated output in a Unity3D compatible skeleton for cross-platfrom native plugins
OPTION(HUNTER_UNITY3D_NATIVE_PLUGIN_NPP_WRAPPER "" ON) # Dynamic native library for Unity3D wrapper, ref: https://github.com/shadowmint/unity-n-native/
OPTION(HUNTER_UNITY3D_NATIVE_PLUGIN_CXX_WRAPPER "" OFF) # disabled for now as we might use unity-n-native as dynamic wrapper
OPTION(HUNTER_UNITY3D_NATIVE_PLUGIN_PROFILE      "" ON)

MACRO(sniper_prepare_macosx_framework)
  # build frameworks or dylibs
  IF(BUILD_SHARED_LIBS)
      IF(is_osx) # Only for MacOSX targets 
        # adapt target to build frameworks instead of dylibs
        set_target_properties(${target_name} PROPERTIES
                              FRAMEWORK TRUE
                              FRAMEWORK_VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}
                              MACOSX_FRAMEWORK_IDENTIFIER com.confusedlabs.${target_name}
                              MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}
                              MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})
      ENDIF(is_osx)
      # adapt install directory to allow distributing dylibs/frameworks in user's frameworks/application bundle
      set_target_properties(${target_name} PROPERTIES
                            BUILD_WITH_INSTALL_RPATH 1
                            INSTALL_NAME_DIR "@rpath")
  ENDIF(BUILD_SHARED_LIBS)
ENDMACRO(sniper_prepare_macosx_framework)

# copy targets to a blank Unity3D project skeleton
# nb. 
# - Means that the project was not created by Unity3D or is empty of any Unity3D files.  
# - Means that it is only a copy of all wrappers and generated content by CMake in a Unity3D compatible structure folder. 
MACRO(hunter_unity3d_deploy)
	  IF(HUNTER_UNITY3D_NATIVE_PLUGIN_DEPLOY)
	    # nm <exe filename> shows the symbols in the file. file <library filename> shows the symbols in the file.
      IF(BUILD_SHARED_LIBS)
          IF(is_osx) # adapt target to build frameworks instead of dylibs
            set_target_properties(${UNITY_PLUGIN_LIBRABRY_NAME} PROPERTIES
                                  FRAMEWORK TRUE
                                  FRAMEWORK_VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}
                                  MACOSX_FRAMEWORK_IDENTIFIER com.confusedlabs.${UNITY_PLUGIN_LIBRABRY_NAME}
                                  MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}
                                  MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})
          ENDIF(is_osx)
          # adapt install directory to allow distributing dylibs/frameworks in user's frameworks/application bundle
          set_target_properties(${UNITY_PLUGIN_LIBRABRY_NAME} PROPERTIES
                                BUILD_WITH_INSTALL_RPATH 1
                                INSTALL_NAME_DIR "@rpath")
      ENDIF(BUILD_SHARED_LIBS)
      # add custom commands to target
	    ADD_CUSTOM_COMMAND(TARGET ${UNITY_PLUGIN_LIBRABRY_NAME}
	        POST_BUILD
	        COMMAND ${CMAKE_COMMAND} -E make_directory ${UNITY_PLUGIN_DEST_DIR}
	        # careful, difference between ${UNITY_PLUGIN_LIBRABRY_NAME} and ${CONFIG_PROJECT_LIBRARY_NAME}
	        COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:${UNITY_PLUGIN_LIBRABRY_NAME}>" "${UNITY_PLUGIN_DEST_DIR}/${UNITY_PLUGIN_FILE_NAME}"
	        COMMAND ${CMAKE_COMMAND} -E remove ${UNITY_ASSETS_DIR}/${UNITY_PLUGIN_NAME}/detail/${UNITY_PLUGIN_LIBRABRY_NAME}.cs
	        COMMAND ${CMAKE_COMMAND} -E remove ${UNITY_ASSETS_DIR}/${UNITY_PLUGIN_NAME}/detail/${CONFIG_PROJECT_LIBRARY_NAME}CSHARP_wrap.cxx
	        COMMAND ${CMAKE_COMMAND} -E remove ${UNITY_ASSETS_DIR}/${UNITY_PLUGIN_NAME}/detail${CONFIG_PROJECT_LIBRARY_NAME}CSHARP_wrap.h
	        COMMAND ${CMAKE_STRIP} ${STRIP_ARGS} "${UNITY_PLUGIN_DEST_DIR}/${UNITY_PLUGIN_FILE_NAME}"
	    )
	    IF(HUNTER_UNITY3D_NATIVE_PLUGIN_PROFILE) # generate report and profile on generated libraries with external tools like nm or file

	    ENDIF(HUNTER_UNITY3D_NATIVE_PLUGIN_PROFILE)

	     # enable c++11 via -std=c++11 when compiler is clang or gcc
	     IF( "\"${CMAKE_CXX_COMPILER_ID}\"" MATCHES AppleClang)
	        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
	        #target_compile_features(${CONFIG_PROJECT_LIBRARY_NAME} PRIVATE cxx_nonstatic_member_init)
	        #target_compile_features(${UNITY_PLUGIN_LIBRABRY_NAME} PRIVATE cxx_nonstatic_member_init)
	     ELSEIF( "\"${CMAKE_CXX_COMPILER_ID}\"" MATCHES Clang)
	        target_compile_features(${CONFIG_PROJECT_LIBRARY_NAME} PRIVATE cxx_nonstatic_member_init)
	        target_compile_features(${UNITY_PLUGIN_LIBRABRY_NAME} PRIVATE cxx_nonstatic_member_init)
	     ELSEIF( "\"${CMAKE_CXX_COMPILER_ID}\"" MATCHES GNU)
	        #target_compile_features(${CONFIG_PROJECT_LIBRARY_NAME} PRIVATE cxx_nonstatic_member_init)
	        #target_compile_features(${UNITY_PLUGIN_LIBRABRY_NAME} PRIVATE cxx_nonstatic_member_init)
	     ELSEIF( "\"${CMAKE_CXX_COMPILER_ID}\"" MATCHES Intel)
	       # using Intel C++
	     ELSEIF( "\"${CMAKE_CXX_COMPILER_ID}\"" MATCHES MSVC)
	       # using Visual Studio C++
	     ENDIF()
	     # fixes compilation with cmake > 3.2.0
	     # http://stackoverflow.com/questions/26841603/arm-linux-androideabi-bin-ld-fatal-error-soname-must-take-a-non-empty-argume
	     STRING(REPLACE "<CMAKE_SHARED_LIBRARY_SONAME_CXX_FLAG><TARGET_SONAME>" "" CMAKE_CXX_CREATE_SHARED_MODULE "${CMAKE_CXX_CREATE_SHARED_MODULE}")
	  ENDIF(HUNTER_UNITY3D_NATIVE_PLUGIN_DEPLOY)
	ENDIF(HUNTER_UNITY3D_NATIVE_PLUGIN)
ENDMACRO()

MACRO(hunter_unity3d_native_wrapper wrapper_name)
	# registry of valid unity native code wrappers
    STRING(COMPARE EQUAL "${wrapper_name}" "NativeCXX" 			is_native_cxx)
    # ref: https://github.com/shadowmint/unity-n-native
    STRING(COMPARE EQUAL "${wrapper_name}" "Unity-N-Native" 		is_npp)
    # ref: https://github.com/tritao/MonoManagedToNative
    STRING(COMPARE EQUAL "${wrapper_name}" "MonoManagedToNative" 	is_mono_managed_to_native)
    # ref: https://github.com/mono/CppSharp
    STRING(COMPARE EQUAL "${wrapper_name}" "CppSharp" 				is_cppsharp)
    # ref: https://github.com/mono/embeddinator-4000
    STRING(COMPARE EQUAL "${wrapper_name}" "Embeddinator4000" 		is_embeddinator_4000)
    # ref: https://github.com/tritao/LLDBSharp
    STRING(COMPARE EQUAL "${wrapper_name}" "LLDBSharp" 				is_lldb_csharp)
ENDMACRO()	

MACRO(hunter_unity3d_profile_generated_libraries unity_native_plugin_name unity_native_plugin_dest_path)
    # .framework
    # lipo -info myFramework.framework/MyFramework    
    IF(is_ios) # iOS - archs=armv7,armv64, extension=*.a
       # profile generated output
       ADD_CUSTOM_COMMAND(TARGET ${_unity_native_plugin_name}
          POST_BUILD
          # get info about the generated library 
          COMMAND file "${UNITY_PLUGIN_DEST_DIR}/${UNITY_PLUGIN_FILE_NAME}" > "${UNITY_PLUGIN_DEST_DIR}/file_library_info-${UNITY_PLUGIN_LIBRABRY_NAME}.txt"
          # get all symbols from the genrated library
          COMMAND nm "${UNITY_PLUGIN_DEST_DIR}/${UNITY_PLUGIN_FILE_NAME}" > "${UNITY_PLUGIN_DEST_DIR}/nn_library_symbols-${UNITY_PLUGIN_LIBRABRY_NAME}.txt"
          # get info about the generated library 
          COMMAND xcrun -sdk iphoneos lipo -info "${UNITY_PLUGIN_DEST_DIR}/${UNITY_PLUGIN_FILE_NAME}" > "${UNITY_PLUGIN_DEST_DIR}/xcrun_iphoneos_lipo_info-${UNITY_PLUGIN_LIBRABRY_NAME}.txt"
       )    
    ELSEIF(is_osx) # MacOSX - archs=i386,x86_64, extension=*.bundle
       # profile generated output
       ADD_CUSTOM_COMMAND(TARGET ${UNITY_PLUGIN_LIBRABRY_NAME}
          POST_BUILD
          # get info about the generated library 
          COMMAND file "${UNITY_PLUGIN_DEST_DIR}/${UNITY_PLUGIN_FILE_NAME}" > "${UNITY_PLUGIN_DEST_DIR}/file_library_info-${UNITY_PLUGIN_LIBRABRY_NAME}.txt"
          # get all symbols from the genrated library
          COMMAND nm "${UNITY_PLUGIN_DEST_DIR}/${UNITY_PLUGIN_FILE_NAME}" > "${UNITY_PLUGIN_DEST_DIR}/nn_library_symbols-${UNITY_PLUGIN_LIBRABRY_NAME}.txt"
          # get info about the generated library 
          COMMAND xcrun -sdk macosx lipo -info "${UNITY_PLUGIN_DEST_DIR}/${UNITY_PLUGIN_FILE_NAME}" > "${UNITY_PLUGIN_DEST_DIR}/xcrun_macosx_lipo_info-${UNITY_PLUGIN_LIBRABRY_NAME}.txt"
       )
    ELSEIF(is_android) # Android - archs=x86,armebi-v7, extension=*.so
  
    ELSEIF(is_linux) # Linux - archs=x86,x86_64, extension=*.so

    ELSEIF(is_msvc_32) # WSA 32 bits - archs=x86, extension=*.dll
    
    ELSEIF(is_msvc_64) # WSA 64 bits - archs=x86, extension=*.dll

    ENDIF(is_ios)

ENDMACRO()

MACRO(ADD_FRAMEWORK fwname appname)
  find_library(FRAMEWORK_${fwname}
      NAMES ${fwname}
      PATHS ${CMAKE_OSX_SYSROOT}/System/Library
      PATH_SUFFIXES Frameworks
      NO_DEFAULT_PATH)
  IF( ${FRAMEWORK_${fwname}} STREQUAL FRAMEWORK_${fwname}-NOTFOUND)
      MESSAGE(ERROR ": Framework ${fwname} not found")
  ELSE()
      TARGET_LINK_LIBRARIES(${appname} ${FRAMEWORK_${fwname}})
      MESSAGE(STATUS "Framework ${fwname} found at ${FRAMEWORK_${fwname}}")
  ENDIF()
ENDMACRO(ADD_FRAMEWORK)

