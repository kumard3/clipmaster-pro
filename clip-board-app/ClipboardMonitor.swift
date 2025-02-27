import SwiftUI
import CoreData

class ClipboardMonitor: ObservableObject {
    @Published var lastCopiedText: String = ""
    
    func startMonitoring(context: NSManagedObjectContext) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let copiedString = NSPasteboard.general.string(forType: .string) {
                if copiedString != self.lastCopiedText {
                    self.lastCopiedText = copiedString
                    self.saveToClipboard(content: copiedString, context: context)
                }
            }
        }
    }
    
    private func saveToClipboard(content: String, context: NSManagedObjectContext) {
        // Check for duplicates
        let fetchRequest: NSFetchRequest<ClipboardItem> = ClipboardItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "content == %@", content)
        
        do {
            let matchingItems = try context.fetch(fetchRequest)
            if matchingItems.isEmpty {
                let newItem = ClipboardItem(context: context)
                newItem.content = content
                newItem.timestamp = Date()
                
                try context.save()
            } else {
                // Update timestamp of existing item
                matchingItems.first?.timestamp = Date()
                try context.save()
            }
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
