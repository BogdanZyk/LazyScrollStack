import SwiftUI

extension LazyScrollStackHost {
    func placeItemsInFirstFrame(
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) {
        let (minY, maxY) = computeHeightRange(
            contentOffset: .zero,
            contentTopInset: coordinator.axis.leadingInset(of: scrollViewController.scrollView.contentInset),
            in: coordinator
        )
        
        var measuredHeight = coordinator.measuredHeight
        var currentY: CGFloat = minY
        var measuredCountInPass = Int.zero
        
        for index in Int.zero...coordinator.placements.count - 1 {
            let hostingController = createCellController(itemIndex: index, in: coordinator)
            
            let size = sizeThatFits(
                crossLength: coordinator.currentProposedSize.crossLength(for: coordinator.axis),
                axis: coordinator.axis,
                hostingController: hostingController
            )
            coordinator.cellSizes[index] = size
            
            place(
                hostingController: hostingController,
                with: size,
                fromPosition: currentY,
                to: scrollViewController,
                axis: coordinator.axis
            )
            coordinator.placements[index] = coordinator.axis.point(length: currentY)
            
            currentY = incrementCurrentY(
                currentValue: currentY,
                index: index,
                cellSize: size,
                spacing: coordinator.spacing,
                axis: coordinator.axis
            )
            let cellLength = coordinator.axis.length(of: size)
            measuredHeight += index == .zero ? cellLength : (coordinator.spacing + cellLength)
            measuredCountInPass += 1
            
            if currentY >= maxY {
                break
            }
        }
        
        updateHeightStatistics(
            coordinator: coordinator,
            measuredHeight: measuredHeight,
            measuredCountInPass: measuredCountInPass
        )
        coordinator.currentCachedHeightRange = (minY, maxY)
        coordinator.itemsRange = Int.zero...measuredCountInPass - 1
        
        #if DEBUG
        logPlaceItems(
            minY: minY, maxY: maxY, coordinator: coordinator
        )
        #endif
    }
}
