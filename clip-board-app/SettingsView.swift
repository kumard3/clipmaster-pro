import SwiftUI
import CoreData

class Settings: ObservableObject {
    @AppStorage("autoDeleteDays") var autoDeleteDays: Int = 30
    @AppStorage("maxClipboardItems") var maxClipboardItems: Int = 1000
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = true
}

struct SettingsView: View {
    @StateObject private var settings = Settings()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isPerformingCleanup = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                    .onChange(of: settings.launchAtLogin) { newValue in
                        // TODO: Implement launch at login functionality
                    }
                
                Stepper("Auto-delete items older than \(settings.autoDeleteDays) days", 
                       value: $settings.autoDeleteDays,
                       in: 1...365)
                
                Stepper("Keep maximum \(settings.maxClipboardItems) items",
                       value: $settings.maxClipboardItems,
                       in: 100...10000,
                       step: 100)
            }
            
            Section {
                Button("Clean Up Old Items") {
                    cleanupOldItems()
                }
                .disabled(isPerformingCleanup)
                
                if isPerformingCleanup {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
    
    private func cleanupOldItems() {
        isPerformingCleanup = true
        
        let calendar = Calendar.current
        let oldDate = calendar.date(byAdding: .day, value: -settings.autoDeleteDays, to: Date())!
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ClipboardItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp < %@", oldDate as NSDate)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let context = PersistenceController.shared.container.newBackgroundContext()
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            let changes: [AnyHashable: Any] = [
                NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []
            ]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
        } catch {
            print("Failed to clean up old items: \(error)")
        }
        
        isPerformingCleanup = false
    }
} 