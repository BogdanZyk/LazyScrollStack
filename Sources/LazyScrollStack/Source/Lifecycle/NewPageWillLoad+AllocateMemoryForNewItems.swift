import Foundation

extension LazyScrollStackHost {
    func allocateMemoryForNewItems(
        coordinator: Coordinator
    ) {
        coordinator.cellSizes.pad(
            to: itemIDs.count, with: CGSize(width: 0, height: .zero)
        )
        coordinator.placements.pad(
            to: itemIDs.count, with: nil
        )
        coordinator.itemIDs = itemIDs
    }
}
