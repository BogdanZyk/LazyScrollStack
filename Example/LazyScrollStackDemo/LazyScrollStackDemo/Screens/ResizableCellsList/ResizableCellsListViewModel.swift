//
//  ResizableCellsListViewModel.swift
//  LazyScrollStack
//

import Combine

final class ResizableCellsListViewModel: ObservableObject {
    @Published var items: [CellModel] = []
    
    init(count: Int) {
        self.items = (0..<count).map {
            CellModel(index: $0)
        }
    }

    func delete(id: CellModel.ID) {
        items.removeAll { $0.id == id }
    }
}
