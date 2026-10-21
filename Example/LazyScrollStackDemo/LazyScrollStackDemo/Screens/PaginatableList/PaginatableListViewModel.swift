//
//  PaginatableListViewModel.swift
//  LazyScrollStack
//

import SwiftUI
import Combine

final class PaginatableListViewModel: ObservableObject {
    @Published var items: [CellModel] = []
    
    var isPaginationEnabled: Bool {
        items.count < 100
    }
    
    init() {
        self.items = (0..<20).map {
            createCellModel(index: $0)
        }
    }
    
    func onLoadMore() async {
        guard isPaginationEnabled else { return }
        
        /// Network's request immitation
        try! await Task.sleep(nanoseconds: 3_000_000_000)
        
        var tempItems: [CellModel] = []
        let currentItemsCount = items.count
        
        for index in 0..<20 {
            let text = currentItemsCount + index
            tempItems.append(createCellModel(index: text))
        }
        withAnimation {
            items.append(contentsOf: tempItems)
        }
       
    }
    
    private func createCellModel(index: Int) -> CellModel {
        CellModel(index: index)
    }
}
