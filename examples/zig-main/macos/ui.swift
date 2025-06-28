import Cocoa

// Global reference to keep the app delegate alive
private var appDelegate: AppDelegate?

// This class handles the application lifecycle
@objc class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the window
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 270),
            styleMask: [.miniaturizable, .closable, .resizable, .titled],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Zig as Main"
        window.makeKeyAndOrderFront(nil)
        
        // Create a text view to display the message
        let textView = NSTextView(frame: window.contentView!.bounds)
        textView.string = "This Swift UI was launched from Zig!\nZig is controlling the application lifecycle."
        textView.isEditable = false
        textView.font = NSFont.systemFont(ofSize: 16)
        textView.alignment = .center
        textView.autoresizingMask = [.width, .height]
        
        window.contentView?.addSubview(textView)
        
        // Create the main menu bar
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        NSApp.mainMenu = mainMenu
        
        // Create the app menu
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        
        // Add a Quit menu item
        let quitMenuItem = NSMenuItem(title: "Quit", 
                           action: #selector(NSApplication.terminate(_:)), 
                           keyEquivalent: "q")
        quitMenuItem.keyEquivalentModifierMask = .command
        appMenu.addItem(quitMenuItem)
        
        // Activate the app and bring window to front
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Cleanup if needed
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// Export function to initialize the Swift UI from Zig
@_cdecl("swift_ui_init")
public func swiftUIInit() {
    // Create the application instance
    let app = NSApplication.shared
    
    // Create and set the delegate
    appDelegate = AppDelegate()
    app.delegate = appDelegate
    
    // Set activation policy
    app.setActivationPolicy(.regular)
}

// Export function to run the Swift UI event loop
@_cdecl("swift_ui_run")
public func swiftUIRun() {
    NSApplication.shared.run()
}

// Export function to stop the application
@_cdecl("swift_ui_stop")
public func swiftUIStop() {
    NSApplication.shared.terminate(nil)
}