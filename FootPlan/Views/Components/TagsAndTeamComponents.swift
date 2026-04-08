import SwiftUI

struct WrapTagsView: View {
    let tags: [String]
    
    var body: some View {
        FlexibleView(
            data: tags,
            spacing: 8,
            alignment: .leading
        ) { tag in
            Text(tag)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.footCard.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    init(data: Data,
         spacing: CGFloat = 8,
         alignment: HorizontalAlignment = .leading,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(generateRows(), id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { element in
                        content(element)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }
    
    private func generateRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRowWidth: CGFloat = 0
        let maxWidth = UIScreen.main.bounds.width - 48
        
        for element in data {
            let elementWidth = estimateWidth(for: element)
            if currentRowWidth + elementWidth + spacing > maxWidth {
                rows.append([element])
                currentRowWidth = elementWidth
            } else {
                rows[rows.count - 1].append(element)
                currentRowWidth += elementWidth + spacing
            }
        }
        
        return rows
    }
    
    private func estimateWidth(for element: Data.Element) -> CGFloat {
        let label = UILabel()
        label.text = "\(element)"
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.sizeToFit()
        return label.bounds.width + 20
    }
}

