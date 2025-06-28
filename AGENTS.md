# Zig-Swift Example Project Guidelines

## Build Commands
- **Build default**: `zig build` - Builds Swift AppKit example (default)
- **Build swift-appkit only**: `zig build -Dexample=swift-appkit`
- **Build swiftui-main only**: `zig build -Dexample=swiftui-main`
- **Build zig-appkit only**: `zig build -Dexample=zig-appkit`
- **Build zig-swiftui only**: `zig build -Dexample=zig-swiftui`
- **Run swift-appkit**: `zig build run-swift-appkit` or `zig build run` (default)
- **Run swiftui-main**: `zig build run-swiftui-main`
- **Run zig-appkit**: `zig build run-zig-appkit`
- **Run zig-swiftui**: `zig build run-zig-swiftui`
- **Clean**: `zig build clean` - Removes all build artifacts

## Code Style - Zig
- Use `const` for immutable values, `var` for mutable
- Export functions with C ABI using `export fn` for Swift interop
- Import Swift functions using `extern fn` declarations
- Use `std.debug.print` for debug output
- Follow Zig naming: snake_case for functions/variables
- Place Zig source in `examples/*/src/main.zig`

## Code Style - Swift
- Use Swift 5+ modern syntax
- Use `@_cdecl("function_name")` to export functions for Zig
- Use `import Cocoa` for AppKit apps, `import SwiftUI` for SwiftUI apps
- Implement proper AppDelegate lifecycle methods for AppKit
- Use `@main` and `App` protocol for SwiftUI apps
- Use `#selector` syntax for target-action patterns in AppKit
- Place Swift source in `examples/*/macos/`
- Use `-parse-as-library` flag when Zig controls main or with SwiftUI

## Project Structure
- `examples/swift-appkit/`: Swift AppKit controls app lifecycle
- `examples/swiftui-main/`: SwiftUI controls app lifecycle
- `examples/zig-appkit/`: Zig controls app lifecycle with AppKit UI
- `examples/zig-swiftui/`: Zig controls app lifecycle with SwiftUI UI
- `include/`: C headers for FFI in each example
- `zig-out/`: Build output directory
- Each example has its own Info.plist

## Git Commits
- Never add "Generated with" or "Co-Authored-By" attributions