# zig-swift-example

Examples demonstrating interoperability between Zig and Swift on macOS.

## Prerequisites

- Zig 0.14.0 or later
- Xcode Command Line Tools (for Swift compiler)
- macOS

## Examples

This repository contains four examples showing different approaches to Zig-Swift interop:

### 1. Swift AppKit Example

In this example, Swift (using AppKit) controls the application lifecycle and calls functions implemented in Zig.

**Structure:**
- Swift creates the macOS app and UI
- Zig provides functions that Swift can call
- The main entry point is in Swift

**Build and run:**
```bash
# Run the example
zig build run-swift-appkit

# Build only (without running)
zig build -Dexample=swift-appkit

# Default build/run (backward compatible)
zig build
zig build run
```

**Key files:**
- `examples/swift-appkit/macos/main.swift` - Swift AppKit app entry point
- `examples/swift-appkit/src/main.zig` - Zig functions exported for Swift
- `examples/swift-appkit/include/x.h` - C header for Swift-Zig bridge

### 2. SwiftUI-as-Main Example

In this example, SwiftUI controls the application lifecycle and calls functions implemented in Zig.

**Structure:**
- SwiftUI creates the macOS app with modern declarative UI
- Zig provides functions that SwiftUI can call
- The main entry point is in SwiftUI using `@main`

**Build and run:**
```bash
# Run the example
zig build run-swiftui-main

# Build only (without running)
zig build -Dexample=swiftui-main
```

**Key files:**
- `examples/swiftui-main/macos/main.swift` - SwiftUI app entry point
- `examples/swiftui-main/src/main.zig` - Zig functions exported for SwiftUI
- `examples/swiftui-main/include/x.h` - C header for SwiftUI-Zig bridge

### 3. Zig AppKit Example

In this example, Zig controls the application lifecycle and initializes a Swift AppKit UI.

**Structure:**
- Zig contains the main entry point
- Swift provides UI functions that Zig calls
- Demonstrates Zig driving a Swift/Cocoa application

**Build and run:**
```bash
# Run the example
zig build run-zig-appkit

# Build only (without running)
zig build -Dexample=zig-appkit
```

**Key files:**
- `examples/zig-appkit/src/main.zig` - Zig main entry point
- `examples/zig-appkit/macos/ui.swift` - Swift AppKit UI functions exported for Zig
- `examples/zig-appkit/include/swift_ui.h` - C header for Zig-Swift bridge

### 4. Zig SwiftUI Example

In this example, Zig controls the application lifecycle and launches a SwiftUI app with advanced interop demonstrations.

**Structure:**
- Zig contains the main entry point
- SwiftUI provides the UI with bidirectional communication
- Demonstrates Zig driving a modern SwiftUI application
- Shows different callback patterns and UI responsiveness

**Features:**
- **Multiple callback patterns**: Demonstrates sync blocking, async task, and immediate UI update patterns
- **Progress tracking**: Shows how Zig can perform long-running tasks while updating SwiftUI progress bars
- **Responsive UI**: Maintains full UI responsiveness during heavy Zig computation

**Build and run:**
```bash
# Run the example
zig build run-zig-swiftui

# Build only (without running)
zig build -Dexample=zig-swiftui
```

**Key files:**
- `examples/zig-swiftui/src/main.zig` - Zig main entry point with callbacks and progress demo
- `examples/zig-swiftui/macos/ui.swift` - SwiftUI app demonstrating various interop patterns
- `examples/zig-swiftui/include/swiftui_bridge.h` - C header for bidirectional communication

## How It Works

All examples use C ABI as the bridge between Zig and Swift:

**Zig → Swift:**
- Zig functions use `export fn` to be callable from Swift
- Swift imports these functions via C headers or `@_silgen_name`

**Swift → Zig:**
- Swift functions use `@_cdecl("function_name")` to be callable from Zig
- Zig imports these functions using `extern fn` declarations

**Key patterns demonstrated:**
- **Swift AppKit/SwiftUI as main**: Zig provides a static library that Swift links against
- **Zig as main**: Zig compiles to object file and links with Swift code using `swiftc`
- **Bidirectional communication**: Both languages can call each other's functions
- **Async patterns**: Maintaining UI responsiveness during heavy computation
- **UI frameworks**: Examples using both AppKit (traditional) and SwiftUI (modern)

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
│   ├── swift-appkit/      # Swift AppKit controls app lifecycle
│   │   ├── include/       # C headers
│   │   ├── macos/        # Swift source and Info.plist
│   │   └── src/          # Zig source
│   ├── swiftui-main/      # SwiftUI controls app lifecycle
│   │   ├── include/       # C headers
│   │   ├── macos/        # SwiftUI source and Info.plist
│   │   └── src/          # Zig source
│   ├── zig-appkit/        # Zig controls AppKit app lifecycle
│   │   ├── include/       # C headers
│   │   ├── macos/        # Swift source and Info.plist
│   │   └── src/          # Zig source
│   └── zig-swiftui/       # Zig controls SwiftUI app lifecycle
│       ├── include/       # C headers
│       ├── macos/        # SwiftUI source and Info.plist
│       └── src/          # Zig source
└── zig-out/               # Build output (generated)
```