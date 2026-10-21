import SwiftUI

extension LazyScrollStackHost {
    func shouldProcessNewContentOffset(
        newValue: CGFloat, coordinator: Coordinator
    ) -> Bool {
        if newValue <= .zero,
           coordinator.itemsRange.upperBound == coordinator.placements.count - 1 {
            return false
        }
        
        if coordinator.isSetContentInsetInProgress {
            coordinator.isSetContentInsetInProgress = false
            return false
        }
        
        return true
    }
}
