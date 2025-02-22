##
 #######################################################################################################################
 #
 #  Copyright (c) 2017-2023 Advanced Micro Devices, Inc. All Rights Reserved.
 #
 #  Permission is hereby granted, free of charge, to any person obtaining a copy
 #  of this software and associated documentation files (the "Software"), to deal
 #  in the Software without restriction, including without limitation the rights
 #  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 #  copies of the Software, and to permit persons to whom the Software is
 #  furnished to do so, subject to the following conditions:
 #
 #  The above copyright notice and this permission notice shall be included in all
 #  copies or substantial portions of the Software.
 #
 #  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 #  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 #  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 #  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 #  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 #  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 #  SOFTWARE.
 #
 #######################################################################################################################

cmake_minimum_required(VERSION 3.13.4)

project(VKGC LANGUAGES C CXX)

### Standalone LLPC build handling
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    include(cmake/CompilerStandalone.cmake)
    set(LLPC_IS_STANDALONE ON)
endif()

### Top-level VKGC Interface ###
add_library(vkgc INTERFACE)

### VKGC header-only library ###
add_library(vkgc_headers INTERFACE)

### Cached Project Options #############################################################################################
option(LLPC_BUILD_TOOLS "LLPC build all tools" OFF)

### Options that affect the headers ####################################################################################
if (LLPC_CLIENT_INTERFACE_MAJOR_VERSION)
    target_compile_definitions(vkgc_headers INTERFACE LLPC_CLIENT_INTERFACE_MAJOR_VERSION=${LLPC_CLIENT_INTERFACE_MAJOR_VERSION})
else()
    message(FATAL_ERROR "Client of LLPC must set LLPC_CLIENT_INTERFACE_MAJOR_VERSION")
endif()

#if VKI_BUILD_GFX11
if(LLPC_BUILD_GFX11)
    target_compile_definitions(vkgc_headers INTERFACE VKI_BUILD_GFX11)
endif()
#endif

if(VKI_RAY_TRACING)
    if(NOT LLPC_IS_STANDALONE)
        target_compile_definitions(vkgc_headers INTERFACE HAVE_GPURT_SHIM)
    endif()

    target_compile_definitions(vkgc_headers INTERFACE VKI_RAY_TRACING)
    target_compile_definitions(vkgc_headers INTERFACE GPURT_CLIENT_INTERFACE_MAJOR_VERSION=${GPURT_CLIENT_INTERFACE_MAJOR_VERSION})
endif()

target_link_libraries(vkgc INTERFACE vkgc_headers)

### Expose header files ################################################################################################
target_include_directories(vkgc_headers
    INTERFACE
        ${PROJECT_SOURCE_DIR}/include
)

### external SPIRV headers #########################################################
if (NOT SPIRV_HEADERS_PATH)
    if(EXISTS ${PROJECT_SOURCE_DIR}/../SPIRV-Headers)
        set(SPIRV_HEADERS_PATH ${PROJECT_SOURCE_DIR}/../SPIRV-Headers CACHE PATH "The path of SPIRV headers.")
    elseif(EXISTS ${PROJECT_SOURCE_DIR}/../../../../SPIRV-Headers)
        set(SPIRV_HEADERS_PATH ${PROJECT_SOURCE_DIR}/../../../../SPIRV-Headers CACHE PATH "The path of SPIRV headers.")
    endif()
endif()

### Interface Target ###################################################################################################
### SPIRV Interface ###
add_library(khronos_spirv_interface INTERFACE)

if(EXISTS ${SPIRV_HEADERS_PATH})
    target_include_directories(khronos_spirv_interface
        INTERFACE
            ${SPIRV_HEADERS_PATH}/include
            ${PROJECT_SOURCE_DIR}/include/khronos
    )
    if (NOT SPIRV_HEADERS_PATH_INTERNAL)
        target_compile_definitions(khronos_spirv_interface
            INTERFACE
                EXTERNAL_SPIRV_HEADERS=1
        )
    endif()
else()
    target_include_directories(khronos_spirv_interface
        INTERFACE
            ${PROJECT_SOURCE_DIR}/include/khronos
    )
endif()

if(LLPC_BUILD_TOOLS)
# SPVGEN
if(EXISTS ${PROJECT_SOURCE_DIR}/../spvgen)
    set(XGL_SPVGEN_PATH ${PROJECT_SOURCE_DIR}/../spvgen CACHE PATH "Specify the path to SPVGEN.")
elseif(EXISTS ${PROJECT_SOURCE_DIR}/../xgl/tools/spvgen)
    set(XGL_SPVGEN_PATH ${PROJECT_SOURCE_DIR}/../xgl/tools/spvgen CACHE PATH "Specify the path to SPVGEN.")
else()
    set(XGL_SPVGEN_PATH ${PROJECT_SOURCE_DIR}/../../../tools/spvgen CACHE PATH "Specify the path to SPVGEN.")
endif()

if(EXISTS ${XGL_SPVGEN_PATH})
    set(XGL_SPVGEN_BUILD_PATH ${CMAKE_BINARY_DIR}/spvgen)
    add_subdirectory(${XGL_SPVGEN_PATH} ${XGL_SPVGEN_BUILD_PATH} EXCLUDE_FROM_ALL)
endif()

endif(LLPC_BUILD_TOOLS)

if(ICD_BUILD_LLPC)
    # Generate Strings for LLPC standalone tool and vkgc_gpurtshim
    add_subdirectory(util ${PROJECT_BINARY_DIR}/util)
endif()

### VKGC build LLPC ################################################################
if(ICD_BUILD_LLPC)
    target_include_directories(vkgc
        INTERFACE
            ${PROJECT_SOURCE_DIR}/llpc/include
            ${PROJECT_SOURCE_DIR}/lgc/include
    )

    add_subdirectory(llpc ${PROJECT_BINARY_DIR}/llpc)

    if(LLPC_BUILD_TESTS)
        set(LLVM_INCLUDE_TESTS ON CACHE BOOL "Force enable LLVM_INCLUDE_TESTS to include gmock" FORCE)
        add_subdirectory(test)
    endif()

    # Export the LLVM and spvgen build paths so that they are available in XGL,
    # when this is not an LLPC standalone build.
    if(NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
        set(XGL_LLVM_BUILD_PATH ${XGL_LLVM_BUILD_PATH} PARENT_SCOPE)
        if(DEFINED XGL_SPVGEN_BUILD_PATH)
            set(XGL_SPVGEN_BUILD_PATH ${XGL_SPVGEN_BUILD_PATH} PARENT_SCOPE)
        endif()
    endif()

    target_link_libraries(vkgc INTERFACE llpc)
endif()

# Set sub library properties
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")

    if (TARGET dumper)
        set_property(TARGET dumper_base PROPERTY FOLDER Compiler)
        set_property(TARGET dumper PROPERTY FOLDER Compiler)
    endif()

    if (TARGET vfx)
        set_property(TARGET vfx PROPERTY FOLDER Compiler)
    endif()

    if(ICD_BUILD_LLPC)
        set_property(TARGET llpc PROPERTY FOLDER Compiler)
        set_property(TARGET llpcinternal PROPERTY FOLDER Compiler)
        if(VKI_RAY_TRACING AND NOT LLPC_IS_STANDALONE)
            set_property(TARGET vkgc_gpurtshim PROPERTY FOLDER Compiler)
        endif()
        set_property(TARGET vkgc_util PROPERTY FOLDER Compiler)
        if (LLPC_BUILD_TOOLS)
            set_property(TARGET amdllpc PROPERTY FOLDER Compiler)
        endif()

        set_property(TARGET all-targets PROPERTY FOLDER Misc)
        set_property(TARGET AMDGPU PROPERTY FOLDER Misc)
        set_property(TARGET benchmark PROPERTY FOLDER Misc)
        set_property(TARGET benchmark_main PROPERTY FOLDER Misc)
        set_property(TARGET distribution PROPERTY FOLDER Misc)
        set_property(TARGET Engine PROPERTY FOLDER Misc)
        set_property(TARGET install-distribution PROPERTY FOLDER Misc)
        set_property(TARGET install-distribution-stripped PROPERTY FOLDER Misc)
        set_property(TARGET LLVMSupportBlake3 PROPERTY FOLDER Misc)
        set_property(TARGET Native PROPERTY FOLDER Misc)
        set_property(TARGET NativeCodeGen PROPERTY FOLDER Misc)
        set_property(TARGET opt-viewer PROPERTY FOLDER Misc)
        if (TARGET llvm-dialects-example)
            set_property(TARGET llvm-dialects-example PROPERTY FOLDER Misc)
        endif()
        if (LLVM_OPTIMIZED_TABLEGEN)
            set_property(TARGET llvm_nm_target PROPERTY FOLDER Misc)
            set_property(TARGET llvm_readobj_target PROPERTY FOLDER Misc)
            set_property(TARGET llvm-min-tblgen-host PROPERTY FOLDER Misc)
            set_property(TARGET llvm-tblgen-host PROPERTY FOLDER Misc)
            set_property(TARGET CONFIGURE_LLVM_NATIVE PROPERTY FOLDER Misc)
            set_property(TARGET CREATE_LLVM_NATIVE PROPERTY FOLDER Misc)
        endif()
        if (LLPC_BUILD_TESTS)
            set_property(TARGET check-all PROPERTY FOLDER Tests)
            if(NOT LLPC_IS_STANDALONE)
                set_property(TARGET check-amber PROPERTY FOLDER "LLPC Tests")
            endif()
            set_property(TARGET check-amdllpc PROPERTY FOLDER "LLPC Tests")
            set_property(TARGET check-amdllpc-units PROPERTY FOLDER "LLPC Tests")
            set_property(TARGET check-lgccps-units PROPERTY FOLDER "LgcCps Tests")
            set_property(TARGET check-lgc-units PROPERTY FOLDER "LGC Tests")
        endif()
    endif()
endif()
