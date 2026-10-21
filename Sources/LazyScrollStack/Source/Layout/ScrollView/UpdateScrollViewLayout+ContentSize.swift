import SwiftUI

extension LazyScrollStackHost {
    func updateScrollViewContentSizeIfNeeded(
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) {
        guard !coordinator.isFooterActive else { return }
        
        let upperBound = coordinator.itemsRange.upperBound
        let lastCellIndex = coordinator.cellSizes.count - 1
        let isLastCellReached = upperBound == lastCellIndex
        
        if isLastCellReached || isUpperBoundPlacementBiggerThanContentSize(
            scrollViewController: scrollViewController, coordinator: coordinator
        ) {
            var lastCellBottomYPosition: CGFloat = .zero
            
            if isLastCellReached {
                let lastCellY = coordinator.placements.last
                    .flatMap { $0 }
                    .map { coordinator.axis.length(of: $0) } ?? .zero
                let lastCellHeight = coordinator.cellSizes.last
                    .map { coordinator.axis.length(of: $0) } ?? .zero
                
                lastCellBottomYPosition = lastCellY + lastCellHeight
            } else {
                let placementUpperBoundNextCell = coordinator.placements[upperBound + 1]
                    .map { coordinator.axis.length(of: $0) } ?? .zero
                let remainingCellsToListEnd = coordinator.placements.count - upperBound
                
                lastCellBottomYPosition = placementUpperBoundNextCell +
                CGFloat(remainingCellsToListEnd) * coordinator.estimatedCellHeight +
                CGFloat(remainingCellsToListEnd - 1) * coordinator.spacing
            }
            
            var footerHeight = CGFloat.zero
            
            if let footerContent {
                footerHeight = sizeThatFitsAndPlaceFooter(
                    scrollViewController: scrollViewController,
                    lastCellBottomYPosition: lastCellBottomYPosition,
                    footer: footerContent,
                    coordinator: coordinator
                ).length(along: coordinator.axis)
            }
            
            let newHeight = lastCellBottomYPosition + footerHeight
            if coordinator.axis.length(of: scrollViewController.scrollView.contentSize) != newHeight {
                updateScrollViewContentSize(
                    isForced: false,
                    newHeight: newHeight,
                    scrollView: scrollViewController.scrollView,
                    coordinator: coordinator
                )
            }
            
            if coordinator.shouldResetContentSize {
                coordinator.shouldResetContentSize = false
            }
        }
    }
}
 
private extension LazyScrollStackHost {
    func isUpperBoundPlacementBiggerThanContentSize(
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) -> Bool {
        let lastCellIndex = coordinator.cellSizes.count - 1
        guard coordinator.itemsRange.upperBound != lastCellIndex else {
            return false
        }
        
        let upperBound = coordinator.itemsRange.upperBound
        let contentSize = coordinator.axis.length(of: scrollViewController.scrollView.contentSize)
        let placementUpperBoundNextCell = coordinator.placements[upperBound + 1]
            .map { coordinator.axis.length(of: $0) } ?? .zero
        
        if upperBound + 1 == lastCellIndex {
            return placementUpperBoundNextCell > contentSize
        }
        
        let placementUpperBoundCell = coordinator.placements[upperBound]
            .map { coordinator.axis.length(of: $0) } ?? .zero
        let placementLastCellYMax = (coordinator.placements[lastCellIndex]
            .map { coordinator.axis.length(of: $0) } ?? .zero)
            + coordinator.axis.length(of: coordinator.cellSizes[lastCellIndex])

        return if placementLastCellYMax.isZero {
            placementUpperBoundNextCell > contentSize
        } else {
            placementUpperBoundCell > placementLastCellYMax
        }
    }
    
    func sizeThatFitsAndPlaceFooter(
        scrollViewController: InterceptableScrollViewController,
        lastCellBottomYPosition: CGFloat,
        footer: FooterContentBuilder,
        coordinator: Coordinator
    ) -> LayoutSize {
        let footerController: UIHostingController<FooterContent>
        
        if let existingController = coordinator.footerController {
            footerController = existingController
            footerController.rootView = footer()
        } else {
            let controller = createFooter(footer)
            coordinator.footerController = controller
            footerController = controller
        }
        
        let footerSize = sizeThatFits(
            crossLength: coordinator.currentProposedSize.crossLength(for: coordinator.axis),
            axis: coordinator.axis,
            hostingController: footerController
        )
        
        if coordinator.axis.length(of: footerSize) == .zero {
            return LayoutSize(width: .zero, height: .zero)
        }
        
        place(
            hostingController: footerController,
            with: footerSize,
            fromPosition: lastCellBottomYPosition,
            to: scrollViewController,
            axis: coordinator.axis
        )

        coordinator.isFooterActive = true
        return LayoutSize(width: footerSize.width, height: footerSize.height)
    }
}
