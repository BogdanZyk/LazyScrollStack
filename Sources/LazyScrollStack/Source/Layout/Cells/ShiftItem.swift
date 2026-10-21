import CoreFoundation

extension LazyScrollStackHost {
    func shiftItem(
        after update: CellSizeUpdate,
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator,
        measuredHeightDelta: CGFloat
    ) {
        applyPlacementShift(
            after: update,
            scrollViewController: scrollViewController,
            coordinator: coordinator,
            heightDelta: measuredHeightDelta
        )

        updateHeightStatistics(
            coordinator: coordinator,
            measuredHeight: coordinator.measuredHeight + measuredHeightDelta,
            measuredCountInPass: .zero
        )
        
        #if DEBUG
        let (minY, maxY) = coordinator.currentCachedHeightRange

        logPlaceItems(
            minY: minY, maxY: maxY, coordinator: coordinator
        )
        #endif
    }
}

private extension LazyScrollStackHost {
    func applyPlacementShift(
        after update: CellSizeUpdate,
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator,
        heightDelta: CGFloat
    ) {
        let startY = coordinator.placements[update.index]
            .map { coordinator.axis.length(of: $0) } ?? .zero
        updateItemFrame(
            at: update.index,
            to: scrollViewController.scrollView,
            toPosition: startY,
            extraLength: heightDelta,
            axis: coordinator.axis,
            coordinator: coordinator
        )
        
        guard update.index < coordinator.cellSizes.count - 1 else {
            return
        }
        
        let affectedRange = (update.index + 1)...coordinator.itemsRange.upperBound
        var currentY = (coordinator.placements[affectedRange.lowerBound]
            .map { coordinator.axis.length(of: $0) } ?? .zero) + heightDelta
        
        for index in affectedRange {
            let cellSize = coordinator.cellSizes[index]

            updateItemFrame(
                at: index,
                to: scrollViewController.scrollView,
                toPosition: currentY,
                axis: coordinator.axis,
                coordinator: coordinator
            )

            coordinator.placements[index] = coordinator.axis.point(length: currentY)
            currentY = incrementCurrentY(
                currentValue: currentY,
                index: index,
                cellSize: cellSize,
                spacing: coordinator.spacing,
                axis: coordinator.axis
            )
        }
    }
}
