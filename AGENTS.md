# Zig-Swift Example Project Guidelines

## Build Commands
- **Build default**: `zig build` - Builds Swift-as-main example (default)
- **Build swift-main only**: `zig build -Dexample=swift-main`
- **Build zig-main only**: `zig build -Dexample=zig-main`
- **Run swift-main**: `zig build run-swift-main` or `zig build run` (default)
- **Run zig-main**: `zig build run-zig-main`
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
- Use `import Cocoa` for macOS apps
- Implement proper AppDelegate lifecycle methods
- Use `#selector` syntax for target-action patterns
- Place Swift source in `examples/*/macos/`
- Use `-parse-as-library` flag when Zig controls main

## Project Structure
- `examples/swift-main/`: Swift controls app lifecycle
- `examples/zig-main/`: Zig controls app lifecycle
- `include/`: C headers for FFI in each example
- `zig-out/`: Build output directory
- Each example has its own Info.plist

## Git Commits
- Never add "Generated with" or "Co-Authored-By" attributions