const std = @import("std");

// Import the Swift UI functions
extern fn swift_ui_init() void;
extern fn swift_ui_run() void;
extern fn swift_ui_stop() void;

pub fn main() !void {
    std.debug.print("Starting Zig-controlled application...\n", .{});
    
    // Initialize the Swift UI
    std.debug.print("Initializing Swift UI from Zig...\n", .{});
    swift_ui_init();
    
    // Run the Swift UI event loop
    std.debug.print("Running Swift UI event loop...\n", .{});
    swift_ui_run();
    
    std.debug.print("Application terminated.\n", .{});
}