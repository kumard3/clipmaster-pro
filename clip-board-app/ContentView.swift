import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var clipboardMonitor = ClipboardMonitor()
    @State private var searchText = ""
    @State private var copiedItemId: NSManagedObjectID?
    @State private var hoveredItemId: NSManagedObjectID?
    @State private var currentPage = 0
    @State private var items: [ClipboardItem] = []
    @State private var isLoading = false
    @State private var hasMoreItems = true
    
    private let itemsPerPage = 50
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, onSearchChanged: { _ in
                resetPagination()
                loadItems()
            })
            .padding()
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(items, id: \.objectID) { item in
                        ClipboardItemRow(item: item,
                                       isCopied: copiedItemId == item.objectID,
                                       isHovered: hoveredItemId == item.objectID,
                                       onTap: { copyToClipboard(item) },
                                       onHover: { isHovered in
                                           hoveredItemId = isHovered ? item.objectID : nil
                                       })
                        .id(item.objectID)
                    }
                    
                    if hasMoreItems {
                        ProgressView()
                            .padding()
                            .onAppear {
                                loadMoreItems()
                            }
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
            loadItems()
        }
    }
    
    private func resetPagination() {
        currentPage = 0
        items = []
        hasMoreItems = true
    }
    
    private func loadItems() {
        guard !isLoading else { return }
        isLoading = true
        
        let fetchRequest: NSFetchRequest<ClipboardItem> = ClipboardItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ClipboardItem.timestamp, ascending: false)]
        fetchRequest.fetchLimit = itemsPerPage
        fetchRequest.fetchOffset = currentPage * itemsPerPage
        
        if !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "content CONTAINS[cd] %@", searchText)
        }
        
        do {
            let fetchedItems = try viewContext.fetch(fetchRequest)
            items.append(contentsOf: fetchedItems)
            hasMoreItems = fetchedItems.count == itemsPerPage
            currentPage += 1
        } catch {
            print("Error fetching items: \(error)")
        }
        
        isLoading = false
    }
    
    private func loadMoreItems() {
        loadItems()
    }
    
    private func copyToClipboard(_ item: ClipboardItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.content ?? "", forType: .string)
        copiedItemId = item.objectID
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedItemId = nil
        }
    }
    
    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onSearchChanged: (String) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search here...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: text, { oldValue, newValue in
                    onSearchChanged(newValue)
                })
        }
    }
}

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isCopied: Bool
    let isHovered: Bool
    let onTap: () -> Void
    let onHover: (Bool) -> Void
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.content ?? "")
                    .lineLimit(2)
                    .truncationMode(.tail)
                Text(item.timestamp ?? Date(), formatter: itemFormatter)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isCopied {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(isHovered ? Color.gray.opacity(0.1) : Color.clear)
        .onTapGesture(perform: onTap)
        .onHover(perform: onHover)
    }
}
