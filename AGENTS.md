# Zig-Swift Example Project Guidelines

## Build Commands
- **Build**: `zig build` - Builds Zig library and Swift app bundle
- **Run**: `zig build run` - Opens the macOS application
- **Clean**: `zig build clean` - Removes build artifacts
- **Test**: No test commands found (add tests to build.zig if needed)

## Code Style - Zig
- Use `const` for immutable values, `var` for mutable
- Export functions with C ABI using `export fn` for Swift interop
- Include headers in `include/` directory for C/Swift bindings
- Use `std.debug.print` for debug output
- Follow Zig naming: snake_case for functions/variables

## Code Style - Swift
- Use Swift 5+ modern syntax
- Follow Apple's Swift API Design Guidelines
- Use `import Cocoa` for macOS apps
- Implement proper AppDelegate lifecycle methods
- Use `#selector` syntax for target-action patterns

## Project Structure
- `src/`: Zig source files
- `macos/`: Swift source and Info.plist
- `include/`: C headers for FFI
- `zig-out/`: Build output directory

## Git Commits
- Never add "Generated with" or "Co-Authored-By" attributions