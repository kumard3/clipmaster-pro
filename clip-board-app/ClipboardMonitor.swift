import SwiftUI
import CoreData

class ClipboardMonitor: ObservableObject {
    @Published var lastCopiedText: String = ""
    private var timer: Timer?
    private var backgroundContext: NSManagedObjectContext?
    
    deinit {
        timer?.invalidate()
    }
    
    func startMonitoring(context: NSManagedObjectContext) {
        // Create a background context for better performance
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext?.parent = context
        
        // Use a more efficient timer that doesn't block the main thread
        timer?.invalidate()
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(checkClipboard), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    @objc private func checkClipboard() {
        guard let backgroundContext = backgroundContext,
              let copiedString = NSPasteboard.general.string(forType: .string),
              copiedString != lastCopiedText else {
            return
        }
        
        lastCopiedText = copiedString
        
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            self.saveToClipboard(content: copiedString, context: backgroundContext)
        }
    }
    
    private func saveToClipboard(content: String, context: NSManagedObjectContext) {
        // Use batch fetching for better performance
        let fetchRequest: NSFetchRequest<ClipboardItem> = ClipboardItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "content == %@", content)
        fetchRequest.fetchLimit = 1
        
        do {
            let matchingItems = try context.fetch(fetchRequest)
            if matchingItems.isEmpty {
                // Create new item in background context
                let newItem = ClipboardItem(context: context)
                newItem.content = content
                newItem.timestamp = Date()
            } else {
                // Update existing item
                matchingItems.first?.timestamp = Date()
            }
            
            // Save in background
            if context.hasChanges {
                try context.save()
                
                // Merge changes to main context
                DispatchQueue.main.async {
                    context.parent?.performAndWait {
                        try? context.parent?.save()
                    }
                }
            }
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
}
