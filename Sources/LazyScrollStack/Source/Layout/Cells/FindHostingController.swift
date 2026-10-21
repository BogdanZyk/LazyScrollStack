import SwiftUI

extension LazyScrollStackHost {
    func findHostingController(
        with itemIndex: Int,
        in coordinator: Coordinator
    ) -> CellHostingController? {
        guard coordinator.itemIDs.indices.contains(itemIndex) else {
            return nil
        }

        return coordinator.activeCellControllers[coordinator.itemIDs[itemIndex]]
    }
}
