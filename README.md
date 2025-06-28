# zig-swift-example

Examples demonstrating interoperability between Zig and Swift on macOS.

## Prerequisites

- Zig 0.14.0 or later
- Xcode Command Line Tools (for Swift compiler)
- macOS

## Examples

This repository contains two examples showing different approaches to Zig-Swift interop:

### 1. Swift-as-Main Example

In this example, Swift controls the application lifecycle and calls functions implemented in Zig.

**Structure:**
- Swift creates the macOS app and UI
- Zig provides functions that Swift can call
- The main entry point is in Swift

**Build and run:**
```bash
# Run the example
zig build run-swift-main

# Build only (without running)
zig build -Dexample=swift-main

# Default build/run (backward compatible)
zig build
zig build run
```

**Key files:**
- `examples/swift-main/macos/main.swift` - Swift app entry point
- `examples/swift-main/src/main.zig` - Zig functions exported for Swift
- `examples/swift-main/include/x.h` - C header for Swift-Zig bridge

### 2. Zig-as-Main Example

In this example, Zig controls the application lifecycle and initializes the Swift UI.

**Structure:**
- Zig contains the main entry point
- Swift provides UI functions that Zig calls
- Demonstrates Zig driving a Swift/Cocoa application

**Build and run:**
```bash
# Run the example
zig build run-zig-main

# Build only (without running)
zig build -Dexample=zig-main
```

**Key files:**
- `examples/zig-main/src/main.zig` - Zig main entry point
- `examples/zig-main/macos/ui.swift` - Swift UI functions exported for Zig
- `examples/zig-main/include/swift_ui.h` - C header for Zig-Swift bridge

## How It Works

Both examples use C ABI as the bridge between Zig and Swift:
- Zig functions use `export fn` to be callable from Swift
- Swift functions use `@_cdecl` to be callable from Zig
- Header files declare the C interface

## Clean Build

To remove all build artifacts:
```bash
zig build clean
```

## Project Structure

```
zig-swift-example/
├── build.zig                 # Build configuration
├── examples/
│   ├── swift-main/         # Swift controls app lifecycle
│   │   ├── include/        # C headers
│   │   ├── macos/         # Swift source and Info.plist
│   │   └── src/           # Zig source
│   └── zig-main/          # Zig controls app lifecycle
│       ├── include/       # C headers
│       ├── macos/        # Swift source and Info.plist
│       └── src/          # Zig source
└── zig-out/               # Build output (generated)
```