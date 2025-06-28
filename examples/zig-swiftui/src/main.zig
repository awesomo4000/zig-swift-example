const std = @import("std");

// Import the SwiftUI functions
extern fn swiftui_init() void;
extern fn swiftui_run() void;
extern fn swiftui_update_message(message: [*c]const u8) void;
extern fn swiftui_increment_count() void;
extern fn swiftui_update_progress(progress: f32) void;
extern fn swiftui_processing_complete() void;

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

// Export long-running task with progress updates
export fn zig_long_running_task() void {
    std.debug.print("[Button 4 - Progress] Starting long-running Zig task...\n", .{});
    
    // Update message
    swiftui_update_message("Zig is processing a complex task...");
    
    // Simulate a long-running task with progress updates
    const total_steps: u32 = 100;
    var i: u32 = 0;
    while (i <= total_steps) : (i += 1) {
        // Update progress
        const progress = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(total_steps));
        swiftui_update_progress(progress);
        
        // Log progress at key milestones
        if (i % 25 == 0) {
            std.debug.print("[Progress] Zig task at {}%\n", .{i});
        }
        
        // Simulate work - sleep for 30ms per step (3 seconds total)
        std.time.sleep(30_000_000); // 30ms
    }
    
    // Mark as complete
    std.debug.print("[Button 4 - Progress] Zig task completed!\n", .{});
    swiftui_processing_complete();
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