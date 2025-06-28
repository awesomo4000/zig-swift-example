import SwiftUI

// Global state to communicate between Zig and SwiftUI
class GlobalState: ObservableObject {
    static let shared = GlobalState()
    @Published var message: String = "SwiftUI launched from Zig!"
    @Published var syncBlockingCount: Int = 0
    @Published var asyncTaskCount: Int = 0
    @Published var immediateCount: Int = 0
    @Published var progressCount: Int = 0
    @Published var progressValue: Double = 0.0
    @Published var isProcessing: Bool = false
}

// App delegate to handle window closing
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Activate the app and bring window to front
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
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
                
                // Progress example - Long running Zig task with UI updates
                VStack(spacing: 10) {
                    HStack {
                        Button(action: {
                            // Update count immediately
                            globalState.progressCount += 1
                            globalState.isProcessing = true
                            globalState.progressValue = 0.0
                            print("[Button 4 - Progress] Starting long-running Zig task...")
                            
                            // Call Zig asynchronously for long-running task
                            DispatchQueue.global(qos: .userInitiated).async {
                                zig_long_running_task()
                            }
                        }) {
                            Label("Progress Demo", systemImage: "chart.line.uptrend.xyaxis")
                                .frame(width: 150)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(globalState.isProcessing)
                        
                        Text("Count: \(globalState.progressCount)")
                            .frame(width: 80)
                            .font(.system(.body, design: .monospaced))
                        
                        Text("Long task with progress updates")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if globalState.isProcessing {
                        ProgressView(value: globalState.progressValue, total: 1.0) {
                            Text("Processing: \(Int(globalState.progressValue * 100))%")
                                .font(.caption)
                        }
                        .progressViewStyle(.linear)
                        .frame(maxWidth: 400)
                    }
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

// Export function that Zig can call to update progress
@_cdecl("swiftui_update_progress")
public func swiftuiUpdateProgress(_ progress: Float) {
    DispatchQueue.main.async {
        GlobalState.shared.progressValue = Double(progress)
    }
}

// Export function that Zig can call when processing is complete
@_cdecl("swiftui_processing_complete")
public func swiftuiProcessingComplete() {
    DispatchQueue.main.async {
        GlobalState.shared.isProcessing = false
        GlobalState.shared.progressValue = 1.0
        GlobalState.shared.message = "Long-running task completed!"
    }
}

// Declare the Zig callback functions
@_silgen_name("zig_callback_from_swiftui")
func zig_callback_from_swiftui() -> Void

@_silgen_name("zig_callback_with_delay")
func zig_callback_with_delay() -> Void

@_silgen_name("zig_long_running_task")
func zig_long_running_task() -> Void