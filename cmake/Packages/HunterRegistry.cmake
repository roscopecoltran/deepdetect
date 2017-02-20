# Copyright (c) 2017, Luc Michalski
# All rights reserved.

# ---[ Computation Algebra

	OPTION(BUILD_BLAS "" ON)
	OPTION(BUILD_EIGEN3 "" ON)

# ---[ CLI

	OPTION(BUILD_CXXOPTS "" ON)

# ---[ Codecs

	OPTION(BUILD_JPEG "" ON)
	OPTION(BUILD_TIFF "" ON)
	OPTION(BUILD_PNG "" ON)

# ---[ Image Processing

	OPTION(BUILD_LIBYUV "" ON)

# ---[ Compression

	OPTION(BUILD_ZLIB "" ON)

# ---[ Debug

	OPTION(BUILD_CATCH "" ON)

# ---[ Data Parsing

	OPTION(BUILD_RAPIDJSON "" ON)
	OPTION(BUILD_RAPIDXML "" ON)
	OPTION(BUILD_YAML_CPP "" ON)
	OPTION(BUILD_NLOHMANN "" ON)

# ---[ Serialization

	OPTION(BUILD_PROTOBUF "" ON)
	OPTION(BUILD_FLATBUFFERS "" ON)
	OPTION(BUILD_CEREAL "" ON)
	OPTION(BUILD_MSGPACK "" ON)

# ---[ Logging

	OPTION(BUILD_GLOG "" ON)
	OPTION(BUILD_LOG4CPLUS "" ON)
	# https://github.com/ruslo/hunter/blob/master/examples/log4cplus/CMakeLists.txt

# ---[ GPGPU / Multi-threading

	OPTION(BUILD_OGLES_GPU "" ON)
	OPTION(BUILD_THREAD_POOL_CPP "" ON)
	OPTION(BUILD_ALL_THE_FLOPS_THREADS "" ON)
	OPTION(BUILD_PTHREAD_STUBS "" ON)

# ---[ Machine Learning 

	OPTION(BUILD_DLIB "" OFF)

# ---[ Vision - Facial Landmarks 

	OPTION(BUILD_DEST "" ON)

# ---[ Vision - Facial Reconstruction 3D

	OPTION(BUILD_EOS "" ON)

# ---[ Network - Message Queueing 

	OPTION(BUILD_RABBITMQ "" ON)
	OPTION(BUILD_ZEROMQ "" ON)
	OPTION(BUILD_ZEROMQPP "" ON)

# ---[ Network - Web Sockets 

	OPTION(BUILD_WEBSOCKETPP "" ON)
	OPTION(BUILD_AUTOBAHN "" ON)

# ---[ Network / Crypto

	OPTION(BUILD_OPENSSL "" ON)

# ---[ Network - Web 

	OPTION(BUILD_CURL "" OFF)

# ---[ Filesystem - Distributed 

	OPTION(BUILD_HDF5 "" ON)

# ---[ Machine Learning  

	OPTION(BUILD_XGBOOST "" ON)
	OPTION(BUILD_ARRAYFIRE "" ON)
	OPTION(BUILD_CAFFE "" OFF)
	OPTION(BUILD_TENSORFLOW "" OFF)
	OPTION(BUILD_DEEPDETECT "" OFF) # not ready yet




