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

set(TARGET_NAME "openbyond-core")

project(${MODULE_NAME})

## Configurations
# Set the default path for built executables to the "bin" directory
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/bin)
# set the default path for built libraries to the "lib" directory
set(LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/lib)

## Configure the build system
find_package(BISON)
find_package(FLEX)

## Build the compiler code
BISON_TARGET(DMParser ${CMAKE_CURRENT_SOURCE_DIR}/grammar/parser.y ${CMAKE_CURRENT_BINARY_DIR}/grammar/parser.cpp)
FLEX_TARGET(DMScanner ${CMAKE_CURRENT_SOURCE_DIR}/grammar/tokens.l ${CMAKE_CURRENT_BINARY_DIR}/grammar/tokens.cpp)
ADD_FLEX_BISON_DEPENDENCY(DMScanner DMParser)

# Add the include folder to the include path
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

# Set the source files, headers, and link libraries
##################
# BASIC TYPES
##################
set(BASICS_SOURCE
	${CMAKE_CURRENT_SOURCE_DIR}/src/string_utils.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/Atom.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/Value.cpp
	)
set(BASICS_INCLUDE
	${CMAKE_CURRENT_SOURCE_DIR}/include/string_utils.h
	${CMAKE_CURRENT_SOURCE_DIR}/include/Atom.h
	${CMAKE_CURRENT_SOURCE_DIR}/include/Value.h
	)

SOURCE_GROUP("src\\" FILES ${BASICS_INCLUDE})
SOURCE_GROUP("src\\" FILES ${BASICS_SOURCE})

##################
## SCRIPTING
##################
set(DMSCRIPT_SOURCE
	${CMAKE_CURRENT_BINARY_DIR}/grammar/parser.cpp
	${CMAKE_CURRENT_BINARY_DIR}/grammar/tokens.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/scripting/ObjectTree.cpp
	)
set(DMSCRIPT_INCLUDE
	${CMAKE_CURRENT_BINARY_DIR}/grammar/parser.hpp
	${CMAKE_CURRENT_SOURCE_DIR}/include/scripting/ObjectTree.h
	)

set(DMSCRIPT_RULES
	${CMAKE_CURRENT_SOURCE_DIR}/grammar/parser.y
	${CMAKE_CURRENT_SOURCE_DIR}/grammar/tokens.l
	)

# Add the flex and bison rules to any IDEs.
SOURCE_GROUP("grammar\\" FILES ${DMSCRIPT_RULES})

SOURCE_GROUP("src\\script" FILES ${DMSCRIPT_INCLUDE})
SOURCE_GROUP("src\\script" FILES ${DMSCRIPT_SOURCE})

set(${MODULE_NAME}_LINK_LIBS )

# Compile the library
add_executable(${TARGET_NAME} 
	${BASICS_INCLUDE} ${BASICS_SOURCE}
	${DMSCRIPT_INCLUDE} ${DMSCRIPT_SOURCE}
)
target_link_libraries(${MODULE_NAME} ${${MODULE_NAME}_LINK_LIBS})