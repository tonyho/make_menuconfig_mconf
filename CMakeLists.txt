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
            add_definitions(-DCURSES_LOC="<curses.h>")
        else()
            add_definitions(-DCURSES_LOC="<ncurses.h>")
        endif()
    else()
        message(FATAL_ERROR "Neither PDCurses nor ncurses found. Please install one of them.")
    endif()
else()
    find_package(Curses REQUIRED)
    set(CURSES_LIBRARY ${CURSES_LIBRARIES})
    add_definitions(-DCURSES_LOC="<ncurses.h>")
endif()

# Definitions
add_definitions(-DPACKAGE="mconf")
add_definitions(-DLOCALEDIR="/usr/share/locale")

if(DISABLE_NLS OR WIN32)
    add_definitions(-DKBUILD_NO_NLS)
endif()

# Include directories
include_directories(include)
include_directories(lxdialog)

# Source files
set(MCONF_SOURCES
    src/mconf.c
    src/zconf.tab.c
    src/confdata.c
    src/expr.c
    src/menu.c
    src/symbol.c
    src/util.c
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

# Link libraries
target_link_libraries(mconf ${CURSES_LIBRARY})

# On some systems, we need additional libraries
if(NOT WIN32)
    # Try to link with tinfo if available (for static linking)
    find_library(TINFO_LIBRARY tinfo)
    if(TINFO_LIBRARY)
        target_link_libraries(mconf ${TINFO_LIBRARY})
    endif()
endif()

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