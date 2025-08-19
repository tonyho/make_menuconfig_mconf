# Git it for Windows/Linux

Just download it from the release page, the Linux version is static linked, so no libncurse is required.

## Standalone mconf (menuconfig) Builder

This directory contains extracted source files from the Linux kernel's kconfig system to build a standalone `mconf` (menuconfig) program.

## What is mconf?

mconf is the program behind `make menuconfig` - it provides a text-based menu interface for configuring kernel options using ncurses. This standalone version allows you to use the menuconfig interface with any Kconfig file, independent of the Linux kernel build system.

## Status

✅ **Fully Working** - The mconf standalone utility is now fully functional with both dynamic and static linking options.

### Recent Fixes (Latest Update)

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

Check the github action script in the .github/workflow, which has the commands to build it one both Windows and Linux.

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
