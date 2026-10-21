import UIKit

extension LazyScrollStackHost {
    func newPageWillLoad(
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) {
        allocateMemoryForNewItems(
            coordinator: coordinator
        )
        
        predictTargetItemsRange(
            scrollView: scrollViewController.scrollView,
            futureContentOffset: coordinator.currentContentOffset,
            direction: .down,
            coordinator: coordinator
        )
        
        placeItems(
            scrollViewController: scrollViewController,
            coordinator: coordinator,
            isNeedForceUpdateHeightStatistics: true
        )
        
        forceUpdateScrollViewContentSize(
            newHeight: coordinator.estimatedHeight,
            scrollView: scrollViewController.scrollView,
            coordinator: coordinator
        )
        
        removeFooter(scrollView: scrollViewController.scrollView)
        coordinator.isFooterActive = false
    }
}
