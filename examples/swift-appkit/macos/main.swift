import Cocoa

// This is a minimal AppDelegate to handle the application lifecycle.
class AppDelegate: NSObject, NSApplicationDelegate {
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
        window.title = "Swift AppKit Example"
        window.makeKeyAndOrderFront(nil)
        
        // Get message from Zig
        let zigMessage = String(cString: get_message_from_zig())
        
        // Create a text view to display the message
        let textView = NSTextView(frame: window.contentView!.bounds)
        textView.string = zigMessage
        textView.isEditable = false
        textView.font = NSFont.systemFont(ofSize: 16)
        textView.alignment = .center
        textView.autoresizingMask = [.width, .height]
        
        window.contentView?.addSubview(textView)

        // Create the main menu bar
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        app.mainMenu = mainMenu

        // Create the app menu
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu

        // Add a Quit menu item
        let quitMenuItem = NSMenuItem(title: "Quit", 
                           action: #selector(NSApplication.terminate(_:)), 
                           keyEquivalent: "q")
        quitMenuItem.keyEquivalentModifierMask = .command
        appMenu.addItem(quitMenuItem)

        // This is the magic! We are calling the function that is defined
        // in our Zig library. The Swift compiler knows about this function
        // because we will tell it to look at our `x.h` header file.
        hello_from_zig()
        
        // Activate the app and bring window to front
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// --- Standard macOS Application Setup ---
let delegate = AppDelegate()
let app = NSApplication.shared
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
