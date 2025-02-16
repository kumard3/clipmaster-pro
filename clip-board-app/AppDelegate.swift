import Cocoa
import SwiftUI
import CoreData

// Add MenuBarView definition here temporarily for testing
struct MenuBarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var clipboardMonitor = ClipboardMonitor()
    @FetchRequest(
        fetchRequest: {
            let request = ClipboardItem.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ClipboardItem.timestamp, ascending: false)]
            request.fetchLimit = 10
            return request
        }()
    ) private var recentItems: FetchedResults<ClipboardItem>
    
    var body: some View {
        Text("Temporary MenuBarView")
            .frame(width: 360, height: 400)
    }
}

// Add SettingsView definition here temporarily for testing
struct SettingsView: View {
    @StateObject private var settings = Settings()
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        Text("Temporary SettingsView")
            .frame(width: 400, height: 300)
    }
}

// Add Settings class definition
class Settings: ObservableObject {
    @AppStorage("autoDeleteDays") var autoDeleteDays: Int = 30
    @AppStorage("maxClipboardItems") var maxClipboardItems: Int = 1000
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = true
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var settingsWindow: NSWindow?
    private var mainWindow: NSWindow?
    
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard")
        }
        
        popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .environment(\EnvironmentValues.managedObjectContext, PersistenceController.shared.container.viewContext)
        )
        
        statusItem.button?.action = #selector(togglePopover(_:))
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
    
    func showSettingsWindow() {
        if settingsWindow == nil {
            let contentView = SettingsView()
                .environment(\EnvironmentValues.managedObjectContext, PersistenceController.shared.container.viewContext)
            
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            settingsWindow?.center()
            settingsWindow?.setFrameAutosaveName("Settings")
            settingsWindow?.isReleasedWhenClosed = false
            settingsWindow?.title = "Settings"
            settingsWindow?.contentView = NSHostingView(rootView: contentView)
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up any resources
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
