import SwiftUI
import CoreData

struct MenuBarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var clipboardMonitor = ClipboardMonitor()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ClipboardItem.timestamp, ascending: false)],
        fetchLimit: 10
    ) private var recentItems: FetchedResults<ClipboardItem>
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Recent Clips")
                    .font(.headline)
                Spacer()
                Menu {
                    Button(action: {
                        if let appDelegate = NSApp.delegate as? AppDelegate {
                            appDelegate.showMainWindow()
                        }
                    }) {
                        Label("View All", systemImage: "list.bullet")
                    }
                    
                    Button(action: {
                        if let appDelegate = NSApp.delegate as? AppDelegate {
                            appDelegate.showSettingsWindow()
                        }
                    }) {
                        Label("Settings", systemImage: "gear")
                    }
                    
                    Divider()
                    
                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Label("Quit", systemImage: "power")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .frame(width: 30, height: 30)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Recent items list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(recentItems) { item in
                        MenuBarItemRow(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                copyToClipboard(item.content ?? "")
                            }
                        
                        if item.id != recentItems.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .frame(width: 360, height: 400)
        .onAppear {
            clipboardMonitor.startMonitoring(context: viewContext)
        }
    }
    
    private func copyToClipboard(_ content: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
    }
}

struct MenuBarItemRow: View {
    let item: ClipboardItem
    @State private var isHovered = false
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.content ?? "")
                .lineLimit(2)
                .truncationMode(.tail)
                .font(.system(size: 14))
            
            Text(item.timestamp ?? Date(), formatter: itemFormatter)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isHovered ? Color.gray.opacity(0.1) : Color.clear)
        .onHover { hovering in
            isHovered = hovering
        }
    }
} 