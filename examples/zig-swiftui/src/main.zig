const std = @import("std");

// Import the SwiftUI functions
extern fn swiftui_init() void;
extern fn swiftui_run() void;
extern fn swiftui_update_message(message: [*c]const u8) void;
extern fn swiftui_increment_count() void;

// Export callback function that SwiftUI can call
export fn zig_callback_from_swiftui() void {
    std.debug.print("[Button 1 - Sync Blocking] SwiftUI called back to Zig!\n", .{});
    
    // Update the message in SwiftUI
    swiftui_update_message("Zig processed the callback!");
}

// Export callback with simulated delay
export fn zig_callback_with_delay() void {
    std.debug.print("[Button 2 - Async Task] SwiftUI called Zig with delay!\n", .{});
    
    // Update message
    swiftui_update_message("Processing in Zig...");
    
    // Simulate heavy processing
    std.time.sleep(200_000_000); // 200ms delay
    
    // Update message again
    swiftui_update_message("Zig finished processing (with delay)");
}

pub fn main() !void {
    std.debug.print("Starting Zig-controlled SwiftUI application...\n", .{});
    
    // Initialize SwiftUI
    std.debug.print("Initializing SwiftUI from Zig...\n", .{});
    swiftui_init();
    
    // Set initial message
    swiftui_update_message("SwiftUI initialized by Zig - Ready for interaction!");
    
    // Run the SwiftUI app (this will block until the app quits)
    std.debug.print("Running SwiftUI event loop...\n", .{});
    swiftui_run();
    
    std.debug.print("SwiftUI application terminated.\n", .{});
}