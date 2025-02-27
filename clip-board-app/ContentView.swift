import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ClipboardItem.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<ClipboardItem>
    @State private var copiedItemId: NSManagedObjectID?
    @State private var hoveredItemId: NSManagedObjectID?
    @StateObject private var clipboardMonitor = ClipboardMonitor()
    @State private var searchText = "" // Add search text state variable

    var body: some View {
        VStack {
            // Search input field at the top
            TextField("Search here...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            List {
                ForEach(filteredItems) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.content ?? "")
                                .lineLimit(2)
                                .truncationMode(.tail)
                            Text(item.timestamp!, formatter: itemFormatter)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if copiedItemId == item.objectID {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .background(hoveredItemId == item.objectID ? Color.gray.opacity(0.1) : Color.clear)
                    .onTapGesture {
                        copyToClipboard(item.content ?? "")
                        copiedItemId = item.objectID
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedItemId = nil
                        }
                    }
                    .onHover { isHovered in
                        hoveredItemId = isHovered ? item.objectID : nil
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            HStack {
                Button(action: quitApp) {
                    Label("Quit", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .padding()
            }
        }
        .onAppear {
            clipboardMonitor.startMonitoring(context: viewContext)
        }
    }

    private var filteredItems: [ClipboardItem] {
        if searchText.isEmpty {
            return items.map { $0 }
        } else {
            return items.filter { $0.content?.localizedCaseInsensitiveContains(searchText) == true }
        }
    }

    private func copyToClipboard(_ content: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
    }

    private func addItem() {
        withAnimation {
            let newItem = ClipboardItem(context: viewContext)
            newItem.timestamp = Date()
            newItem.content = "New item \(Date())"
            newItem.type = "text"

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
