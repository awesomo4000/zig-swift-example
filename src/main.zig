const std = @import("std");

// This function is exported with a C ABI so that it can be called
// from other languages like Swift. The `export` keyword is key.
export fn hello_from_zig() void {
    std.debug.print("Hello from Zig!\n", .{});
}