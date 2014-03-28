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

################################################
## FIND SHIT THAT FINDFLEX IS TOO LAZY TO FIND
################################################
if (NOT ${FLEX_INCLUDE_DIR} OR ${FLEX_INCLUDE_DIR} STREQUAL "FLEX_INCLUDE_DIR-NOTFOUND")
	# Last resort: Check lib/FlexLexer.h
	find_path(FLEX_INCLUDE_DIR
		NAMES
			FlexLexer.h
		PATHS
			../lib/
  )
endif (NOT ${FLEX_INCLUDE_DIR} OR ${FLEX_INCLUDE_DIR} STREQUAL "FLEX_INCLUDE_DIR-NOTFOUND")
if (NOT ${FL_LIBRARY} OR ${FL_LIBRARY} STREQUAL "FL_LIBRARY-NOTFOUND")
	# Last resort: Check lib/FlexLexer.h
	find_library(FL_LIBRARY 
		NAMES
			fl
		DOC
			"Path to the fl library"
		PATHS
			/lib
			/usr/local/lib
			../lib/
			C:\\cygwin64\\lib
		)
endif (NOT ${FL_LIBRARY} OR ${FL_LIBRARY} STREQUAL "FL_LIBRARY-NOTFOUND")

message("Writing config.h to ${CMAKE_CURRENT_BINARY_DIR}")
configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h)

# Add the include folder to the include path
include_directories(
	${CMAKE_CURRENT_BINARY_DIR}
	${CMAKE_CURRENT_BINARY_DIR}/grammar
	${CMAKE_CURRENT_SOURCE_DIR}/include 
	${FLEX_INCLUDE_DIR})

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
	${FLEX_DMScanner_OUTPUTS}
	${BISON_DMParser_OUTPUTS}
	${CMAKE_CURRENT_SOURCE_DIR}/src/scripting/ObjectTree.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/scripting/Driver.cpp
	)
set(DMSCRIPT_INCLUDE
	${CMAKE_CURRENT_SOURCE_DIR}/include/scripting/ObjectTree.h
	${CMAKE_CURRENT_SOURCE_DIR}/include/scripting/DMLexer.h
	${CMAKE_CURRENT_SOURCE_DIR}/include/scripting/Driver.h
	)

SOURCE_GROUP("src\\script" FILES ${DMSCRIPT_INCLUDE})
SOURCE_GROUP("src\\script" FILES ${DMSCRIPT_SOURCE})

set(${MODULE_NAME}_LINK_LIBS ${FLEX_LIBRARIES})

# Compile the library
add_executable(${TARGET_NAME} 
	${BASICS_INCLUDE} ${BASICS_SOURCE}
	${DMSCRIPT_INCLUDE} ${DMSCRIPT_SOURCE}
)
target_link_libraries(${MODULE_NAME} ${${MODULE_NAME}_LINK_LIBS})