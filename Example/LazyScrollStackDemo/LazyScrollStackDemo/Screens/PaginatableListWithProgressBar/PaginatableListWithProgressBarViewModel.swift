//
//  PaginatableListWithProgressBarViewModel.swift
//  LazyScrollStack
//

import SwiftUI
import Combine

final class PaginatableListWithProgressBarViewModel: ObservableObject {
    @Published var items: [CellModel] = []
    @Published var scrollProgress: CGFloat = .zero
    
    private let screenWidth = UIScreen.main.bounds.size.width
    
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
        
        try! await Task.sleep(for: .seconds(2))
        
        var tempItems: [CellModel] = []
        let currentItemsCount = items.count
        
        for index in 0..<20 {
            let text = currentItemsCount + index
            tempItems.append(createCellModel(index: text))
        }
        
        items.append(contentsOf: tempItems)
    }
    
    func updateScrollProgress(_ progress: CGFloat) {
        Task { @MainActor in
            scrollProgress = progress * screenWidth
        }
    }
    
    private func createCellModel(index: Int) -> CellModel {
        CellModel(index: index)
    }
}
