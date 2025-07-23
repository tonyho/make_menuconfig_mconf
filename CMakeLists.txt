cmake_minimum_required(VERSION 3.10)
project(mconf_standalone C)

# Set C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Build options
option(BUILD_STATIC "Build statically linked binary" ON)
option(DISABLE_NLS "Disable Native Language Support" OFF)

# Compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra")
set(CMAKE_C_FLAGS_RELEASE "-O2 -DNDEBUG")

# Static linking
if(BUILD_STATIC)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
    if(WIN32)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libgcc")
    endif()
endif()

# Find ncurses/curses library
if(WIN32)
    # Try to find PDCurses first, then ncurses
    find_library(CURSES_LIBRARY NAMES pdcurses ncurses curses)
    if(CURSES_LIBRARY)
        if(CURSES_LIBRARY MATCHES "pdcurses")
            set(CURSES_LOC "<curses.h>")
        else()
            set(CURSES_LOC "<ncurses.h>")
        endif()
    else()
        message(FATAL_ERROR "Neither PDCurses nor ncurses found. Please install one of them.")
    endif()
    set(_WIN32 ON)
else()
    find_package(Curses REQUIRED)
    if(BUILD_STATIC)
        # For static linking, try to find static libraries
        find_library(NCURSES_STATIC_LIB libncurses.a PATHS /usr/lib /usr/lib/x86_64-linux-gnu /usr/local/lib)
        find_library(TINFO_STATIC_LIB libtinfo.a PATHS /usr/lib /usr/lib/x86_64-linux-gnu /usr/local/lib)
        if(NCURSES_STATIC_LIB)
            set(CURSES_LIBRARY ${NCURSES_STATIC_LIB})
            if(TINFO_STATIC_LIB)
                set(CURSES_LIBRARY ${CURSES_LIBRARY} ${TINFO_STATIC_LIB})
            else()
                # If static tinfo not found, try without it or use -ltinfo
                set(CURSES_LIBRARY ${CURSES_LIBRARY} -ltinfo)
            endif()
        else()
            # Fallback to dynamic libraries
            set(CURSES_LIBRARY ${CURSES_LIBRARIES})
            # Remove static linking flag if we can't find static libraries
            set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
        endif()
    else()
        set(CURSES_LIBRARY ${CURSES_LIBRARIES})
    endif()
    set(CURSES_LOC "<ncurses.h>")
endif()

# Configuration variables
set(PACKAGE_NAME "mconf")
set(LOCALEDIR "/usr/share/locale")

if(DISABLE_NLS OR WIN32)
    set(KBUILD_NO_NLS ON)
endif()

# Generate config.h
configure_file(config.h.in config.h @ONLY)

# Include directories
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/lxdialog)
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})

# Source files (zconf.tab.c includes confdata.c, expr.c, menu.c, symbol.c, util.c)
set(MCONF_SOURCES
    src/mconf.c
    src/zconf.tab.c
)

set(LXDIALOG_SOURCES
    lxdialog/checklist.c
    lxdialog/util.c
    lxdialog/inputbox.c
    lxdialog/textbox.c
    lxdialog/yesno.c
    lxdialog/menubox.c
)

# Create executable
add_executable(mconf ${MCONF_SOURCES} ${LXDIALOG_SOURCES})

# No additional compile definitions needed - using config.h

# Link libraries
target_link_libraries(mconf ${CURSES_LIBRARY})

# Additional libraries are already handled in the CURSES_LIBRARY setup above

# Install target
install(TARGETS mconf DESTINATION bin)

# Print configuration summary
message(STATUS "Configuration Summary:")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Static linking: ${BUILD_STATIC}")
message(STATUS "  Disable NLS: ${DISABLE_NLS}")
message(STATUS "  Curses library: ${CURSES_LIBRARY}")
message(STATUS "  C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "  C Flags: ${CMAKE_C_FLAGS}")