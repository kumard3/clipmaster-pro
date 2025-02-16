import SwiftUI

@main
struct clip_board_appApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
        .commands {
            // Add empty commands to remove default menu items
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .pasteboard) { }
            CommandGroup(replacing: .undoRedo) { }
            CommandGroup(replacing: .textEditing) { }
            CommandGroup(replacing: .windowList) { }
            CommandGroup(replacing: .windowSize) { }
        }
    }
    
    init() {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
    }
}
