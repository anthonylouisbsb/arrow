#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

source /multibuild/manylinux_utils.sh

# Quit on failure
set -e

PYTHON_VERSION=3.7
CPYTHON_PATH="$(cpython_path ${PYTHON_VERSION})"
PYTHON_INTERPRETER="${CPYTHON_PATH}/bin/python"
PIP="${CPYTHON_PATH}/bin/pip"

ARROW_BUILD_DIR=/tmp/arrow-build
mkdir -p "${ARROW_BUILD_DIR}"
pushd "${ARROW_BUILD_DIR}"

PATH="${CPYTHON_PATH}/bin:${PATH}"
export ARROW_TEST_DATA="/arrow/testing/data"
export PARQUET_TEST_DATA="/arrow/cpp/submodules/parquet-testing/data"
export AWS_EC2_METADATA_DISABLED=TRUE

cmake -DCMAKE_BUILD_TYPE=Release \
    -DARROW_DEPENDENCY_SOURCE="SYSTEM" \
    -DZLIB_ROOT=/usr/local \
    -DCMAKE_INSTALL_PREFIX=/arrow-dist \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DARROW_BUILD_TESTS=ON \
    -DARROW_BUILD_SHARED=ON \
    -DARROW_BOOST_USE_SHARED=OFF \
    -DARROW_PROTOBUF_USE_SHARED=OFF \
    -DARROW_OPENSSL_USE_SHARED=OFF \
    -DARROW_BROTLI_USE_SHARED=OFF \
    -DARROW_BZ2_USE_SHARED=OFF \
    -DARROW_GRPC_USE_SHARED=OFF \
    -DARROW_LZ4_USE_SHARED=OFF \
    -DARROW_SNAPPY_USE_SHARED=OFF \
    -DARROW_THRIFT_USE_SHARED=OFF \
    -DARROW_UTF8PROC_USE_SHARED=OFF \
    -DARROW_ZSTD_USE_SHARED=OFF \
    -DARROW_GANDIVA_PC_CXX_FLAGS="-isystem;/opt/rh/devtoolset-9/root/usr/include/c++/9;-isystem;/opt/rh/devtoolset-9/root/usr/include/c++/9/x86_64-redhat-linux;-isystem;-lpthread" \
    -DARROW_JEMALLOC=ON \
    -DARROW_RPATH_ORIGIN=ON \
    -DARROW_PYTHON=OFF \
    -DARROW_PARQUET=ON \
    -DARROW_DATASET=ON \
    -DARROW_FILESYSTEM=ON \
    -DPARQUET_REQUIRE_ENCRYPTION=OFF \
    -DPARQUET_BUILD_EXAMPLES=OFF \
    -DPARQUET_BUILD_EXECUTABLES=OFF \
    -DPythonInterp_FIND_VERSION=${PYTHON_VERSION} \
    -DARROW_GANDIVA=ON \
    -DARROW_GANDIVA_JAVA=ON \
    -DARROW_GANDIVA_JAVA7=ON \
    -DARROW_ORC=ON \
    -DARROW_JNI=ON \
    -DARROW_PLASMA=ON \
    -DARROW_PLASMA_JAVA_CLIENT=ON \
    -DBoost_NAMESPACE=arrow_boost \
    -Dgflags_SOURCE=BUNDLED \
    -DRapidJSON_SOURCE=BUNDLED \
    -DRE2_SOURCE=BUNDLED \
    -DARROW_BUILD_UTILITIES=OFF \
    -DBoost_NAMESPACE=arrow_boost \
    -DBOOST_ROOT=/arrow_boost_dist \
    -GNinja /arrow/cpp
ninja install
CTEST_OUTPUT_ON_FAILURE=1 ninja test
popd


# copy the library to distribution
cp -L  /arrow-dist/lib/libgandiva_jni.so /arrow/dist
cp -L  /arrow-dist/lib/libarrow_dataset_jni.so /arrow/dist
cp -L  /arrow-dist/lib/libarrow_orc_jni.so /arrow/dist