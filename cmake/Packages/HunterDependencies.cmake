# Copyright (c) 2017, Luc Michalski
# All rights reserved.

# project context helpers and macros
include(sniper_context_builder)

macro(hunter_add_dependencies)

	# This list is required for static linking and exported to ${PROJECT_NAME}Config.cmake
	set(${PROJECT_NAME}_LINKER_LIBS "")
	set(PROJECT_IMPORTED_DEP "")
	set(PROJECT_IMPORTED_DEP_SERVER "")

	# ---[ Threads
	#find_package(Threads REQUIRED)
	#list(APPEND ${PROJECT_NAME}_LINKER_LIBS ${CMAKE_THREAD_LIBS_INIT})

	IF(is_ios OR is_android OR is_wsa)
		add_definitions(-DCPU_ONLY)
	ENDIF(is_ios OR is_android OR is_wsa)

	# ---[ OpenSSL
	IF(BUILD_OPENSSL)
		hunter_add_package(OpenSSL)
		find_package(OpenSSL REQUIRED) # OpenSSL::SSL OpenSSL::Crypto
		# Compatibilty mode
	    LIST(APPEND PROJECT_IMPORTED_DEP_SERVER  "OpenSSL=OpenSSL::SSL")
	    LIST(APPEND PROJECT_IMPORTED_DEP_SERVER  "OpenSSL=OpenSSL::Crypto")
	ENDIF(BUILD_OPENSSL)

	# ---[ BLAS
	IF(BUILD_BLAS)
		if(NOT APPLE)

		  set(BLAS "Atlas" CACHE STRING "Selected BLAS library")
		  set_property(CACHE BLAS PROPERTY STRINGS "Atlas;Open;MKL")

		  if(BLAS STREQUAL "Atlas" OR BLAS STREQUAL "atlas")
		    find_package(Atlas REQUIRED)
		    include_directories(SYSTEM ${Atlas_INCLUDE_DIR})
		    list(APPEND ${PROJECT_NAME}_LINKER_LIBS ${Atlas_LIBRARIES})
		  elseif(BLAS STREQUAL "Open" OR BLAS STREQUAL "open")
		    hunter_add_package(OpenBLAS)
		    find_package(OpenBLAS CONFIG REQUIRED)
		    list(APPEND ${PROJECT_NAME}_LINKER_LIBS OpenBLAS::OpenBLAS)
		  elseif(BLAS STREQUAL "MKL" OR BLAS STREQUAL "mkl")
		    find_package(MKL REQUIRED)
		    include_directories(SYSTEM ${MKL_INCLUDE_DIR})
		    list(APPEND ${PROJECT_NAME}_LINKER_LIBS ${MKL_LIBRARIES})
		    add_definitions(-DUSE_MKL)
		  endif()

		# for Apple platforms, need to use built-in framework Accelerate
		elseif(APPLE)

		  find_package(vecLib REQUIRED)
		  MESSAGE(STATUS "vecLib_INCLUDE_DIR: ${vecLib_INCLUDE_DIR}")
		  include_directories(SYSTEM ${vecLib_INCLUDE_DIR})
		  list(APPEND ${PROJECT_NAME}_LINKER_LIBS ${vecLib_LINKER_LIBS})
		  list(APPEND ${PROJECT_NAME}_INCLUDE_DIRS PUBLIC ${vecLib_INCLUDE_DIR})

		  	if(VECLIB_FOUND)
		    	if(NOT vecLib_INCLUDE_DIR MATCHES "^/System/Library/Frameworks/vecLib.framework.*")
		      		list(APPEND ${PROJECT_NAME}_DEFINITIONS PUBLIC -DUSE_ACCELERATE)
		    	endif()
		  	endif()

		  	MESSAGE(STATUS "vecLib_INCLUDE_DIR: ${vecLib_INCLUDE_DIR}")
		endif()
	ENDIF(BUILD_BLAS)

	# ---[ JPEG
	IF(BUILD_JPEG)
		# add new package
		hunter_activate_package(
				HUNTER_NAME 			"Jpeg"
				INTERFACE_NAMESPACE 	"JPEG::jpeg"
				FIND_BYNAME 			"JPEG"
				COMPATIBILITY_MODE 		"TRUE"
				INCLUDE_DIRS 			"TRUE"
			)
	ENDIF(BUILD_JPEG)

	# ---[ JPEG
	IF(BUILD_JPEG_WITHOUT_MACRO)
		hunter_add_package(Jpeg)
		IF(HUNTER_ENABLED)
			find_package(JPEG CONFIG REQUIRED) # JPEG::jpeg
			list(APPEND ${PROJECT_NAME}_LINKER_LIBS JPEG::jpeg)
		ENDIF(HUNTER_ENABLED)
		find_package(JPEG REQUIRED) # Compatibility mode
		IF(JPEG_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "Jpeg=JPEG::jpeg")
			add_definitions(-DUSE_LIBJPEG)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${JPEG_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(JPEG_FOUND)
	ENDIF(BUILD_JPEG_WITHOUT_MACRO)

	# ---[ TIFF
	IF(BUILD_TIFF)
		hunter_add_package(TIFF)
		IF(HUNTER_ENABLED)
			find_package(TIFF CONFIG REQUIRED) # TIFF::libtiff
			list(APPEND ${PROJECT_NAME}_LINKER_LIBS TIFF::libtiff)
		ENDIF(HUNTER_ENABLED)
		find_package(TIFF REQUIRED) # Compatibility mode
		IF(TIFF_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "TIFF=TIFF::libtiff")
			add_definitions(-DUSE_TIFF)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${TIFF_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(TIFF_FOUND)
	ENDIF(BUILD_TIFF)

	# ---[ ZLIB
	IF(BUILD_ZLIB)
		hunter_add_package(ZLIB)
		IF(HUNTER_ENABLED)
			find_package(ZLIB CONFIG REQUIRED) # ZLIB::zlib
			list(APPEND ${PROJECT_NAME}_LINKER_LIBS ZLIB::zlib)
		ENDIF(HUNTER_ENABLED)
		find_package(ZLIB REQUIRED) # Compatibility mode
		IF(ZLIB_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "ZLIB=ZLIB::zlib")
			add_definitions(-DUSE_ZLIB)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${ZLIB_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(ZLIB_FOUND)
	ENDIF(BUILD_ZLIB)

	# ---[ PNG
	IF(BUILD_PNG)
		hunter_add_package(PNG)
		IF(HUNTER_ENABLED)
			find_package(PNG CONFIG REQUIRED) # PNG::png
			list(APPEND ${PROJECT_NAME}_LINKER_LIBS PNG::png)
		ENDIF(HUNTER_ENABLED)
		find_package(PNG REQUIRED) # Compatibility mode
		IF(PNG_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "PNG=PNG::png")
			add_definitions(-DUSE_LIBPNG)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${PNG_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(PNG_FOUND)
	ENDIF(BUILD_PNG)

	# ---[ Protobuf
	IF(BUILD_PROTOBUF)

		# Compatibility Mode introduced by protobuf
		# * see examples/Protobuf-legacy for usage of protobuf_MODULE_COMPATIBLE=ON
		option(protobuf_MODULE_COMPATIBLE "use protobuf in module compatible mode" OFF)

		# If we cross compile for Android or iOS build a separate protoc executable on host to compile .proto files in CMake
		if(is_ios OR is_android)
		  # add cmake/host subdiretcory as host project to install protoc
		  include(hunter_experimental_add_host_project)
		  hunter_experimental_add_host_project(${CMAKE_CURRENT_LIST_DIR}/Host)

		  add_executable(protobuf::protoc IMPORTED)
		  set_property(TARGET protobuf::protoc APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
		  set_target_properties(protobuf::protoc PROPERTIES IMPORTED_LOCATION_RELEASE "${HUNTER_HOST_ROOT}/bin/protoc")

		  message(STATUS "Using imported protoc from host: ${HUNTER_HOST_ROOT}/bin/protoc")

		endif(is_ios OR is_android)

		hunter_add_package(Protobuf)
		IF(HUNTER_ENABLED)
			find_package(Protobuf CONFIG REQUIRED) # protobuf::libprotobuf
			list(APPEND ${PROJECT_NAME}_LINKER_LIBS protobuf::libprotobuf)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${Protobuf_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(HUNTER_ENABLED)
		find_package(Protobuf REQUIRED) # Compatibility mode

		IF(Protobuf_FOUND AND WITH_EXPERIMENTAL)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "Protobuf=protobuf::libprotobuf")
			add_definitions(-DUSE_PROTOBUF)
			# fetches protobuf version
			set(protobuf_header "${PROTOBUF_ROOT}/include/google/protobuf/stubs/common.h")

			if(NOT EXISTS "${protobuf_header}")
		  	message(FATAL_ERROR "File not found: ${protobuf_header}")
			endif()

			sniper_parse_header("${protobuf_header}" VERION_LINE GOOGLE_PROTOBUF_VERSION)
			string(REGEX MATCH "([0-9])00([0-9])00([0-9])" Protobuf_VERSION ${GOOGLE_PROTOBUF_VERSION})
			set(PROTOBUF_VERSION "${CMAKE_MATCH_1}.${CMAKE_MATCH_2}.${CMAKE_MATCH_3}")
			unset(GOOGLE_PROTOBUF_VERSION)

		ENDIF(Protobuf_FOUND AND WITH_EXPERIMENTAL)

	ENDIF(BUILD_PROTOBUF)

	# ---[ Google-glog
	IF(BUILD_GLOG)

		hunter_add_package(glog)
		IF(HUNTER_ENABLED)
			find_package(glog CONFIG REQUIRED)
			list(APPEND ${PROJECT_NAME}_LINKER_LIBS glog::glog)
		ENDIF(HUNTER_ENABLED)
		find_package(glog REQUIRED) # Compatibility mode
		IF(glog_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "glog=glog::glog")
			add_definitions(-DUSE_GLOG)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${glog_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(glog_FOUND)

	ENDIF(BUILD_GLOG)

	# ---[ flatbuffers
	IF(BUILD_FLATBUFFERS)
		hunter_add_package(flatbuffers)
		IF(HUNTER_ENABLED)
			find_package(flatbuffers CONFIG REQUIRED) # flatbuffers::flatbuffers
			list(APPEND ${PROJECT_NAME}_LINKER_LIBS flatbuffers::flatbuffers)
		ENDIF(HUNTER_ENABLED)
		find_package(flatbuffers REQUIRED) # Compatibility mode
		IF(flatbuffers_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "flatbuffers=flatbuffers::flatbuffers")
			add_definitions(-DUSE_FLATBUFFERS)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${flatbuffers_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(flatbuffers_FOUND)
	ENDIF(BUILD_FLATBUFFERS)

	# ---[ eigen3
	IF(BUILD_EIGEN3)
		hunter_add_package(Eigen)
		IF(HUNTER_ENABLED)
		  find_package(Eigen3 CONFIG REQUIRED) # Eigen3::Eigen
		  list(APPEND ${PROJECT_NAME}_LINKER_LIBS Eigen3::Eigen)
		ENDIF(HUNTER_ENABLED)
		find_package(Eigen3 REQUIRED) # Compatibility mode

		IF(Eigen_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "Eigen=Eigen3::Eigen")
			# Check if licenses was copied
			string(COMPARE EQUAL "${Eigen_LICENSES}" "" is_empty)
			if(is_empty)
				message(FATAL_ERROR "Licenses not found")
			endif()
			message("Eigen licenses:")
			foreach(x ${Eigen_LICENSES})
				message("* ${x}")
				if(NOT EXISTS "${Eigen_LICENSES}")
			  		message(FATAL_ERROR "File not found")
				endif()
			endforeach()
			add_definitions(-DUSE_EIGEN3)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${Eigen_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(Eigen_FOUND)
	ENDIF(BUILD_EIGEN3)

	## OpenCV 
	## nb. Mandatory dependency as everything relay on it for this native plugin :-)
	hunter_add_package(OpenCV)
	find_package(OpenCV REQUIRED)

	if(OpenCV_VERSION MATCHES "^2\\.")
		find_package(OpenCV REQUIRED COMPONENTS core highgui imgproc features2d nonfree)
	else()
		find_package(OpenCV REQUIRED COMPONENTS core highgui imgproc imgcodecs features2d xfeatures2d)
	endif()

	list(APPEND ${PROJECT_NAME}_LINKER_LIBS ${OpenCV_LIBS})
	# quick debug ouput
	MESSAGE(STATUS "OpenCV found (${OpenCV_CONFIG_PATH})")
	MESSAGE("OpenCV_FOUND: ${OpenCV_FOUND}")
	MESSAGE("OpenCV_DIR: ${OpenCV_DIR}")
	MESSAGE("OpenCV_CONFIG: ${OpenCV_CONFIG}")
	MESSAGE("OpenCV_LIBS: ${OpenCV_LIBS}")

	IF(OpenCV_FOUND)
		add_definitions(-DUSE_OPENCV)

		list(APPEND ${PROJECT_NAME}_LINKER_LIBS ${OpenCV_LIBS})
		message(STATUS "OpenCV found (${OpenCV_CONFIG_PATH})")

		FOREACH(OpenCV_DEP ${OpenCV_LIBS})
			LIST(APPEND PROJECT_IMPORTED_DEP  "OpenCV=${OpenCV_DEP}")
		ENDFOREACH()

		IF(PKG_INCLUDE_DIRS)
			INCLUDE_DIRECTORIES(${OpenCV_INCLUDE_DIRS})
		ENDIF(PKG_INCLUDE_DIRS)
	ENDIF(OpenCV_FOUND)

	# ---[ cereal
	IF(BUILD_CEREAL)
		IF(ANDROID)
		  MESSAGE(AUTHOR_WARNING "cereal is broken on Android (ref: https://travis-ci.org/ingenue/hunter/jobs/118219414) ")
		  # Broken: https://travis-ci.org/ingenue/hunter/jobs/118219414
		ENDIF()
		hunter_add_package(cereal)
		IF(HUNTER_ENABLED)
		  find_package(cereal CONFIG REQUIRED) # cereal::cereal
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS cereal::cereal)
		ENDIF(HUNTER_ENABLED)
		find_package(cereal REQUIRED) # Compatibility mode

		IF(cereal_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "cereal=cereal::cereal")
		  	add_definitions(-DUSE_CEREAL)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${cereal_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(cereal_FOUND)
	ENDIF(BUILD_CEREAL)

	# ---[ dlib
	IF(BUILD_DLIB)
		hunter_add_package(dlib)
		IF(HUNTER_ENABLED)
		  find_package(dlib CONFIG REQUIRED) # dlib::dlib
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS dlib::dlib)
		ENDIF(HUNTER_ENABLED)
		find_package(dlib REQUIRED) # Compatibility mode
		IF(dlib_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "dlib=dlib::dlib")
		  	add_definitions(-DUSE_DLIB)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${dlib_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(dlib_FOUND)
	ENDIF(BUILD_DLIB)

	# ---[ dest
	IF(BUILD_DEST)
		hunter_add_package(dest)
		IF(HUNTER_ENABLED)
		  find_package(dest CONFIG REQUIRED) # dest::dest
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS dest::dest)
		ENDIF(HUNTER_ENABLED)
		find_package(dest REQUIRED) # Compatibility mode
		IF(dest_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "dest=dest::dest")
		  	add_definitions(-DUSE_DEST)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${dest_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(dest_FOUND)
	ENDIF(BUILD_DEST)

	# ---[ eos
	IF(BUILD_EOS)
		hunter_add_package(eos)
		IF(HUNTER_ENABLED)
		  find_package(eos CONFIG REQUIRED) # eos::eos
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS eos::eos)
		ENDIF(HUNTER_ENABLED)
		find_package(eos REQUIRED) # Compatibility mode
		IF(eos_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "eos=eos::eos")
		  	add_definitions(-DUSE_EOS)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${eos_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(eos_FOUND)
	ENDIF(BUILD_EOS)

	# ---[ RapidJSON
	IF(BUILD_RAPIDJSON)
		hunter_add_package(RapidJSON)
		IF(HUNTER_ENABLED)
		  find_package(RapidJSON CONFIG REQUIRED) # RapidJSON::rapidjson
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS RapidJSON::rapidjson)
		ENDIF(HUNTER_ENABLED)
		find_package(RapidJSON REQUIRED) # Compatibility mode
		IF(RapidJSON_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "RapidJSON=RapidJSON::rapidjson")
		  	add_definitions(-DUSE_RAPIDJSON)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${RAPIDJSON_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(RapidJSON_FOUND)
	ENDIF(BUILD_RAPIDJSON)

	# ---[ RapidXML
	IF(BUILD_RAPIDXML)
		hunter_add_package(RapidXML)
		IF(HUNTER_ENABLED)
		  find_package(RapidXML CONFIG REQUIRED) # RapidXML::RapidXML
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS RapidXML::RapidXML)
		ENDIF(HUNTER_ENABLED)
		find_package(RapidXML REQUIRED) # Compatibility mode
		IF(RapidXML_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "RapidXML=RapidXML::RapidXML")
		  	add_definitions(-DUSE_RAPIDXML)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${RapidXML_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(RapidXML_FOUND)
	ENDIF(BUILD_RAPIDXML)

	# ---[ yaml-cpp
	IF(BUILD_YAML_CPP)
		hunter_add_package(yaml-cpp)
		IF(HUNTER_ENABLED)
		  find_package(yaml-cpp CONFIG REQUIRED) # yaml-cpp::yaml-cpp
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS yaml-cpp::yaml-cpp)
		ENDIF(HUNTER_ENABLED)
		find_package(yaml-cpp REQUIRED) # Compatibility mode
		IF(yaml-cpp_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "yaml-cpp=yaml-cpp::yaml-cpp")
		  	add_definitions(-DUSE_YAML_CPP)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${yaml-cpp_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(yaml-cpp_FOUND)
	ENDIF(BUILD_YAML_CPP)

	# ---[ libyuv
	IF(BUILD_LIBYUV)
		hunter_add_package(libyuv)
		IF(HUNTER_ENABLED)
		  	find_package(libyuv CONFIG REQUIRED) # libyuv::yuv
		  	LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS libyuv::yuv)
		ENDIF(HUNTER_ENABLED)
		find_package(libyuv REQUIRED) # Compatibility mode
		IF(libyuv_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "libyuv=libyuv::yuv")
		  	add_definitions(-DUSE_LIBYUV)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${LIBYUV_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(libyuv_FOUND)
	ENDIF(BUILD_LIBYUV)

	# ---[ ogles_gpgpu
	IF(BUILD_OGLES_GPU)
		hunter_add_package(ogles_gpgpu)
		IF(HUNTER_ENABLED)
		  find_package(ogles_gpgpu CONFIG REQUIRED) # ogles_gpgpu::ogles_gpgpu
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS ogles_gpgpu::ogles_gpgpu)
		ENDIF(HUNTER_ENABLED)
		#find_package(ogles_gpgpu REQUIRED) # Compatibility mode
		IF(ogles_gpgpu_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "ogles_gpgpu=ogles_gpgpu::ogles_gpgpu")
		  	add_definitions(-DUSE_OGLES_GPU)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${OGLES_GPU_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(ogles_gpgpu_FOUND)
	ENDIF(BUILD_OGLES_GPU)

	# ---[ AllTheFlopsThreads
	IF(BUILD_ALL_THE_FLOPS_THREADS)
		hunter_add_package(AllTheFlopsThreads)
		IF(HUNTER_ENABLED)
		  find_package(AllTheFlopsThreads CONFIG REQUIRED) # AllTheFlopsThreads::all_the_flops_threads
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS AllTheFlopsThreads::all_the_flops_threads)
		ENDIF(HUNTER_ENABLED)
		#find_package(AllTheFlopsThreads REQUIRED) # Compatibility mode
		IF(AllTheFlopsThreads_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "AllTheFlopsThreads=AllTheFlopsThreads::all_the_flops_threads")
		  	add_definitions(-DUSE_ALL_THE_FLOPS_THREADS)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${AllTheFlopsThreads_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(AllTheFlopsThreads_FOUND)
	ENDIF(BUILD_ALL_THE_FLOPS_THREADS)

	# ---[ thread-pool-cpp
	IF(BUILD_THREAD_POOL_CPP)
		hunter_add_package(thread-pool-cpp)
		IF(HUNTER_ENABLED)
		  find_package(thread-pool-cpp CONFIG REQUIRED) # thread-pool-cpp::thread-pool-cpp
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS thread-pool-cpp::thread-pool-cpp)
		ENDIF(HUNTER_ENABLED)
		#find_package(thread-pool-cpp REQUIRED) # Compatibility mode
		IF(thread-pool-cpp_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "thread-pool-cpp=thread-pool-cpp::thread-pool-cpp")
		  	add_definitions(-DUSE_THREAD_POOL_CPP)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${thread-pool-cpp_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(thread-pool-cpp_FOUND)
	ENDIF(BUILD_THREAD_POOL_CPP)

	# ---[ hdf5
	IF(BUILD_HDF5)
		hunter_add_package(hdf5)
		IF(HUNTER_ENABLED)
			find_package(ZLIB CONFIG REQUIRED)
			find_package(szip CONFIG REQUIRED)
		  	find_package(hdf5 CONFIG REQUIRED) # hdf5
		  	LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS hdf5)
		ENDIF(HUNTER_ENABLED)
		#find_package(CURL REQUIRED) # Compatibility mode
		IF(hdf5_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "hdf5=hdf5")
		  	add_definitions(-DUSE_HDF5)
			# target_link_libraries(foo PRIVATE CURL::libcurl)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${CURL_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(hdf5_FOUND)
	ENDIF(BUILD_HDF5)

	# ---[ msgpack
	IF(BUILD_MSGPACK)
		hunter_add_package(msgpack)
		IF(HUNTER_ENABLED)
		  	find_package(msgpack CONFIG REQUIRED) # msgpack::msgpack
		  	LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS msgpack)
		ENDIF(HUNTER_ENABLED)
		#find_package(msgpack REQUIRED) # Compatibility mode
		IF(hdf5_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "msgpack=msgpack::msgpack")
		  	add_definitions(-DUSE_MSGPACK)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${msgpack_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(hdf5_FOUND)
	ENDIF(BUILD_MSGPACK)

	# ---[ CURL
	IF(BUILD_CURL)
		hunter_add_package(CURL)
		IF(HUNTER_ENABLED)
		  find_package(CURL CONFIG REQUIRED) # CURL::libcurl
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS CURL::libcurl)
		ENDIF(HUNTER_ENABLED)
		#find_package(CURL REQUIRED) # Compatibility mode
		IF(CURL_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "CURL=CURL::libcurl")
		  	add_definitions(-DUSE_CURL)
			# target_link_libraries(foo PRIVATE CURL::libcurl)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${CURL_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(CURL_FOUND)
	ENDIF(BUILD_CURL)

	# to finish, try to implement the following dependencies (server side/client side) 
	# https://github.com/msgflo/msgflo-cpp

	# ---[ rabbitmq-c
	IF(BUILD_RABBITMQ)
		hunter_add_package(rabbitmq-c)
		find_package(rabbitmq-c CONFIG REQUIRED) # rabbitmq-c::rabbitmq-static
		# Compatibilty mode
		#target_link_libraries(foo rabbitmq-c::rabbitmq-static)
	ENDIF(BUILD_RABBITMQ)

	# ---[ ZeroMQ
	IF(BUILD_ZEROMQ)
		hunter_add_package(ZeroMQ) # 
		find_package(ZeroMQ CONFIG REQUIRED) # ZeroMQ::libzmq, ZeroMQ::libzmq-static
		if(CMAKE_SYSTEM_NAME STREQUAL Windows)
			MESSAGE(AUTHOR_WARNING "Not working with Windows platforms")
		endif()
	ENDIF(BUILD_ZEROMQ)

	# ---[ ZMQPP
	IF(BUILD_ZEROMQPP)
		hunter_add_package(ZMQPP) # ZMQPP::zmqpp
		find_package(ZMQPP CONFIG REQUIRED) # ZMQPP::zmqpp
	ENDIF(BUILD_ZEROMQPP)

	# ---[ websocketpp
	IF(BUILD_WEBSOCKETPP)
		hunter_add_package(websocketpp)
		find_package(websocketpp CONFIG REQUIRED) # websocketpp::websocketpp
		#set (CMAKE_CXX_STANDARD 11)
	ENDIF(BUILD_WEBSOCKETPP)

	# ---[ autobahn-cpp
	IF(BUILD_AUTOBAHN)
		hunter_add_package(autobahn-cpp)
		# set (CMAKE_CXX_STANDARD 11)
		find_package(autobahn-cpp CONFIG REQUIRED) # autobahn-cpp::autobahn-cpp
	ENDIF(BUILD_AUTOBAHN)

	# ---[ pthread-stubs
	IF(BUILD_PTHREAD_STUBS)
		hunter_add_package(pthread-stubs)
	ENDIF(BUILD_PTHREAD_STUBS)

	# ---[ xgboost
	IF(BUILD_XGBOOST)
		hunter_add_package(xgboost)
		IF(HUNTER_ENABLED)
		  find_package(xgboost CONFIG REQUIRED) # xgboost::xgboost
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS xgboost::xgboost)
		ENDIF(HUNTER_ENABLED)
		#find_package(xgboost REQUIRED) # Compatibility mode
		IF(xgboost_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "xgboost=xgboost::xgboost")
		  	add_definitions(-DUSE_XGBOOST)
			# target_link_libraries(foo PRIVATE CURL::libcurl)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${xgboost_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(xgboost_FOUND)
	ENDIF(BUILD_XGBOOST)

	# ---[ nlohmann-json
	IF(BUILD_NLOHMANN_JSON)
		hunter_add_package(nlohmann-json)
		IF(HUNTER_ENABLED)
		  find_package(nlohmann-json CONFIG REQUIRED) # nlohmann-json::nlohmann-json
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS nlohmann-json::nlohmann-json)
		ENDIF(HUNTER_ENABLED)
		#find_package(nlohmann-json REQUIRED) # Compatibility mode
		IF(nlohmann-json_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "nlohmann-json=nlohmann-json::nlohmann-json")
		  	add_definitions(-DUSE_NLOHMANN_JSON)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${nlohmann-json_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(nlohmann-json_FOUND)
	ENDIF(BUILD_NLOHMANN_JSON)

	# ---[ log4cplus
	IF(BUILD_LOG4CPLUS)
		hunter_add_package(log4cplus)
		IF(HUNTER_ENABLED)
		  find_package(log4cplus CONFIG REQUIRED) # log4cplus::log4cplus
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS log4cplus::log4cplus)
		ENDIF(HUNTER_ENABLED)
		IF(log4cplus_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "log4cplus=log4cplus::log4cplus")
		  	add_definitions(-DUSE_LOG4CPLUS)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${log4cplus_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
			if(ANDROID)
			  hunter_add_package(Android-Apk)
			  list(APPEND CMAKE_MODULE_PATH "${ANDROID-APK_ROOT}")
			  include(AndroidApk) # android_add_test
			  enable_testing()
			  #android_add_test(NAME FooTest COMMAND foo)
			  hunter_add_package(Android-SDK)
			  message("Path to `android`: ${ANDROID-SDK_ROOT}/android-sdk/tools/android")
			  message("Path to `emulator`: ${ANDROID-SDK_ROOT}/android-sdk/tools/emulator")
			  message("Path to `adb`: ${ANDROID-SDK_ROOT}/android-sdk/platform-tools/adb")
			endif()
		ENDIF(log4cplus_FOUND)
	ENDIF(BUILD_LOG4CPLUS)

	# ---[ caffe
	if(BUILD_CAFFE)
		hunter_add_package(caffe)
		IF(HUNTER_ENABLED)
		  find_package(Caffe CONFIG REQUIRED) # caffe
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS caffe)
		ENDIF(HUNTER_ENABLED)
		#find_package(Caffe REQUIRED) # Compatibility mode
		IF(Caffe_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "Caffe=caffe")
		  	add_definitions(-DUSE_CAFFE)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${Caffe_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(Caffe_FOUND)
	endif(BUILD_CAFFE)

	# ---[ TensorFlow
	if(BUILD_TENSORFLOW)
		hunter_add_package(TensorFlow)
		IF(HUNTER_ENABLED)
		  find_package(TensorFlow CONFIG REQUIRED) # TensorFlow
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS TensorFlow)
		ENDIF(HUNTER_ENABLED)
		#find_package(TensorFlow REQUIRED) # Compatibility mode
		IF(TensorFlow_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "TensorFlow=TensorFlow::TensorFlow")
		  	add_definitions(-DUSE_TENSORFLOW)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${Caffe_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(TensorFlow_FOUND)
	endif(BUILD_TENSORFLOW)

	# ---[ ArrayFire
	if(BUILD_ARRAYFIRE)
		hunter_add_package(ArrayFire)
		IF(HUNTER_ENABLED)
		  find_package(ArrayFire CONFIG REQUIRED)
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS ArrayFire::af)
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS ArrayFire::afcpu)
		ENDIF(HUNTER_ENABLED)
		#find_package(ArrayFire REQUIRED) # Compatibility mode
		IF(ArrayFire_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "ArrayFire=ArrayFire::afcpu")
		    LIST(APPEND PROJECT_IMPORTED_DEP  "ArrayFire=ArrayFire::af")
		  	add_definitions(-DUSE_ARRAY_FIRE)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${ArrayFire_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(ArrayFire_FOUND)
	endif(BUILD_ARRAYFIRE)

	# ---[ Catch
	if(BUILD_CATCH)
		hunter_add_package(Catch)
		IF(HUNTER_ENABLED)
		  find_package(Catch CONFIG REQUIRED) # Catch::Catch
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS Catch)
		ENDIF(HUNTER_ENABLED)
		#find_package(Catch REQUIRED) # Compatibility mode
		IF(Catch_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "Catch=Catch::Catch")
		  	add_definitions(-DUSE_CATCH)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${Catch_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(Catch_FOUND)
	endif(BUILD_CATCH)

	# ---[ cxxopts
	if(BUILD_CXXOPTS)
		hunter_add_package(cxxopts)
		IF(HUNTER_ENABLED)
		  find_package(cxxopts CONFIG REQUIRED) # cxxopts::cxxopts
		  LIST(APPEND ${PROJECT_NAME}_LINKER_LIBS cxxopts)
		ENDIF(HUNTER_ENABLED)
		IF(cxxopts_FOUND)
		    LIST(APPEND PROJECT_IMPORTED_DEP  "cxxopts=cxxopts::cxxopts")
		  	add_definitions(-DUSE_CXXOPTS)
			IF(PKG_INCLUDE_DIRS)
				INCLUDE_DIRECTORIES(${cxxopts_INCLUDE_DIRS})
			ENDIF(PKG_INCLUDE_DIRS)
		ENDIF(cxxopts_FOUND)
	endif(BUILD_CXXOPTS)

endmacro(hunter_add_dependencies)