//
//  SameCellsHeightPlainList.swift
//  ListComparison
//

import SwiftUI
import LazyScrollStack

private let comparisonItems = 0..<1000

struct SystemListDemo: View {
    var body: some View {
        List(comparisonItems, id: \.self) { index in
            ComparisonCellView(index: index)
                .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle("SwiftUI List")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LazyVStackDemo: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(comparisonItems, id: \.self) { index in
                    ComparisonCellView(index: index)
                }
            }
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 12)
        .navigationTitle("LazyVStack")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LazyScrollStackDemo: View {
    var body: some View {
        LazyScrollStack(comparisonItems, spacing: 8) { index in
            ComparisonCellView(index: index)
        }
        .ignoresSafeArea()
        .padding(.horizontal, 12)
        .navigationTitle("LazyScrollStack")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ComparisonCellView: View {
    let index: Int

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "square.grid.2x2.fill")
                .foregroundStyle(.indigo)

            VStack(alignment: .leading, spacing: 4) {
                Text("Demo item \(index + 1)")
                    .font(.body.weight(.medium))

                if index % 3 != 0 {
                    Text("A comparison row with dynamic height.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                if index % 3 == 2 {
                    Label("Updated today", systemImage: "checkmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)

            Text("#\(index + 1)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
    }
}
