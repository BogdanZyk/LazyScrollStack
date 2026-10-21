//
//  PaginatableList.swift
//  LazyScrollStack
//

import SwiftUI
import Combine
import LazyScrollStack

struct PaginatableList: View {
    @StateObject private var viewModel: PaginatableListViewModel
    
    init() {
        self._viewModel = StateObject(
            wrappedValue: PaginatableListViewModel()
        )
    }

    var body: some View {
        VStack(spacing: .zero) {
            VStack(spacing: 10) {
                Image(systemName: "shippingbox.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                Text("Infinite shelf")
                    .font(.title2.bold())
                Text("New rows appear when you reach the end.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(height: 180)
            
            LazyScrollStack($viewModel.items, spacing: 8) { $item in
                CellView(by: item)
            }
            .onContentSizeChange { measurement in
                print(measurement.size)
            }
            .footer {
                loader
            }
            .itemAnimations(insertion: .identity, removal: .opacity, pagination: .opacity)
            .padding(.horizontal, 8)
            .ignoresSafeArea()
        }
        .navigationTitle("Pagination")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var loader: some View {
        if viewModel.isPaginationEnabled {
            LoaderView()
                .padding(.top, 28)
                .onAppear {
                    Task {
                        await viewModel.onLoadMore()
                    }
                }
        }
    }
}

private struct CellView: View {
    let item: CellModel
    
    init(by item: CellModel) {
        self.item = item
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .frame(width: 36, height: 36)
                .foregroundStyle(.blue)
                .background(.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.body.weight(.medium))

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}
