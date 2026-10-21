import UIKit

extension LazyScrollStackHost {
    func updateScrollViewTopInsetIfNeeded(
        scrollView: UIScrollView,
        coordinator: Coordinator
    ) {
        let lowerBound = coordinator.itemsRange.lowerBound
        let currentTopInset = coordinator.axis.leadingInset(of: scrollView.contentInset)
        
        if let placement = coordinator.placements[lowerBound] {
            let placementValue = coordinator.axis.length(of: placement)

            if placementValue < .zero {
                yPlacementBelowZero(
                    coordinator: coordinator,
                    scrollView: scrollView,
                    lowerBound: lowerBound,
                    yPlacement: placementValue,
                    currentTopInset: currentTopInset
                )
            } else {
                yPlacementAboveZero(
                    coordinator: coordinator,
                    scrollView: scrollView,
                    lowerBound: lowerBound,
                    yPlacement: placementValue,
                    currentTopInset: currentTopInset
                )
            }
        }
    }
}

private extension LazyScrollStackHost {
    func yPlacementBelowZero(
        coordinator: Coordinator,
        scrollView: UIScrollView,
        lowerBound: Int,
        yPlacement: CGFloat,
        currentTopInset: CGFloat
    ) {
        if lowerBound != .zero,
           (currentTopInset == .zero) || (yPlacement < -currentTopInset) {
            
            coordinator.isSetContentInsetInProgress = true
            
            let newTopInset = currentTopInset + (coordinator.estimatedCellHeight + coordinator.spacing) * CGFloat(lowerBound)
            coordinator.axis.setLeadingInset(newTopInset, in: &scrollView.contentInset)
            return
        }
        
        if lowerBound == .zero {
            let yZeroPlacement = -(coordinator.placements[.zero]
                .map { coordinator.axis.length(of: $0) } ?? .zero)
            
            if coordinator.axis.leadingInset(of: scrollView.contentInset) != yZeroPlacement {
                coordinator.axis.setLeadingInset(yZeroPlacement, in: &scrollView.contentInset)
            }
        }
    }
    
    func yPlacementAboveZero(
        coordinator: Coordinator,
        scrollView: UIScrollView,
        lowerBound: Int,
        yPlacement: CGFloat,
        currentTopInset: CGFloat
    ) {
        if lowerBound != .zero {
            if yPlacement < abs(currentTopInset) {
                coordinator.isSetContentInsetInProgress = true
                
                coordinator.placements[.zero] = coordinator.axis.point(length: .zero)
                coordinator.axis.setLeadingInset(.zero, in: &scrollView.contentInset)
            }
        } else {
            let newTopInset = -(coordinator.placements[.zero]
                .map { coordinator.axis.length(of: $0) } ?? .zero)
            
            scrollView.contentInset = coordinator.axis.insets(leading: newTopInset)
        }
    }
}
