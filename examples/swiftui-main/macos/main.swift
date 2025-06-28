import SwiftUI

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

// Main SwiftUI App structure
@main
struct ZigSwiftUIApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 480, minHeight: 270)
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

// View Model to manage state and interact with Zig
class ContentViewModel: ObservableObject {
    @Published var zigMessage: String = ""
    @Published var clickCount: Int = 0
    
    init() {
        // Get initial message from Zig
        zigMessage = String(cString: get_message_from_zig())
        
        // Call hello function to demonstrate console output
        hello_from_zig()
    }
    
    func callZigFunction() {
        clickCount += 1
        zigMessage = "Called Zig function \(clickCount) time\(clickCount == 1 ? "" : "s")"
        
        // Call Zig function again
        hello_from_zig()
    }
}

// Main content view
struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("SwiftUI with Zig")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("This is a SwiftUI app calling Zig functions")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.horizontal, 40)
            
            Text(viewModel.zigMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button(action: {
                viewModel.callZigFunction()
            }) {
                Label("Call Zig Function", systemImage: "arrow.right.circle.fill")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}