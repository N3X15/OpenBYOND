# search for tclap Templatized C++ Command Line Parser

FIND_PATH(TCLAP_INCLUDE_DIR tclap/CmdLine.h
	/usr/local/include
	/usr/include
	lib/tclap-1.2.1/include
	lib/tclap-1.2.0/include
)
IF(TCLAP_INCLUDE_DIR)
	SET(TCLAP_FOUND TRUE)
	message(STATUS "Found TCLAP: ${TCLAP_INCLUDE_DIR}")
ELSE()
	SET(TCLAP_FOUND FALSE)
	message(FATAL_ERROR "Could not find TCLAP")
ENDIF()

