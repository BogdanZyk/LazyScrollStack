extension LazyScrollStackHost {
    // Avoid shrinking content size at high speed because it can shift the offset.
    func shouldResetContentSize(coordinator: Coordinator) -> Bool {
        let itemsRange = coordinator.itemsRange
        let targetRange = coordinator.targetItemsRange
        
        if !coordinator.isFooterActive {
            if targetRange.upperBound == coordinator.placements.count - 1,
               abs(targetRange.lowerBound - itemsRange.lowerBound) > 1 ||
                abs(targetRange.upperBound - itemsRange.upperBound) > 1 {
                return true
            }
        }
        
        return false
    }
}
