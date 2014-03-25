###################################
## OpenBYOND Core Library
###################################

## Project Setup
cmake_minimum_required(VERSION 2.8)

## WHAT A CREATIVE NAME WOW
set(MODULE_NAME ${PROJECT_NAME}-core)

## Versioning shit
set(VERSION_MAJOR 0)
set(VERSION_MINOR 0)
set(VERSION_PATCH 1)

project(${MODULE_NAME})

## Configurations
# Set the default path for built executables to the "bin" directory
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/bin)
# set the default path for built libraries to the "lib" directory
set(LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/lib)

## Configure the build system
find_package(BISON)
find_package(FLEX)

BISON_TARGET(DMParser ${CMAKE_CURRENT_SOURCE_DIR}/grammar/parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp)
FLEX_TARGET(DMScanner ${CMAKE_CURRENT_SOURCE_DIR}/grammar/tokens.l ${CMAKE_CURRENT_BINARY_DIR}/tokens.cpp)
ADD_FLEX_BISON_DEPENDENCY(DMScanner DMParser)

# Add the include folder to the include path
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

# Set the source files, headers, and link libraries
file(${MODULE_NAME}_SRCS 
	${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)

set(${MODULE_NAME}_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}.h)

set(${MODULE_NAME}_LINK_LIBS )

# Compile the library
add_executable(${MODULE_NAME} ${${MODULE_NAME}_SRCS})
target_link_libraries(${MODULE_NAME} ${${MODULE_NAME}_LINK_LIBS})