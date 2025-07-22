#!/bin/bash

# Build script for standalone mconf on Linux with static linking

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building standalone mconf for Linux...${NC}"

# Check for required dependencies
echo -e "${YELLOW}Checking dependencies...${NC}"

# Check for ncurses development libraries
if ! pkg-config --exists ncurses; then
    echo -e "${RED}Error: ncurses development libraries not found!${NC}"
    echo "Please install ncurses development package:"
    echo "  Ubuntu/Debian: sudo apt-get install libncurses5-dev libncursesw5-dev"
    echo "  CentOS/RHEL:   sudo yum install ncurses-devel"
    echo "  Fedora:        sudo dnf install ncurses-devel"
    echo "  Arch:          sudo pacman -S ncurses"
    exit 1
fi

# Compiler settings
CC=${CC:-gcc}

# Try to find the right ncurses configuration
NCURSES_CFLAGS=""
NCURSES_LIBS=""

if pkg-config --exists ncurses; then
    NCURSES_CFLAGS="$(pkg-config --cflags ncurses)"
    NCURSES_LIBS="$(pkg-config --libs ncurses)"
elif pkg-config --exists ncursesw; then
    NCURSES_CFLAGS="$(pkg-config --cflags ncursesw)"
    NCURSES_LIBS="$(pkg-config --libs ncursesw)"
else
    # Fallback to standard locations
    NCURSES_LIBS="-lncurses"
    # Try to find tinfo separately
    if ldconfig -p 2>/dev/null | grep -q libtinfo; then
        NCURSES_LIBS="$NCURSES_LIBS -ltinfo"
    fi
fi

CFLAGS="-Wall -Wextra -O2 -DPACKAGE=\"\\\"mconf\\\"\" -DLOCALEDIR=\"\\\"/usr/share/locale\\\"\" $NCURSES_CFLAGS"
LDFLAGS=""
LIBS="$NCURSES_LIBS"

# Include paths
INCLUDES="-Iinclude -Ilxdialog -I."

# Source files (zconf.tab.c includes confdata.c, expr.c, menu.c, symbol.c, util.c)
SOURCES="src/mconf.c src/zconf.tab.c"
LXDIALOG_SOURCES="lxdialog/checklist.c lxdialog/util.c lxdialog/inputbox.c lxdialog/textbox.c lxdialog/yesno.c lxdialog/menubox.c"

# Output binary
OUTPUT="mconf"

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
    
    # Test if it's statically linked
    if command -v ldd >/dev/null 2>&1; then
        echo -e "${YELLOW}Checking if statically linked:${NC}"
        if ldd "$OUTPUT" 2>&1 | grep -q "not a dynamic executable"; then
            echo -e "${GREEN}✓ Successfully statically linked${NC}"
        else
            echo -e "${YELLOW}⚠ Dynamic linking detected:${NC}"
            ldd "$OUTPUT"
        fi
    fi
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi