import SwiftUI

extension LazyScrollStackHost {
    func firstFrameWillAppear(
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) {
        if !itemIDs.isEmpty {
            placeItemsInFirstFrame(
                scrollViewController: scrollViewController,
                coordinator: coordinator
            )
        }
        
        forceUpdateScrollViewContentSize(
            newHeight: coordinator.estimatedHeight,
            scrollView: scrollViewController.scrollView,
            coordinator: coordinator
        )
    }
}
