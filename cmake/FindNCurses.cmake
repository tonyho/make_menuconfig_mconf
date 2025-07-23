# FindNCurses.cmake - Find ncurses library and headers
# This module defines:
#  NCURSES_FOUND - True if ncurses is found
#  NCURSES_LIBRARIES - The ncurses library
#  NCURSES_INCLUDE_DIRS - The ncurses include directories
#  NCURSES_CURSES_LOC - The header to include (e.g., <ncurses.h> or <ncurses/ncurses.h>)

# Find the library first
find_library(NCURSES_LIBRARIES
    NAMES ncurses pdcurses curses
    PATHS
        ${CMAKE_PREFIX_PATH}/lib
        $ENV{MSYSTEM_PREFIX}/lib
        /mingw64/lib
        /mingw32/lib
        /usr/lib
        /usr/local/lib
)

# Find the header
find_path(NCURSES_INCLUDE_DIRS
    NAMES ncurses.h
    PATHS
        ${CMAKE_PREFIX_PATH}/include/ncurses
        $ENV{MSYSTEM_PREFIX}/include/ncurses
        /mingw64/include/ncurses
        /mingw32/include/ncurses
        /usr/include/ncurses
        /usr/local/include/ncurses
        ${CMAKE_PREFIX_PATH}/include
        $ENV{MSYSTEM_PREFIX}/include
        /mingw64/include
        /mingw32/include
        /usr/include
        /usr/local/include
)

# Determine the correct header to include
if(NCURSES_INCLUDE_DIRS)
    if(EXISTS "${NCURSES_INCLUDE_DIRS}/ncurses.h")
        # Check if this is a subdirectory (like /mingw64/include/ncurses)
        get_filename_component(PARENT_DIR "${NCURSES_INCLUDE_DIRS}" NAME)
        if(PARENT_DIR STREQUAL "ncurses")
            set(NCURSES_CURSES_LOC "<ncurses/ncurses.h>")
            # Include the parent directory so we can use ncurses/ncurses.h
            get_filename_component(NCURSES_INCLUDE_DIRS "${NCURSES_INCLUDE_DIRS}" DIRECTORY)
        else()
            set(NCURSES_CURSES_LOC "<ncurses.h>")
        endif()
    else()
        set(NCURSES_CURSES_LOC "<ncurses.h>")
    endif()
else()
    set(NCURSES_CURSES_LOC "<ncurses.h>")
endif()

# Handle the QUIETLY and REQUIRED arguments
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(NCurses
    REQUIRED_VARS NCURSES_LIBRARIES NCURSES_INCLUDE_DIRS
    FAIL_MESSAGE "Could not find ncurses library and headers"
)

if(NCURSES_FOUND)
    message(STATUS "NCurses found:")
    message(STATUS "  Library: ${NCURSES_LIBRARIES}")
    message(STATUS "  Include: ${NCURSES_INCLUDE_DIRS}")
    message(STATUS "  Header:  ${NCURSES_CURSES_LOC}")
endif()

mark_as_advanced(NCURSES_LIBRARIES NCURSES_INCLUDE_DIRS NCURSES_CURSES_LOC)