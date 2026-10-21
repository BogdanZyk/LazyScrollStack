//
//  SameCellsHeightPlainList.swift
//  LazyScrollStack
//

import SwiftUI
import LazyScrollStack

struct SameCellsHeightPlainList: View {
    @State private var alwaysBounce = true
    @State private var isScrollEnabled = true
    @State private var items: [CellModel]
    
    private let allowsDeletion: Bool
    
    @MainActor init(count: Int) {
        _items = State(initialValue: (0..<count).map(CellModel.init(index:)))
        allowsDeletion = count == 100 || count == 1000
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Button {
                    alwaysBounce.toggle()
                } label: {
                    Label(alwaysBounce ? "Bounce on" : "Bounce off", systemImage: "arrow.up.and.down")
                }
                
                Button {
                    isScrollEnabled.toggle()
                } label: {
                    Label(isScrollEnabled ? "Scrolling on" : "Scrolling off", systemImage: "hand.draw")
                }
            }
            .buttonStyle(.bordered)
            .font(.caption)
            
            LazyScrollStack(items, spacing: 8) { item in
                CellView(
                    by: item,
                    deleteAction: allowsDeletion
                    ? { remove(for: item) }
                    : nil
                )
            }
            .alwaysBounce(alwaysBounce)
            .isScrollEnabled(isScrollEnabled)
            .itemAnimations(insertion: .identity, removal: .opacity, pagination: .opacity)
            .ignoresSafeArea()
        }
        .padding(.horizontal, 8)
        .navigationTitle("Fixed-height rows")
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
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .frame(width: 36, height: 36)
                .foregroundStyle(.indigo)
                .background(.indigo.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.body.weight(.medium))

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            if let deleteAction {
                Button(role: .destructive, action: deleteAction) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Delete \(item.title)")
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}
