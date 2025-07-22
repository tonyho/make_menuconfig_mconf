#!/bin/bash

# Build script for standalone mconf on Windows using MinGW with static linking

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building standalone mconf for Windows...${NC}"

# Check for MinGW compiler
MINGW_CC=""
for cc in x86_64-w64-mingw32-gcc i686-w64-mingw32-gcc mingw32-gcc; do
    if command -v $cc >/dev/null 2>&1; then
        MINGW_CC=$cc
        break
    fi
done

if [ -z "$MINGW_CC" ]; then
    echo -e "${RED}Error: MinGW compiler not found!${NC}"
    echo "Please install MinGW-w64:"
    echo "  Ubuntu/Debian: sudo apt-get install mingw-w64"
    echo "  CentOS/RHEL:   sudo yum install mingw64-gcc"
    echo "  Fedora:        sudo dnf install mingw64-gcc"
    echo "  Arch:          sudo pacman -S mingw-w64-gcc"
    echo "  macOS:         brew install mingw-w64"
    exit 1
fi

echo -e "${YELLOW}Using compiler: $MINGW_CC${NC}"

# Check for PDCurses or ncurses for Windows
CURSES_LIB=""
CURSES_HEADER=""

# Try to find PDCurses first (better for Windows)
if [ -f "/usr/x86_64-w64-mingw32/lib/libpdcurses.a" ] || [ -f "/usr/i686-w64-mingw32/lib/libpdcurses.a" ]; then
    CURSES_LIB="-lpdcurses"
    CURSES_HEADER="<curses.h>"
    echo -e "${YELLOW}Using PDCurses${NC}"
elif [ -f "/usr/x86_64-w64-mingw32/lib/libncurses.a" ] || [ -f "/usr/i686-w64-mingw32/lib/libncurses.a" ]; then
    CURSES_LIB="-lncurses"
    CURSES_HEADER="<ncurses.h>"
    echo -e "${YELLOW}Using ncurses${NC}"
else
    echo -e "${RED}Error: Neither PDCurses nor ncurses found for MinGW!${NC}"
    echo "Please install PDCurses for MinGW:"
    echo "  Ubuntu/Debian: sudo apt-get install libpdcurses-mingw-w64-dev"
    echo "Or build PDCurses manually and install it in the MinGW sysroot"
    exit 1
fi

# Compiler settings
CC=$MINGW_CC
CFLAGS="-Wall -Wextra -O2 -DCURSES_LOC='$CURSES_HEADER' -DPACKAGE='\"mconf\"' -DLOCALEDIR='\"/usr/share/locale\"' -DKBUILD_NO_NLS"
LDFLAGS="-static -static-libgcc"
LIBS="$CURSES_LIB"

# Include paths
INCLUDES="-Iinclude -Ilxdialog"

# Source files
SOURCES="src/mconf.c src/zconf.tab.c src/confdata.c src/expr.c src/menu.c src/symbol.c src/util.c"
LXDIALOG_SOURCES="lxdialog/checklist.c lxdialog/util.c lxdialog/inputbox.c lxdialog/textbox.c lxdialog/yesno.c lxdialog/menubox.c"

# Output binary
OUTPUT="mconf.exe"

echo -e "${YELLOW}Compiling...${NC}"

# Compile
$CC $CFLAGS $INCLUDES $SOURCES $LXDIALOG_SOURCES $LDFLAGS $LIBS -o $OUTPUT

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build successful!${NC}"
    echo -e "${GREEN}Executable: $OUTPUT${NC}"
    echo ""
    echo "Usage: ./$OUTPUT [Kconfig_file]"
    echo ""
    echo "If no Kconfig file is specified, it will look for 'Kconfig' in the current directory."
    
    # Show file size
    SIZE=$(stat -c%s "$OUTPUT" 2>/dev/null || stat -f%z "$OUTPUT" 2>/dev/null || echo "unknown")
    echo -e "${YELLOW}Binary size: $SIZE bytes${NC}"
    
    # Test if it's statically linked (for Windows, check with objdump if available)
    if command -v objdump >/dev/null 2>&1; then
        echo -e "${YELLOW}Checking dependencies:${NC}"
        objdump -p "$OUTPUT" | grep "DLL Name" || echo -e "${GREEN}✓ No dynamic dependencies found${NC}"
    fi
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi