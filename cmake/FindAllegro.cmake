# - Try to find Allegro include dirs and libraries
# Usage of this module as follows:
#
#   find_package(allegro 5.1 COMPONENTS main image primative color)
#
#   if(allegro_FOUND)
#      include_directories(${allegro_INCLUDE_DIRS})
#      add_executable(foo foo.cc)
#      target_link_libraries(foo ${allegro_LIBRARIES})
#
#      add_executable(bar bar.cc)
#      target_link_libraries(bar ${allegro_main_LIBRARIES})
#   endif()
#
# Variables defined by this module:
#
#   allegro_FOUND                       System has Allegro, this means the
#                                       include dir was found, as well as all
#                                       the libraries specified in the
#                                       COMPONENTS list.
#
#   allegro_INCLUDE_DIRS                Allegro include directories: not cached
#
#
#   allegro_LIBRARIES                   Link to these to use the Allegro
#                                       libraries that you specified: not
#                                       cached
#
#   allegro_LIBRARY_DIRS                The path to where the Allegro library
#                                       files are.
#
#   allegro_VERSION                     The version number of the allegro 
#                                       libraries that have been found
#
# For each component you specify in find_package(), the following (UPPER-CASE)
# variables are set.  You can use these variables if you would like to pick and
# choose components for your targets instead of just using Boost_LIBRARIES.
#
#   allegro_${COMPONENT}_FOUND          True IF the Allegro library
#                                       "component" was found.
#
#   allegro_${COMPONENT}_LIBRARY        Contains the libraries for the
#                                       specified Allegro "component"
#

#------------------------------------------------------------------------------
# Convenience msg macro
#------------------------------------------------------------------------------
macro(_allegro_msg msg)
  if (NOT allegro_FIND_QUIET)
    message(STATUS "Allegro: " ${msg})
  endif (NOT allegro_FIND_QUIET)
endmacro(_allegro_msg)

#------------------------------------------------------------------------------
# Setup some default variable values
#------------------------------------------------------------------------------
set(allegro_FOUND FALSE)
set(allegro_INCLUDE_DIRS )
set(allegro_LIBRARIES )
set(allegro_LIBRARY_DIRS )
set(allegro_VERSION )

#------------------------------------------------------------------------------
# Appends relavent include_dirs, libraries, and library_dirs
#------------------------------------------------------------------------------
macro(_allegro_add_component component)
  pkg_check_modules(
    allegro_pc_${component} QUIET allegro_${component}-${allegro_VERSION}
  )

  if (allegro_pc_${component}_FOUND)
    list(APPEND allegro_INCLUDE_DIRS ${allegro_pc_${component}_INCLUDE_DIRS})
    list(APPEND allegro_LIBRARIES ${allegro_pc_${component}_LIBRARIES})
    list(APPEND allegro_LIBRARY_DIRS ${allegro_pc_${component}_LIBRARY_DIRS})
    set(allegro_${component}_FOUND True)
    _allegro_msg("Found allegro_${component}-${allegro_VERSION}")
  else (allegro_pc_${component}_FOUND)
    set(allegro_${component}_FOUND False)
    _allegro_msg("Could not find allegro_${component}-${allegro_VERSION}")
    set(allegro_FOUND False)
  endif (allegro_pc_${component}_FOUND)
endmacro(_allegro_add_component)

#------------------------------------------------------------------------------
# Appends relavent include_dirs, libraries, and library_dirs for the core lib
#------------------------------------------------------------------------------
macro(_find_allegro)
  pkg_check_modules(allegro_pc QUIET allegro-${allegro_VERSION})

  if (allegro_pc_FOUND)
    list(APPEND allegro_INCLUDE_DIRS ${allegro_pc_INCLUDE_DIRS})
    list(APPEND allegro_LIBRARIES ${allegro_pc_LIBRARIES})
    list(APPEND allegro_LIBRARY_DIRS ${allegro_pc_LIBRARY_DIRS})
    set(allegro_FOUND True)
    _allegro_msg("Found allegro-${allegro_VERSION}")
  else (allegro_pc_FOUND)
    set(allegro_FOUND False)
    _allegro_msg("Could not find allegro-${allegro_VERSION}")
  endif (allegro_pc_FOUND)
endmacro(_find_allegro)

#------------------------------------------------------------------------------
# This module piggy backs on the pkg-config system provided by Allegro
#------------------------------------------------------------------------------
find_package(PkgConfig)
if (PKGCONFIG_FOUND)
  # Get the highest version of allegro found in pkg-config
  execute_process(
    COMMAND ${PKG_CONFIG_EXECUTABLE} "--list-all"
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    RESULT_VARIABLE pc_result
    OUTPUT_VARIABLE pc_out
  )
  string(REGEX MATCHALL "allegro-..." VERSION_STRS "${pc_out}")
  set(allegro_VERSION 0.0)
  foreach (VERSION_STR_IT ${VERSION_STRS})
    string(REGEX MATCH "[0-9].[0-9]" VERSION_STR_IT "${VERSION_STR_IT}")
    if (${VERSION_STR_IT} VERSION_GREATER ${allegro_VERSION})
      set(allegro_VERSION "${VERSION_STR_IT}")
    endif (${VERSION_STR_IT} VERSION_GREATER ${allegro_VERSION})
  endforeach (VERSION_STR_IT ${VERSION_STRS})
  if (allegro_VERSION VERSION_GREATER 0.0)
    _allegro_msg("Using version ${allegro_VERSION}")
    # No matter what find the core allegro library
    _find_allegro()
    if (allegro_FIND_COMPONENTS)
      foreach (COMPONENT ${allegro_FIND_COMPONENTS})
        STRING(TOLOWER ${COMPONENT} COMPONENT)
        _allegro_add_component(${COMPONENT})
      endforeach (COMPONENT ${allegro_FIND_COMPONENTS})
    endif (allegro_FIND_COMPONENTS)
  else (allegro_VERSION VERSION_GREATER 0.0)
    _allegro_msg("Could not find any version of allegro in pkg-config")
  endif (allegro_VERSION VERSION_GREATER 0.0)
else (PKGCONFIG_FOUND)
  _allegro_msg("Could not find pkg-config")
endif (PKGCONFIG_FOUND)

#------------------------------------------------------------------------------
# Make the lists unique
#------------------------------------------------------------------------------
list(REMOVE_DUPLICATES allegro_INCLUDE_DIRS)
list(REMOVE_DUPLICATES allegro_LIBRARIES)
list(REMOVE_DUPLICATES allegro_LIBRARY_DIRS)

#------------------------------------------------------------------------------
# If not found and REQUIRED error out
#------------------------------------------------------------------------------
if (allegro_FIND_REQUIRED AND NOT allegro_FOUND)
  message(FATAL_ERROR "Could not find Allegro")
endif (allegro_FIND_REQUIRED AND NOT allegro_FOUND)
