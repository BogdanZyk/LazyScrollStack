import UIKit

extension LazyScrollStackHost {
    func updateScrollViewContentSize(
        isForced: Bool,
        newHeight: CGFloat,
        scrollView: UIScrollView,
        coordinator: Coordinator
    ) {
        #if DEBUG
        logSetContentSize(
            newHeight: newHeight,
            coordinator: coordinator
        )
        #endif
        
        setContentSize(
            to: scrollView,
            size: coordinator.axis.size(
                length: newHeight,
                crossLength: coordinator.currentProposedSize.crossLength(for: coordinator.axis)
            ),
            isForced: isForced,
            shouldReset: coordinator.shouldResetContentSize,
        )
    }
}

private extension LazyScrollStackHost {
    func setContentSize(
        to scrollView: UIScrollView,
        size: CGSize,
        isForced: Bool,
        shouldReset: Bool
    ) {
        if !isForced, shouldReset {
            scrollView.contentSize = .zero
        }
        
        scrollView.contentSize = size
    }
}
