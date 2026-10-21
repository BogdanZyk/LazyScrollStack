import SwiftUI

extension LazyScrollStackHost {
    func cellWillLayout(
        itemIndex: Int,
        scrollViewController: InterceptableScrollViewController,
        in coordinator: Coordinator
    ) {
        guard let hostingController = findHostingController(with: itemIndex, in: coordinator) else {
            return
        }
        
        updateSUIView(
            in: hostingController,
            with: itemIndex
        )
        
        let oldSize = coordinator.cellSizes[itemIndex]
        let newSize = sizeThatFits(
            crossLength: coordinator.currentProposedSize.crossLength(for: coordinator.axis),
            axis: coordinator.axis,
            hostingController: hostingController
        )
        
        guard isNeedCellResizing(oldSize: oldSize, newSize: newSize, axis: coordinator.axis) else {
            return
        }
        
        let cellSizeUpdate = CellSizeUpdate(
            index: itemIndex,
            newSize: newSize,
            oldSize: oldSize
        )
        
        updateStoredCellSize(
            cellSizeUpdate: cellSizeUpdate,
            coordinator: coordinator
        )
        
        shiftItem(
            after: cellSizeUpdate,
            scrollViewController: scrollViewController,
            coordinator: coordinator,
            measuredHeightDelta: coordinator.axis.length(of: cellSizeUpdate.newSize)
                - coordinator.axis.length(of: cellSizeUpdate.oldSize)
        )
        
        forceUpdateScrollViewContentSize(
            newHeight: coordinator.estimatedHeight,
            scrollView: scrollViewController.scrollView,
            coordinator: coordinator
        )
    }
}

private extension LazyScrollStackHost {
    func isNeedCellResizing(
        oldSize: CGSize,
        newSize: CGSize,
        axis: Axis
    ) -> Bool {
        axis.length(of: oldSize) != axis.length(of: newSize)
    }
}
