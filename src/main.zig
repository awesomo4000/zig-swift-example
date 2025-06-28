const std = @import("std");

// This function is exported with a C ABI so that it can be called
// from other languages like Swift. The `export` keyword is key.
export fn hello_from_zig() void {
    std.debug.print("Hello from Zig!\n", .{});
}

// Export a function that returns a string from Zig
export fn get_message_from_zig() [*c]const u8 {
    return "Hello from Zig! This message was generated in Zig code.";
}