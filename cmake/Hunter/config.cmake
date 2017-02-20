# Copyright (c) 2017, Luc Michalski
# All rights reserved.

# ---[ Ensure CMake build type

	IF(NOT DEFINED HUNTER_CONFIGURATION_TYPE)
	  SET(HUNTER_CONFIGURATION_TYPE "Release")
	  MESSAGE(STATUS "[Sniper] Fixed CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
	ENDIF(NOT DEFINED HUNTER_CONFIGURATION_TYPE)

# ---[ Cross-Compilation cmake args for shared (with PIC) and static libraries

	set(is_wsa ${WSA}) # syntax compatibility
	set(is_android ${ANDROID}) # syntax compatibility
	string(COMPARE EQUAL "${CMAKE_OSX_SYSROOT}" "iphoneos" is_ios)
	string(COMPARE EQUAL "${CMAKE_SYSTEM_NAME}" "Linux" is_linux)
	string(COMPARE EQUAL "${CMAKE_GENERATOR}" "Xcode" is_xcode)
	if(is_xcode AND NOT is_ios)
	  set(is_osx TRUE)
	else()
	  set(is_osx TRUE)  
	endif()

	if(is_ios)
	  set(CMAKE_SHARED_LIBRARY_PREFIX_PATH "iOS")
	  set(CMAKE_SHARED_LIBRARY_SUFFIX ".a")
	  set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
	else(is_xcode AND not is_ios)
	  set(CMAKE_SHARED_LIBRARY_PREFIX_PATH "MacOSX")
	  set(CMAKE_SHARED_LIBRARY_SUFFIX ".bundle")
	  set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
	elseif(is_wsa)
	  set(CMAKE_SHARED_LIBRARY_PREFIX_PATH "WSA")
	  set(CMAKE_SHARED_LIBRARY_SUFFIX ".dll")
	  set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
	else()
	  set(CMAKE_SHARED_LIBRARY_PREFIX_PATH ".")
	  set(CMAKE_SHARED_LIBRARY_SUFFIX ".so")
	  set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
	endif()

  	#set(CMAKE_SHARED_LIBRARY_PREFIX_PATH "iOS")
  	#set(CMAKE_SHARED_LIBRARY_SUFFIX ".a")
  	#set(CMAKE_SHARED_LIBRARY_PREFIX "lib")

	# iOS = static libraries
	IF(is_ios)

		MESSAGE(STATUS "[Hunter] BUILDING STATIC LIBRARY *** ")
		SET(HUNTER_BUILD_CFG_PACKAGE
			 HUNTER_CONFIGURATION_TYPES=${HUNTER_CONFIGURATION_TYPE}
			 CMAKE_BUILD_TYPE=${HUNTER_CONFIGURATION_TYPE}
			 BUILD_SHARED_LIBS=OFF
			 CMAKE_SHARED_LIBRARY_SUFFIX=${CMAKE_SHARED_LIBRARY_SUFFIX}
			 CMAKE_SHARED_LIBRARY_PREFIX=${CMAKE_SHARED_LIBRARY_PREFIX}
			 CMAKE_CXX_FLAGS=-fPIC)

		SET(_arg_protobuf 	protobuf_BUILD_LIBPROTOBUF_LITE=ON
							protobuf_BUILD_PROTOC=ON
							protobuf_BUILD_SHARED_LIBS=OFF
							protobuf_WITH_ZLIB_DEFAULT=OFF							
							BUILD_SHARED_LIBS=OFF
							protobuf_BUILD_TESTS=OFF
							protobuf_BUILD_EXAMPLES=OFF)

	# other platforms require shared libraries
	ELSE()

		IF(is_osx)
			#set(CMAKE_OSX_ARCHITECTURES "$(ARCHS_UNIVERSAL_IPHONE_OS)")
		ENDIF(is_osx)

		MESSAGE(STATUS "[Hunter] BUILDING SHARED LIBRARY *** ")
		SET(HUNTER_BUILD_CFG_PACKAGE 
			 HUNTER_CONFIGURATION_TYPES=${HUNTER_CONFIGURATION_TYPE}
			 CMAKE_BUILD_TYPE=${HUNTER_CONFIGURATION_TYPE}
			 BUILD_SHARED_LIBS=ON
			 CMAKE_SHARED_LIBRARY_SUFFIX=${CMAKE_SHARED_LIBRARY_SUFFIX}
			 CMAKE_SHARED_LIBRARY_PREFIX=${CMAKE_SHARED_LIBRARY_PREFIX}
			 CMAKE_POSITION_INDEPENDENT_CODE=ON
			 HUNTER_INSTALL_WITH_DEPENDENCIES=ON
			 CMAKE_CXX_FLAGS=-fPIC)

		# 	protobuf_BUILD_LIBPROTOBUF_LITE=ON
		# 	protobuf_WITH_ZLIB_DEFAULT=ON
		#   BUILD_SHARED_LIBS=ON
		SET(_arg_protobuf 	protobuf_BUILD_PROTOC=ON
							protobuf_BUILD_SHARED_LIBS=ON
							protobuf_BUILD_TESTS=OFF
							protobuf_BUILD_EXAMPLES=OFF)

		#SET(_arg_protobuf 	protobuf_BUILD_SHARED_LIBS=ON
		#					HUNTER_INSTALL_WITH_DEPENDENCIES=ON 
		#					CMAKE_POSITION_INDEPENDENT_CODE=ON
		#					CMAKE_CXX_FLAGS=-fPIC)

	ENDIF()

# ---[ OpenCV

	SET(OpenCV_VERSION 3.1.0-p4)
	SET(OpenCV-Extra_VERSION 3.1.0-p0)

	

	# definied by not used for now as all cmake args were set in hunter directly
	if(ANDROID)
	  message("ANDROID =====================================================================")
	  include(SetOpenCVCMakeArgs-android) 
	  set_opencv_cmake_args_android()
	elseif(is_ios)
	  message("is_ios ======================================================================")
	  include(SetOpenCVCMakeArgs-iOS) 
	  set_opencv_cmake_args_ios()
	elseif(APPLE) 
	  message("APPLE =======================================================================")
	  include(SetOpenCVCMakeArgs-osx)
	  set_opencv_cmake_args_osx()
	elseif(is_linux)
	  message("is_linux ====================================================================")
	  include(SetOpenCVCMakeArgs-nix)
	elseif(MSCV)
	  message("MSVC ========================================================================")
	  include(SetOpenCVCMakeArgs-windows)
	endif()


#	  BUILD_opencv_videostab=OFF
#	  BUILD_opencv_stitching=OFF
#	  BUILD_opencv_hal=OFF
#	  BUILD_opencv_superres=OFF
#	  BUILD_opencv_video=OFF
#	  BUILD_opencv_python=OFF
#	  BUILD_opencv_viz=OFF
#	  BUILD_opencv_ts=OFF

#WITH_PNG:BOOL=FALSE -DCMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD="c++11" -DCMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY="libc++" 
#CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD="c++11"

	list(APPEND OPENCV_CMAKE_ARGS 
		WITH_PNG=OFF
	  	BUILD_opencv_world=OFF
	  	BUILD_opencv_dnn=OFF
	  	${HUNTER_BUILD_CFG_PACKAGE}
	)

	SET(HUNTER_OpenCV_CUSTOM_CMAKE_ARGS 			"")
	LIST(APPEND HUNTER_OpenCV_CUSTOM_CMAKE_ARGS 	"${HUNTER_BUILD_CFG_PACKAGE}")
	LIST(APPEND HUNTER_OpenCV_CUSTOM_CMAKE_ARGS 	"${OPENCV_CMAKE_ARGS}")

	if(is_ios)
		LIST(APPEND HUNTER_OpenCV_CUSTOM_CMAKE_ARGS 	"CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD=c++11")
		LIST(APPEND HUNTER_OpenCV_CUSTOM_CMAKE_ARGS 	"CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY=libc++")
	endif()

	FOREACH(_argCMakeConfig ${HUNTER_BUILD_CFG_PACKAGE})
	    MESSAGE(STATUS "[Hunter] OpenCV custom arg: ${_argCMakeConfig}")
	ENDFOREACH()	

	hunter_config(OpenCV 		VERSION 	"${OpenCV_VERSION}" 				CMAKE_ARGS 	"${HUNTER_OpenCV_CUSTOM_CMAKE_ARGS}")
	hunter_config(OpenCV-Extra 	VERSION 	"${OpenCV-Extra_VERSION}" 			CMAKE_ARGS 	"${HUNTER_OpenCV_CUSTOM_CMAKE_ARGS}")

# ---[ Eigen3

	SET(Eigen_VERSION 3.3.1-p3)
	hunter_config(Eigen 		VERSION 	"${Eigen_VERSION}" 			CMAKE_ARGS 	"${HUNTER_BUILD_CFG_PACKAGE}")

# ---[ dlib

	SET(dlib_VERSION 19.2-p1)

	if(is_ios)
		set(_dlib_ios_arg "DLIB_HEADER_ONLY=OFF")
	else()
		set(_dlib_ios_arg "DLIB_HEADER_ONLY=ON")
	endif()

	hunter_config(dlib
	    VERSION ${dlib_VERSION}
	    CMAKE_ARGS
	      ${_dlib_ios_arg}
	      DLIB_NO_GUI_SUPPORT=OFF
	      DLIB_GIF_SUPPORT=OFF
	      ${HUNTER_BUILD_CFG_PACKAGE}
	)

# ---[ Boost

	hunter_config(Boost 		VERSION 	"${HUNTER_Boost_VERSION}" 			CMAKE_ARGS 	"${HUNTER_BUILD_CFG_PACKAGE}")

# ---[ ZLIB

	hunter_config(ZLIB 			VERSION 	"${HUNTER_ZLIB_VERSION}" 			CMAKE_ARGS 	"${HUNTER_BUILD_CFG_PACKAGE}")

# ---[ PNG

	hunter_config(PNG 			VERSION 	"${HUNTER_PNG_VERSION}" 			CMAKE_ARGS 	"${HUNTER_BUILD_CFG_PACKAGE}")

# ---[ Jpeg

	hunter_config(Jpeg 			VERSION 	"${HUNTER_Jpeg_VERSION}" 			CMAKE_ARGS 	"${HUNTER_BUILD_CFG_PACKAGE}")

# ---[ flatbuffers

	hunter_config(flatbuffers 	VERSION 	"${HUNTER_flatbuffers_VERSION}" 	CMAKE_ARGS 	"${HUNTER_BUILD_CFG_PACKAGE}")

# ---[ cereal

	hunter_config(cereal 		VERSION 	"${HUNTER_cereal_VERSION}" 			CMAKE_ARGS 	"${HUNTER_BUILD_CFG_PACKAGE}")

# ---[ eos

	hunter_config(eos 			VERSION 	"${HUNTER_eos_VERSION}" 			CMAKE_ARGS 	"${HUNTER_BUILD_CFG_PACKAGE}")

# ---[ Sugar

	hunter_config(Sugar 		VERSION 	"${HUNTER_Sugar_VERSION}")

# ---[ Protobuf

	#hunter_config(Protobuf 		VERSION 	"${HUNTER_Protobuf_VERSION}")
	hunter_config(Protobuf
	    VERSION ${HUNTER_Protobuf_VERSION}
	    CMAKE_ARGS
	      ${_arg_protobuf}
	)

# ---[ rabbitmq-c

	hunter_config(rabbitmq-c 	VERSION 	"${HUNTER_rabbitmq-c_VERSION}" 		CMAKE_ARGS 	"${HUNTER_BUILD_CFG_PACKAGE}")

# ---[ ZeroMQ

	hunter_config(ZeroMQ 		VERSION 		"${HUNTER_ZeroMQ_VERSION}" 		CMAKE_ARGS 	"${HUNTER_BUILD_CFG_PACKAGE}")

# ---[ ZMQPP

	hunter_config(ZMQPP 		VERSION 		"${HUNTER_ZMQPP_VERSION}" 		CMAKE_ARGS 	"${HUNTER_BUILD_CFG_PACKAGE}")

# ---[ websocketpp

	hunter_config(websocketpp 	VERSION 	"${HUNTER_websocketpp_VERSION}" 	CMAKE_ARGS 	"${HUNTER_BUILD_CFG_PACKAGE}")

# ---[ autobahn-cpp

	hunter_config(autobahn-cpp 	VERSION 	"${HUNTER_autobahn-cpp_VERSION}" 	CMAKE_ARGS 	"${HUNTER_BUILD_CFG_PACKAGE}")

# ---[ Summary of target platform flags and cmake args passed to hunter 

	MESSAGE(STATUS "is_ios? ${is_ios}")
	MESSAGE(STATUS "is_osx? ${is_osx}")
	MESSAGE(STATUS "is_linux? ${is_linux}")
	MESSAGE(STATUS "is_android? ${is_android}")

	FOREACH(_argPkgConfig ${HUNTER_BUILD_CFG_PACKAGE})
	    MESSAGE(STATUS "[Hunter] Packages global arg: ${_argPkgConfig}")
	ENDFOREACH()	
