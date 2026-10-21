import UIKit

extension LazyScrollStackHost {
    func notifyScrollMetricsChangeIfNeeded(
        scrollView: UIScrollView,
        coordinator: Coordinator
    ) {
        guard let onScrollMetricsChangeAction else {
            return
        }

        let minimumOffset = -coordinator.axis.leadingInset(of: scrollView.adjustedContentInset)
        let maximumOffset = max(
            coordinator.axis.length(of: scrollView.contentSize)
                - coordinator.axis.length(of: scrollView.bounds.size)
                + coordinator.axis.trailingInset(of: scrollView.adjustedContentInset),
            minimumOffset
        )
        let offset = max(coordinator.currentContentOffset - minimumOffset, .zero)
        let scrollableDistance = maximumOffset - minimumOffset
        let progress = scrollableDistance > .zero
            ? min(max(offset / scrollableDistance, .zero), 1)
            : .zero

        assert((0...1).contains(progress))

        let direction: ScrollMetrics.Direction
        switch coordinator.currentScrollActivity == .idle
            ? .noChanges
            : coordinator.currentDirection {
        case .up:
            direction = .towardStart
        case .down:
            direction = .towardEnd
        case .noChanges:
            direction = .stationary
        }

        let metrics = ScrollMetrics(
            offset: offset,
            progress: progress,
            velocity: coordinator.currentScrollVelocity,
            direction: direction,
            activity: coordinator.currentScrollActivity
        )

        guard metrics != coordinator.lastSentScrollMetrics else {
            return
        }

        coordinator.lastSentScrollMetrics = metrics
    
        onScrollMetricsChangeAction(metrics)
    }
}
