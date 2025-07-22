# Standalone mconf (menuconfig) Builder

This directory contains extracted source files from the Linux kernel's kconfig system to build a standalone `mconf` (menuconfig) program.

## What is mconf?

mconf is the program behind `make menuconfig` - it provides a text-based menu interface for configuring kernel options using ncurses. This standalone version allows you to use the menuconfig interface with any Kconfig file, independent of the Linux kernel build system.

## Status

✅ **Fully Working** - The mconf standalone utility is now fully functional with both dynamic and static linking options.

### Recent Fixes (Latest Update)

1. **Segmentation Fault Fixed**: Resolved PACKAGE macro definition issue that was causing crashes during initialization
2. **Build System Improved**: Enhanced build scripts with better dependency checking and error handling
3. **Static Linking Working**: Successfully implemented static linking for completely portable binaries
4. **Cross-platform Support**: Verified working on Linux with plans for Windows support

## Features

- ✅ Full menuconfig functionality (menus, choices, string/int/hex input)
- ✅ Static linking support for portable binaries (1.4MB static vs 175KB dynamic)
- ✅ Cross-platform support (Linux, Windows via MinGW)
- ✅ Search functionality (press '/' in the menu)
- ✅ Help system (press '?' or 'H')
- ✅ Save/Load configuration files
- ✅ Color themes support via MENUCONFIG_COLOR environment variable

## Files Structure

```
mconf_standalone/
├── src/                    # Core source files
│   ├── mconf.c            # Main menuconfig program
│   ├── zconf.tab.c        # Kconfig parser (generated)
│   ├── confdata.c         # Configuration data handling
│   ├── expr.c             # Expression evaluation
│   ├── menu.c             # Menu handling
│   ├── symbol.c           # Symbol management
│   ├── util.c             # Utility functions
│   └── zconf.hash.c       # Hash table for keywords
├── lxdialog/              # Dialog interface (ncurses)
│   ├── checklist.c        # Checkbox/radiolist dialogs
│   ├── dialog.h           # Dialog interface header
│   ├── inputbox.c         # Text input dialogs
│   ├── menubox.c          # Menu dialogs
│   ├── textbox.c          # Text display dialogs
│   ├── util.c             # Dialog utilities
│   └── yesno.c            # Yes/No dialogs
├── include/               # Header files
│   ├── expr.h             # Expression definitions
│   ├── lkc.h              # Main kconfig header
│   ├── lkc_proto.h        # Function prototypes
│   └── list.h             # Linked list macros
├── build-linux.sh         # Linux build script (dynamic linking)
├── build-linux-static.sh  # Linux static build script
├── build-windows.sh       # Windows build script (MinGW)
├── CMakeLists.txt         # CMake configuration
├── test_Kconfig           # Sample Kconfig for testing
└── README.md              # This file
```

## Building

### Prerequisites

#### Linux
```bash
# Ubuntu/Debian
sudo apt-get install libncurses5-dev libncursesw5-dev

# CentOS/RHEL/Fedora
sudo yum install ncurses-devel  # or dnf install ncurses-devel

# Arch Linux
sudo pacman -S ncurses
```

#### Windows (Cross-compilation)
```bash
# Ubuntu/Debian
sudo apt-get install mingw-w64 libpdcurses-mingw-w64-dev

# Or build PDCurses manually for MinGW
```

### Build Methods

#### Method 1: Shell Scripts (Recommended)

**Linux (Dynamic Linking):**
```bash
cd mconf_standalone
./build-linux.sh          # Creates ~175KB binary with library dependencies
```

**Linux (Static Linking):**
```bash
cd mconf_standalone
./build-linux-static.sh   # Creates ~1.4MB fully portable binary
```

**Windows (cross-compile from Linux):**
```bash
cd mconf_standalone
./build-windows.sh
```

#### Method 2: CMake (Cross-platform)
```bash
cd mconf_standalone
mkdir build && cd build

# Standard build
cmake ..
make

# Static build (default)
cmake -DBUILD_STATIC=ON ..
make

# Disable NLS (Native Language Support)
cmake -DDISABLE_NLS=ON ..
make

# Windows cross-compile
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/mingw-w64.cmake ..
make
```

#### Method 3: Manual Compilation
```bash
cd mconf_standalone

# Linux
gcc -Wall -O2 -DCURSES_LOC='<ncurses.h>' -DPACKAGE='"mconf"' \
    -Iinclude -Ilxdialog \
    src/*.c lxdialog/*.c \
    -lncurses -ltinfo -static -o mconf

# Windows (with MinGW)
x86_64-w64-mingw32-gcc -Wall -O2 -DCURSES_LOC='<curses.h>' \
    -DPACKAGE='"mconf"' -DKBUILD_NO_NLS \
    -Iinclude -Ilxdialog \
    src/*.c lxdialog/*.c \
    -lpdcurses -static -static-libgcc -o mconf.exe
```

## Usage

### Basic Usage
```bash
# Use with provided test file
./mconf test_Kconfig

# Use with your own Kconfig file
./mconf /path/to/your/Kconfig

# If no file specified, looks for "Kconfig" in current directory
./mconf
```

### Environment Variables
```bash
# Single menu mode (all options in one large tree)
MENUCONFIG_MODE=single_menu ./mconf test_Kconfig

# Color themes
MENUCONFIG_COLOR=mono ./mconf test_Kconfig        # Monochrome
MENUCONFIG_COLOR=blackbg ./mconf test_Kconfig     # Black background
MENUCONFIG_COLOR=classic ./mconf test_Kconfig     # Classic blue
MENUCONFIG_COLOR=bluetitle ./mconf test_Kconfig   # Blue title (default)
```

### Keyboard Shortcuts
- **Arrow keys**: Navigate menus
- **Enter**: Select/enter submenu
- **Space**: Toggle boolean options or cycle through tristate
- **Y**: Set to yes/built-in
- **N**: Set to no/disabled  
- **M**: Set to module (if applicable)
- **?** or **H**: Show help
- **/**: Search for symbols
- **Z**: Toggle display of hidden options
- **ESC ESC**: Exit current menu/dialog
- **Tab**: Navigate between buttons in dialogs

### Configuration Files
- Configuration is saved to `.config` by default
- Use **Save** button to save to alternate file
- Use **Load** button to load from alternate file

## Testing

A sample `test_Kconfig` file is provided for testing the functionality:

```bash
./mconf test_Kconfig
```

This will open a test configuration with various option types:
- Boolean options
- String input
- Integer input with range validation
- Hexadecimal input
- Choice menus
- Dependent options

## Troubleshooting

### Build Issues

**"ncurses not found"**
```bash
# Make sure development headers are installed
sudo apt-get install libncurses5-dev  # Ubuntu/Debian
```

**"MinGW compiler not found"**
```bash
# Install MinGW-w64
sudo apt-get install mingw-w64  # Ubuntu/Debian
```

**Static linking fails**
```bash
# Some distributions need additional packages
sudo apt-get install libc6-dev-i386  # For 32-bit support
```

### Runtime Issues

**"Your display is too small"**
- Minimum terminal size: 19 lines × 80 columns
- Resize your terminal window

**Colors look wrong**
- Set TERM environment variable: `export TERM=xterm-256color`
- Try different color themes with MENUCONFIG_COLOR

**Segmentation fault**
- Check that your Kconfig file syntax is correct
- Try with the provided test_Kconfig first

## Integration

To integrate this standalone mconf into your project:

1. Copy the built `mconf` binary to your project
2. Create a `Kconfig` file describing your configuration options
3. Add build targets to call mconf:

```makefile
menuconfig: mconf
	./mconf Kconfig

mconf:
	# Build or copy the mconf binary
```

## License

This code is extracted from the Linux kernel and is licensed under GPL v2.0.

## Contributing

This is a standalone extraction. For improvements to the core kconfig system, contribute to the Linux kernel project.