import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var popover: NSPopover!
    func setupMenuBar() {
        let mainMenu = NSMenu()
        
        let appMenuItem = NSMenuItem(title: "App", action: nil, keyEquivalent: "")
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenu.addItem(quitMenuItem)
        
        mainMenu.addItem(appMenuItem)
        NSApplication.shared.mainMenu = mainMenu
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Remove the app from the dock
        NSApp.setActivationPolicy(.accessory)
        
        // Create the status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard")
            button.action = #selector(togglePopover(_:))
        }

        // Create the popover
        let contentView = ContentView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
    }

    @objc func togglePopover(_ sender: Any?) {
        if let button = statusBarItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}
