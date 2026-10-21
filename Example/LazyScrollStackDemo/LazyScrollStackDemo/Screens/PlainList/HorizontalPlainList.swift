//
//  HorizontalPlainList.swift
//  LazyScrollStackDemo
//

import SwiftUI
import LazyScrollStack

struct HorizontalPlainList: View {
    
    private let items: [CellModel]

    init(count: Int) {
        items = (0..<count).map {
            CellModel(index: $0)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            LazyScrollStack(items, axis: .horizontal, spacing: 8) { item in
                CellView(by: item)
            }
            .frame(height: 155)

            Spacer(minLength: 0)
        }
        .padding(.top, 8)
        .navigationTitle("Horizontal rows")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CellView: View {
    let item: CellModel

    init(by item: CellModel) {
        self.item = item
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: item.icon)
                .font(.title)
                .foregroundStyle(.teal)

            Text(item.title)
                .font(.headline)

            Text(item.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(width: 180, height: 150, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
