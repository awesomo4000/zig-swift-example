#ifndef SWIFTUI_BRIDGE_H
#define SWIFTUI_BRIDGE_H

// SwiftUI functions that can be called from Zig
void swiftui_init(void);
void swiftui_run(void);
void swiftui_update_message(const char* message);
void swiftui_increment_count(void);

// Zig functions that SwiftUI can call
void zig_callback_from_swiftui(void);
void zig_callback_with_delay(void);

#endif // SWIFTUI_BRIDGE_H