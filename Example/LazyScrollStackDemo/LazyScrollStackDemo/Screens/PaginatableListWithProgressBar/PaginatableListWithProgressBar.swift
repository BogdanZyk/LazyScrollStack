//
//  PaginatableListWithProgressBar.swift
//  LazyScrollStack
//

import SwiftUI
import Combine
import LazyScrollStack

struct PaginatableListWithProgressBar: View {
    @StateObject private var viewModel: PaginatableListWithProgressBarViewModel
    
    init() {
        self._viewModel = StateObject(
            wrappedValue: PaginatableListWithProgressBarViewModel()
        )
    }

    var body: some View {
        VStack(spacing: .zero) {
            header

            progressView(by: viewModel.scrollProgress)
            
            LazyScrollStack($viewModel.items, spacing: 8) { $item in
                CellView(by: item)
            }
            .onScrollMetricsChange { metrics in
                viewModel.updateScrollProgress(metrics.progress)
            }
            .footer {
                loader
            }
            .padding(.horizontal, 8)
            .ignoresSafeArea()
        }
        .navigationTitle("Scroll progress")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.largeTitle)
                .foregroundStyle(.green)
            Text("Reading progress")
                .font(.title2.bold())
            Text("The bar tracks your position in the list.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(height: 180)
    }
    
    private func progressView(by scrollProgress: CGFloat) -> some View {
        HStack(spacing: .zero) {
            Rectangle()
                .fill(.green)
                .frame(width: scrollProgress, height: 5)
            Spacer(minLength: .zero)
        }
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
                .foregroundStyle(.green)
                .background(.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))

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
