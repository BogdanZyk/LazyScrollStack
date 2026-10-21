import UIKit

extension LazyScrollStackHost {
    func predictTargetItemsRange(
        scrollView: UIScrollView,
        futureContentOffset: CGFloat,
        direction: ScrollDirection,
        coordinator: Coordinator
    ) {
        let (minY, maxY) = computeHeightRange(
            contentOffset: futureContentOffset,
            contentTopInset: coordinator.axis.leadingInset(of: scrollView.contentInset),
            in: coordinator
        )

        switch direction {
        case .down:
            let lowerIndex = coordinator.itemsRange.lowerBound
            let indices = lowerIndex..<coordinator.cellSizes.count
            
            let newLowerIndex = layoutDownwardUntilMinY(indices: indices, minY: minY, in: coordinator)
            let newUpperIndex = layoutDownwardUntilMaxY(lowerIndex: newLowerIndex, maxY: maxY, in: coordinator)
            
            coordinator.targetItemsRange = newLowerIndex...newUpperIndex
        case .up:
            let upperIndex = coordinator.itemsRange.upperBound
            let indices = (.zero...upperIndex).reversed()
            
            let newUpperIndex = layoutUpwardUntilMaxY(indices: indices, maxY: maxY, in: coordinator)
            let newLowerIndex = layoutUpwardUntilMinY(upperIndex: newUpperIndex, minY: minY, in: coordinator)
            
            coordinator.targetItemsRange = newLowerIndex...newUpperIndex
    
        default:
            return
        }
        
        if shouldResetContentSize(coordinator: coordinator) {
            coordinator.shouldResetContentSize = true
        }
        
        #if DEBUG
        logPredictTargetItemsRange(
            cachedHeightRange: minY...maxY,
            direction: direction,
            coordinator: coordinator
        )
        #endif
        
        coordinator.currentCachedHeightRange = (minY, maxY)
        coordinator.currentContentOffset = futureContentOffset
        coordinator.currentDirection = direction
    }
}
