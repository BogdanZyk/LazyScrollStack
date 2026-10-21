//
//  ContentView.swift
//  LazyScrollStackDemo
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
               
                Section("Fixed-height rows") {
                    NavigationLink("Small sample · 5 rows", destination: SameCellsHeightPlainList(count: 5))
                    NavigationLink("Regular sample · 100 rows", destination: SameCellsHeightPlainList(count: 100))
                    NavigationLink("Large sample · 1,000 rows", destination: SameCellsHeightPlainList(count: 1000))
                    NavigationLink("Horizontal sample · 100 rows", destination: HorizontalPlainList(count: 100))
                }

                Section("Variable-height rows") {
                    NavigationLink("Small sample · 5 rows", destination: DifferentCellsHeightPlainList(count: 5))
                    NavigationLink("Regular sample · 100 rows", destination: DifferentCellsHeightPlainList(count: 100))
                    NavigationLink("Large sample · 1,000 rows", destination: DifferentCellsHeightPlainList(count: 1000))
                }

                Section("Loading more rows") {
                    NavigationLink("Pagination · up to 100 rows", destination: PaginatableList())
                    NavigationLink("Pagination with scroll progress", destination: PaginatableListWithProgressBar())
                }

                Section("Interactive sizing") {
                    NavigationLink("Expandable rows · 25 rows", destination: ResizableCellsList(count: 25))
                }
                
                Section("1000 row comparison") {
                    NavigationLink(destination: SystemListDemo()) {
                        Label("SwiftUI List", systemImage: "list.bullet.rectangle")
                    }

                    NavigationLink(destination: LazyVStackDemo()) {
                        Label("ScrollView + LazyVStack", systemImage: "square.stack.3d.up")
                    }

                    NavigationLink(destination: LazyScrollStackDemo()) {
                        Label("LazyScrollStack", systemImage: "rectangle.stack")
                    }
                }
            }
            .navigationTitle("LazyScrollStack Demo")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.insetGrouped)
        }
    }
}

#Preview {
    ContentView()
}
