import Foundation

extension LazyScrollStackHost {
    func computeHeightRange(
        contentOffset: CGFloat,
        contentTopInset: CGFloat,
        in coordinator: Coordinator
    ) -> (minY: CGFloat, maxY: CGFloat) {
        let shouldIncreseTopInset = contentOffset < 0 && coordinator.itemsRange.lowerBound != 0
        let isTopInsetAboveZero = contentTopInset > 0
        
        let proposedHeight = coordinator.currentProposedSize.length(along: coordinator.axis)
        let additionalCachedHeight = coordinator.cacheSize * proposedHeight
        
        var visibleMinY: CGFloat = .zero
        var minY: CGFloat = .zero
        
        if isTopInsetAboveZero || shouldIncreseTopInset {
            visibleMinY = contentOffset
            minY = visibleMinY - additionalCachedHeight
        } else {
            visibleMinY = max(contentOffset, .zero)
            
            let firstCellY = if coordinator.cellSizes.isEmpty {
                CGFloat.zero
            } else {
                coordinator.placements[.zero]
                    .map { coordinator.axis.length(of: $0) } ?? .zero
            }
            
            minY = max(firstCellY, visibleMinY - additionalCachedHeight)
        }
        
        let maxY = minY + additionalCachedHeight + proposedHeight + additionalCachedHeight
        return (minY, maxY)
    }
}
