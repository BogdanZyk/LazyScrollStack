import SwiftUI

extension LazyScrollStackHost {
    func placeItems(
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator,
        isNeedForceUpdateHeightStatistics: Bool = false
    ) {
        let operations = makeItemChangesOperations(
            currentRange: coordinator.itemsRange,
            targetRange: coordinator.targetItemsRange
        )
        
        performItemDeletions(
            ranges: operations.remove,
            coordinator: coordinator
        )
        
        let (measuredCountInPass, measuredHeight) = performItemInsertions(
            ranges: operations.insert,
            scrollViewController: scrollViewController,
            coordinator: coordinator
        )
        
        if isNeedForceUpdateHeightStatistics || measuredCountInPass > .zero {
            updateHeightStatistics(
                coordinator: coordinator,
                measuredHeight: measuredHeight,
                measuredCountInPass: measuredCountInPass
            )
        }

        #if DEBUG
        if !coordinator.shouldResetContentSize {
            let (minY, maxY) = coordinator.currentCachedHeightRange
            
            logPlaceItems(
                minY: minY, maxY: maxY, coordinator: coordinator
            )
        }
        #endif
    }
}

private extension LazyScrollStackHost {
    func performItemDeletions(
        ranges: [ClosedRange<Int>],
        coordinator: Coordinator
    ) {
        for range in ranges {
            for index in range {
                prepareForReuseCellController(cellIndex: index, in: coordinator)
            }
        }
        coordinator.itemsRange = coordinator.targetItemsRange
    }
    
    func performItemInsertions(
        ranges: [ClosedRange<Int>],
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) -> (measuredCountInPass: Int, measuredHeight: CGFloat) {
        var measuredCountInPass = Int.zero
        var measuredHeight = coordinator.measuredHeight
        
        for indexes in ranges {
            switch coordinator.currentDirection {
            case .up:
                let (tempMeasuredCountInPass, tempMeasuredHeight) = performUpItemsInsertions(
                    indexes: indexes,
                    scrollViewController: scrollViewController,
                    coordinator: coordinator
                )
                measuredCountInPass += tempMeasuredCountInPass
                measuredHeight += tempMeasuredHeight
                
            case .down:
                let (tempMeasuredCountInPass, tempMeasuredHeight) = performDownItemsInsertions(
                    indexes: indexes,
                    scrollViewController: scrollViewController,
                    coordinator: coordinator
                )
                measuredCountInPass += tempMeasuredCountInPass
                measuredHeight += tempMeasuredHeight
            
            case .noChanges:
                return (measuredCountInPass: Int.zero, coordinator.measuredHeight)
            }
        }
        
        return (measuredCountInPass, measuredHeight)
    }
    
    func performUpItemsInsertions(
        indexes: ClosedRange<Int>,
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) -> (measuredCountInPass: Int, measuredHeight: CGFloat) {
        let (minY, _) = coordinator.currentCachedHeightRange
        var currentY = coordinator.placements[indexes.upperBound + 1]
            .map(coordinator.axis.length(of:)) ?? .zero
        
        var measuredHeight = CGFloat.zero
        var measuredCountInPass = Int.zero
        
        for index in (Int.zero...indexes.upperBound).reversed() {
            let hostingController = createCellController(itemIndex: index, in: coordinator)
            
            var size = coordinator.cellSizes[index]
            if size == .zero {
                size = sizeThatFits(
                    crossLength: coordinator.currentProposedSize.crossLength(for: coordinator.axis),
                    axis: coordinator.axis,
                    hostingController: hostingController
                )
                
                coordinator.cellSizes[index] = size
                measuredHeight += coordinator.spacing + coordinator.axis.length(of: size)
                measuredCountInPass += 1
            }
            
            currentY = decrementCurrentY(
                currentValue: currentY,
                cellSize: size,
                spacing: coordinator.spacing,
                axis: coordinator.axis
            )
            
            place(
                hostingController: hostingController,
                with: size,
                fromPosition: currentY,
                to: scrollViewController,
                axis: coordinator.axis
            )
            coordinator.placements[index] = coordinator.axis.point(length: currentY)
            
            if currentY <= minY {
                coordinator.itemsRange = index...coordinator.targetItemsRange.upperBound
                break
            }
        }
        
        return (measuredCountInPass, measuredHeight)
    }
    
    func performDownItemsInsertions(
        indexes: ClosedRange<Int>,
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) -> (measuredCountInPass: Int, measuredHeight: CGFloat) {
        let (_, maxY) = coordinator.currentCachedHeightRange
        var currentY = coordinator.placements[indexes.lowerBound]
            .map(coordinator.axis.length(of:)) ?? .zero
        
        var measuredHeight = CGFloat.zero
        var measuredCountInPass = Int.zero
        
        for index in indexes.lowerBound...coordinator.cellSizes.count - 1 {
            let hostingController = createCellController(itemIndex: index, in: coordinator)
            
            var size = coordinator.cellSizes[index]
            if size == .zero {
                size = sizeThatFits(
                    crossLength: coordinator.currentProposedSize.crossLength(for: coordinator.axis),
                    axis: coordinator.axis,
                    hostingController: hostingController
                )
                
                coordinator.cellSizes[index] = size
                measuredHeight += coordinator.spacing + coordinator.axis.length(of: size)
                measuredCountInPass += 1
            }
            
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
            
            if currentY >= maxY {
                coordinator.itemsRange = coordinator.targetItemsRange.lowerBound...index
                break
            }
        }
        
        return (measuredCountInPass, measuredHeight)
    }
}
