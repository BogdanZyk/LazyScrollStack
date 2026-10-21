//
//  ResizableCellsList.swift
//  LazyScrollStack
//

import SwiftUI
import LazyScrollStack

struct ResizableCellsList: View {
    @StateObject private var viewModel: ResizableCellsListViewModel
    
    init(count: Int) {
        self._viewModel = StateObject(
            wrappedValue: ResizableCellsListViewModel(count: count)
        )
    }

    var body: some View {
        LazyScrollStack($viewModel.items, spacing: 8) { $item in
            CellView(
                by: $item,
                deleteAction: { remove(for: item) }
            )
        }
        .onContentSizeChange { measurement in
            print(measurement.size)
        }
        .padding(.horizontal, 8)
        .ignoresSafeArea()
        .navigationTitle("Expandable rows")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func remove(for item: CellModel) {
        withAnimation {
            viewModel.delete(id: item.id)
        }
    }
}

private struct CellView: View {
    @Binding var item: CellModel
    let deleteAction: () -> Void
    
    init(by item: Binding<CellModel>, deleteAction: @escaping () -> Void) {
        self._item = item
        self.deleteAction = deleteAction
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.icon)
                .frame(width: 36, height: 36)
                .foregroundStyle(.purple)
                .background(.purple.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))
                    
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.body.weight(.medium))

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button(item.isOn ? "Show less" : "Show details") {
                    item.isOn.toggle()
                }
                .font(.caption)

                if item.isOn {
                    Text("This extra content changes the measured row height at runtime.")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button("Remove", role: .destructive, action: deleteAction)
                    .font(.caption)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}
