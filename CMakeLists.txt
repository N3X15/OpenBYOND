##########################################
## OpenBYOND - Compile Script
##########################################

cmake_minimum_required(VERSION 2.8)

## WHAT A CREATIVE NAME WOW
set(PROJECT_NAME openbyond)

## Versioning shit
set(VERSION_MAJOR 0)
set(VERSION_MINOR 0)
set(VERSION_PATCH 1)

# Uncomment the line below to set the build type
# set(CMAKE_BUILD_TYPE DEBUG)

# Extend the find_package search path
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")

# Find Allegro
find_package(allegro 5.0 REQUIRED COMPONENTS
  main font ttf native_dialog primitives tiled
)
#include_directories(${allegro_INCLUDE_DIRS})
#list(APPEND ${PROJECT_NAME}_LINK_LIBS ${allegro_LIBRARIES})

#
# Every module has a CMakeLists.txt in it's root. 
set (MODULES 
	${CMAKE_SOURCE_DIR}/openbyond-core
	${CMAKE_SOURCE_DIR}/openbyond-tools
#	${CMAKE_SOURCE_DIR}/openbyond-server
#	${CMAKE_SOURCE_DIR}/openbyond-client
#	${CMAKE_SOURCE_DIR}/openbyond-ide
)

# 
# Each module has an include directory where all the headers go to.
# To make it easier to find header files, I decided to make all the headers 
# available to all modules globally.
# You can achieve this using include_directories in the root CMakeLists.txt
# before loading the modules.
foreach ( MODULE ${MODULES} )
  include_directories ( "${MODULE}/include/" )
endforeach ()

#
# After adding the include paths, the only remaining thing is to 
# include each CMakeLists.txt for each module.
# add_subdirectory searches for a CMakeLists.txt file in the given
# directory, so that's what we use to include each module's build script.
foreach ( MODULE ${MODULES} )
  add_subdirectory ( ${MODULE} )
endforeach ()
