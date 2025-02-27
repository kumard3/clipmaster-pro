import SwiftUI
import CoreData

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isSelected: Bool
    @State private var isHovered: Bool = false
    
    var body: some View {
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
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
        .background(isHovered ? Color.gray.opacity(0.1) : Color.clear)
        .onHover { isHovered = $0 }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()