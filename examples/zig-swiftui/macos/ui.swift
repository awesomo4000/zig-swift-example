import SwiftUI

// Global state to communicate between Zig and SwiftUI
class GlobalState: ObservableObject {
    static let shared = GlobalState()
    @Published var message: String = "SwiftUI launched from Zig!"
    @Published var syncBlockingCount: Int = 0
    @Published var asyncTaskCount: Int = 0
    @Published var immediateCount: Int = 0
}

// App delegate to handle window closing
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// SwiftUI App structure
struct ZigControlledApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var globalState = GlobalState.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(globalState)
                .frame(minWidth: 600, minHeight: 400)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .appTermination) {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}

// Main content view
struct ContentView: View {
    @EnvironmentObject var globalState: GlobalState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Zig-Controlled SwiftUI")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Zig is controlling the application lifecycle")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.horizontal, 40)
            
            Text(globalState.message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            VStack(spacing: 15) {
                // Synchronous blocking call (slow)
                HStack {
                    Button(action: {
                        // This blocks the UI thread
                        zig_callback_with_delay()
                        globalState.syncBlockingCount += 1
                    }) {
                        Label("Sync Blocking", systemImage: "tortoise.fill")
                            .frame(width: 150)
                    }
                    .buttonStyle(.bordered)
                    
                    Text("Count: \(globalState.syncBlockingCount)")
                        .frame(width: 80)
                        .font(.system(.body, design: .monospaced))
                    
                    Text("Blocks UI thread - slow updates")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Async Task call (better)
                HStack {
                    Button(action: {
                        Task {
                            zig_callback_from_swiftui()
                            await MainActor.run {
                                globalState.asyncTaskCount += 1
                            }
                        }
                    }) {
                        Label("Async Task", systemImage: "hare.fill")
                            .frame(width: 150)
                    }
                    .buttonStyle(.bordered)
                    
                    Text("Count: \(globalState.asyncTaskCount)")
                        .frame(width: 80)
                        .font(.system(.body, design: .monospaced))
                    
                    Text("Non-blocking but waits for Zig")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Immediate UI + async Zig (best)
                HStack {
                    Button(action: {
                        // Update count immediately
                        globalState.immediateCount += 1
                        print("[Button 3 - Immediate] UI updated, calling Zig async...")
                        
                        // Call Zig asynchronously
                        DispatchQueue.global(qos: .userInitiated).async {
                            zig_callback_from_swiftui()
                        }
                    }) {
                        Label("Immediate", systemImage: "bolt.fill")
                            .frame(width: 150)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Text("Count: \(globalState.immediateCount)")
                        .frame(width: 80)
                        .font(.system(.body, design: .monospaced))
                    
                    Text("Instant UI update + async Zig")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Export function to initialize SwiftUI from Zig
@_cdecl("swiftui_init")
public func swiftuiInit() {
    // Nothing special needed for initialization
}

// Export function to run SwiftUI app
@_cdecl("swiftui_run")
public func swiftuiRun() {
    // Create and run the SwiftUI app
    ZigControlledApp.main()
}

// Export function that Zig can call to update the UI
@_cdecl("swiftui_update_message")
public func swiftuiUpdateMessage(_ message: UnsafePointer<CChar>) {
    let swiftString = String(cString: message)
    if Thread.isMainThread {
        GlobalState.shared.message = swiftString
    } else {
        DispatchQueue.main.async {
            GlobalState.shared.message = swiftString
        }
    }
}

// Export function that Zig can call to update the count (not used in this example)
@_cdecl("swiftui_increment_count")
public func swiftuiIncrementCount() {
    // Not used - each button manages its own count
}

// Declare the Zig callback functions
@_silgen_name("zig_callback_from_swiftui")
func zig_callback_from_swiftui() -> Void

@_silgen_name("zig_callback_with_delay")
func zig_callback_with_delay() -> Void