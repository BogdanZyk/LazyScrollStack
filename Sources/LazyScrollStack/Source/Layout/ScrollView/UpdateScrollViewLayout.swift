import SwiftUI

extension LazyScrollStackHost {
    func updateScrollViewLayoutIfNeeded(
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) {
        updateScrollViewTopInsetIfNeeded(
            scrollView: scrollViewController.scrollView,
            coordinator: coordinator
        )
        
        updateScrollViewContentSizeIfNeeded(
            scrollViewController: scrollViewController,
            coordinator: coordinator
        )
        
        notifyContentSizeChangeIfNeeded(
            coordinator: coordinator
        )
        
        notifyScrollMetricsChangeIfNeeded(
            scrollView: scrollViewController.scrollView,
            coordinator: coordinator
        )
    }
    
    func forceUpdateScrollViewContentSize(
        newHeight: CGFloat,
        scrollView: UIScrollView,
        coordinator: Coordinator
    ) {
        updateScrollViewContentSize(
            isForced: true,
            newHeight: newHeight,
            scrollView: scrollView,
            coordinator: coordinator
        )
        
        notifyContentSizeChangeIfNeeded(
            coordinator: coordinator
        )
        
        notifyScrollMetricsChangeIfNeeded(
            scrollView: scrollView,
            coordinator: coordinator
        )
    }
}
