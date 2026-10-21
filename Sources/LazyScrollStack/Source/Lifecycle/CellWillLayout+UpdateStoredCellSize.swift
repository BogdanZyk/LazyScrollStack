import CoreFoundation

extension LazyScrollStackHost {
    func updateStoredCellSize(
        cellSizeUpdate: CellSizeUpdate,
        coordinator: Coordinator
    ) {
        coordinator.cellSizes[cellSizeUpdate.index] = cellSizeUpdate.newSize
    }
}
