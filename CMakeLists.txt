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

# Add compiler flags to suppress warnings from generated code and kernel code
# These warnings are common in Linux kernel code and generated files
add_compile_options(
    -Wno-pointer-to-int-cast
    -Wno-int-to-pointer-cast
    -Wno-missing-field-initializers
    -Wno-unused-parameter
    -Wno-sign-compare
    -Wno-builtin-declaration-mismatch
    -Wno-implicit-fallthrough
)

# Add Windows-specific settings
if(WIN32)
    # Define _WIN32 for Windows-specific code paths (mkdir, etc.)
    add_definitions(-D_WIN32)
    # Force disable NLS on Windows to avoid libintl dependency
    set(KBUILD_NO_NLS ON)
    set(DISABLE_NLS ON)
    # Define KBUILD_NO_NLS at compile time
    add_definitions(-DKBUILD_NO_NLS)
    # Define libintl function replacements to avoid linking issues
    add_definitions(
        -Dlibintl_fprintf=fprintf
        -Dlibintl_printf=printf
        -Dlibintl_sprintf=sprintf
        -Dlibintl_snprintf=snprintf
        -Dlibintl_vprintf=vprintf
        -Dlibintl_vfprintf=vfprintf
        -Dlibintl_vsnprintf=vsnprintf
        -Dlibintl_gettext=gettext
        -D__printf__=printf
    )
    # Additional Windows-specific warning suppressions
    add_compile_options(-Wno-format)
endif()

# Static linking
if(BUILD_STATIC)
    if(WIN32)
        # On Windows/MSYS2, ncurses is only available as DLL, so we can't do full static linking
        # We'll link statically what we can (libgcc, etc.) but ncurses will be dynamic
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libgcc")
        message(WARNING "Full static linking not possible on Windows - ncurses will be dynamically linked")
    else()
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
    endif()
endif()

# Add custom cmake modules path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Find ncurses/curses library
if(WIN32)
    # Use custom FindNCurses module for better Windows/MSYS2 support
    find_package(NCurses REQUIRED)
    
    if(NCURSES_FOUND)
        set(CURSES_LIBRARY ${NCURSES_LIBRARIES})
        set(CURSES_LOC ${NCURSES_CURSES_LOC})
        include_directories(${NCURSES_INCLUDE_DIRS})
    else()
        message(FATAL_ERROR "ncurses not found. Please install ncurses development package.")
    endif()
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

# Windows-specific additional libraries
if(WIN32)
    # For Windows, we don't link libintl since we disable NLS
    # Add Windows system libraries that might be needed
    target_link_libraries(mconf -lws2_32)
endif()

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