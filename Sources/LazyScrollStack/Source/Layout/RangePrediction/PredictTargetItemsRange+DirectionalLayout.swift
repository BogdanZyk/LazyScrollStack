import UIKit

extension LazyScrollStackHost {
    func layoutDownwardUntilMinY(
        indices: Range<Int>,
        minY: CGFloat,
        in coordinator: Coordinator
    ) -> Int {
        guard let firstIndex = indices.first else { return .zero }
        
        var currentY = coordinator.placements[firstIndex]
            .map { coordinator.axis.length(of: $0) } ?? .zero
        let lastIndex = indices.last ?? coordinator.cellSizes.count - 1
        
        for index in indices {
            if index == lastIndex {
                coordinator.placements[index] = coordinator.axis.point(length: currentY)
                return index
            }
            
            let cellHeightAndSpacing = getCachedSpacingAndCell(
                coordinator: coordinator, index: index
            )
            
            if currentY + cellHeightAndSpacing > minY {
                coordinator.placements[index] = coordinator.axis.point(length: currentY)
                return index
            }
            
            currentY += cellHeightAndSpacing
        }
        
        return lastIndex
    }
    
    func layoutDownwardUntilMaxY(
        lowerIndex: Int,
        maxY: CGFloat,
        in coordinator: Coordinator
    ) -> Int {
        let itemsRangeUpperBound = coordinator.itemsRange.upperBound
        var currentY = coordinator.placements[lowerIndex]
            .map { coordinator.axis.length(of: $0) } ?? .zero
        let lastIndex = coordinator.cellSizes.count - 1
        
        for index in lowerIndex..<lastIndex {
            if index > itemsRangeUpperBound {
                coordinator.placements[index] = coordinator.axis.point(length: currentY)
            }
            
            let cellHeightAndSpacing = getCachedSpacingAndCell(
                coordinator: coordinator, index: index
            )
            
            currentY += cellHeightAndSpacing
            
            if currentY >= maxY {
                return index
            }
        }

        coordinator.placements[lastIndex] = coordinator.axis.point(length: currentY)
        return lastIndex
    }
    
    func layoutUpwardUntilMaxY(
        indices: ReversedCollection<ClosedRange<Int>>,
        maxY: CGFloat,
        in coordinator: Coordinator
    ) -> Int {
        guard let firstIndex = indices.first else { return .zero }
        
        var currentY = coordinator.placements[firstIndex]
            .map { coordinator.axis.length(of: $0) } ?? .zero
        let firstCellHeight = getCachedSpacingAndCell(
            coordinator: coordinator, index: firstIndex
        )
        currentY += firstCellHeight
        
        for index in indices {
            let cellHeightAndSpacing = getCachedSpacingAndCell(
                coordinator: coordinator, index: index
            )
            
            if currentY - cellHeightAndSpacing < maxY {
                let nextCellIndex = index + 1
                
                if nextCellIndex < coordinator.placements.count {
                    coordinator.placements[nextCellIndex] = coordinator.axis.point(length: currentY)
                }
                
                return index
            }
            
            currentY -= cellHeightAndSpacing
        }
        
        if coordinator.placements.count > 1 {
            coordinator.placements[1] = coordinator.axis.point(length: currentY)
        }
        
        return .zero
    }
    
    func layoutUpwardUntilMinY(
        upperIndex: Int,
        minY: CGFloat,
        in coordinator: Coordinator
    ) -> Int {
        guard upperIndex != .zero else { return .zero }
        
        let nextUpperIndex = min(upperIndex + 1, coordinator.cellSizes.count - 1)
        
        var currentPlacement = coordinator.placements[nextUpperIndex]
            .map { coordinator.axis.length(of: $0) } ?? .zero
        guard currentPlacement > minY else {
            return nextUpperIndex
        }
        
        for index in (.zero...nextUpperIndex).reversed().dropFirst() {
            let previousCellHeightAndSpacing = getCachedSpacingAndCell(
                coordinator: coordinator, index: index
            )
            
            if currentPlacement - previousCellHeightAndSpacing <= minY {
                return index
            }
            
            currentPlacement -= previousCellHeightAndSpacing
        }
        
        return .zero
    }
}

private extension LazyScrollStackHost {
    func getCachedSpacingAndCell(coordinator: Coordinator, index: Int) -> CGFloat {
        let cellStoredHeight = coordinator.axis.length(of: coordinator.cellSizes[index])
        let cellHeight = cellStoredHeight != .zero ? cellStoredHeight : coordinator.estimatedCellHeight

        return cellHeight + coordinator.spacing
    }
}
