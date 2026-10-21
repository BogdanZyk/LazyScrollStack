import Foundation

extension LazyScrollStackHost {
    func contentOffsetWillSet(
        _ value: CGFloat,
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) {
        let direction = getScrollDirection(
            futureOffset: value,
            cachedOffset: coordinator.currentContentOffset
        )
        
        guard direction != .noChanges else {
            return
        }

        updateScrollVelocity(
            futureOffset: value,
            coordinator: coordinator
        )
        
        predictTargetItemsRange(
            scrollView: scrollViewController.scrollView,
            futureContentOffset: value,
            direction: direction,
            coordinator: coordinator
        )
        
        placeItems(
            scrollViewController: scrollViewController,
            coordinator: coordinator
        )
        
        updateScrollViewLayoutIfNeeded(
            scrollViewController: scrollViewController,
            coordinator: coordinator
        )
    }

    private func updateScrollVelocity(
        futureOffset: CGFloat,
        coordinator: Coordinator
    ) {
        guard coordinator.currentScrollActivity != .idle else {
            coordinator.currentScrollVelocity = .zero
            return
        }

        let currentTime = ProcessInfo.processInfo.systemUptime
        defer { coordinator.lastScrollSampleTime = currentTime }

        guard let lastSampleTime = coordinator.lastScrollSampleTime,
              currentTime > lastSampleTime
        else {
            coordinator.currentScrollVelocity = .zero
            return
        }

        coordinator.currentScrollVelocity =
            (futureOffset - coordinator.currentContentOffset)
            / (currentTime - lastSampleTime)
    }
}
