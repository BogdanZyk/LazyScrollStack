//
//  DifferentCellsHeightPlainList.swift
//  LazyScrollStack
//

import SwiftUI
import LazyScrollStack

struct DifferentCellsHeightPlainList: View {
    @State private var items: [CellModel]

    private let allowsDeletion: Bool
    
    init(count: Int) {
        _items = State(initialValue: (0..<count).map(CellModel.init(index:)))
        allowsDeletion = count == 100 || count == 1000
    }
    
    var body: some View {
        LazyScrollStack(items, spacing: 8) { item in
            CellView(
                by: item,
                deleteAction: allowsDeletion
                    ? { remove(for: item) }
                    : nil
            )
        }
        .onContentSizeChange { measurement in
            print(measurement.size)
        }
        .alwaysBounce(true)
        .showsIndicators(false)
        .isScrollEnabled(true)
        .padding(.horizontal, 8)
        .ignoresSafeArea()
        .navigationTitle("Variable-height rows")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func remove(for item: CellModel) {
        withAnimation {
            items.removeAll { $0.id == item.id }
        }
    }
}

private struct CellView: View {
    let item: CellModel
    let deleteAction: (() -> Void)?
    
    init(by item: CellModel, deleteAction: (() -> Void)?) {
        self.item = item
        self.deleteAction = deleteAction
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.icon)
                .frame(width: 36, height: 36)
                .foregroundStyle(.orange)
                .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body.weight(.medium))

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                if item.index % 3 == 0 {
                    Text("One extra detail makes this row taller.")
                        .font(.caption)
                }
                if item.index % 5 == 0 {
                    Text("A second line demonstrates dynamic measurement.")
                        .font(.caption)
                }

                if let deleteAction {
                    Button("Remove", role: .destructive, action: deleteAction)
                        .font(.caption)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}
