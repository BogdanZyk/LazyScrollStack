//
//  LoaderView.swift
//  LazyScrollStack
//

import SwiftUI

struct LoaderView: View {
    var body: some View {
        HStack(spacing: 10) {
            ProgressView()
            Text("Loading more rows…")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 24)
    }
}
