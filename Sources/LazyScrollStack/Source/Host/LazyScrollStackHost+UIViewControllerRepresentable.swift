import SwiftUI

extension LazyScrollStackHost: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(axis: axis, itemIDs: itemIDs, spacing: spacing)
    }
    
    func makeUIViewController(context: Context) -> InterceptableScrollViewController {
        let controller = InterceptableScrollViewController()
        applyConfiguration(to: controller.scrollView)
        updateScrollHandlers(for: controller, coordinator: context.coordinator)
        
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: InterceptableScrollViewController,
        context: Context
    ) {
        let coordinator = context.coordinator
        
        applyConfiguration(to: uiViewController.scrollView)
        updateScrollHandlers(
            for: uiViewController,
            coordinator: coordinator
        )
        
        switch resolveUpdateUIViewReason(coordinator: coordinator) {
        case .updateCellLayout(let indexes):
            performUpdate(
                scrollViewController: uiViewController,
                context: context,
                animation: .cellLayout
            ) {
                layoutCells(
                    at: indexes,
                    scrollViewController: uiViewController,
                    coordinator: coordinator
                )
            }
            
        case .pagination:
            performUpdate(
                scrollViewController: uiViewController,
                context: context,
                animation: .items(insertion: animationConfiguration.pagination)
            ) {
                layoutCells(
                    at: coordinator.itemsRange,
                    scrollViewController: uiViewController,
                    coordinator: coordinator
                )
                
                newPageWillLoad(
                    scrollViewController: uiViewController,
                    coordinator: coordinator
                )
            }
            
        case .reset(let preservingCachedSizes):
            performUpdate(
                scrollViewController: uiViewController,
                context: context,
                animation: .items(insertion: animationConfiguration.insertion)
            ) {
                dataDidReload(
                    scrollViewController: uiViewController,
                    coordinator: coordinator,
                    preservingCachedSizes: preservingCachedSizes
                )
            }
            
        case .firstFrame, .unknown:
            break
        }
    }
    
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiViewController: InterceptableScrollViewController,
        context: Context
    ) -> CGSize? {
        _sizeThatFits(
            in: .init(width: proposal.width, height: proposal.height),
            uiViewController: uiViewController,
            coordinator: context.coordinator
        )
    }
}

private extension LazyScrollStackHost {
    
    enum LazyScrollUpdateAnimation {
        case cellLayout
        case items(insertion: LazyScrollItemTransition)
    }
    
    func performUpdate(
        scrollViewController: InterceptableScrollViewController,
        context: Context,
        animation: LazyScrollUpdateAnimation,
        update: () -> Void
    ) {
        guard !context.transaction.disablesAnimations,
              !UIAccessibility.isReduceMotionEnabled
        else {
            update()
            return
        }

        let fallbackDuration: TimeInterval?

        switch animation {
        case .cellLayout:
            fallbackDuration = animationConfiguration.layoutDuration

        case .items:
            fallbackDuration = nil
        }

        let animate: (
            _ changes: @escaping () -> Void,
            _ completion: @escaping () -> Void
        ) -> Void

        if context.transaction.animation != nil {
            animate = { changes, completion in
                animateChanges(
                    changes,
                    completion: completion,
                    context: context
                )
            }
        } else if let duration = fallbackDuration {
            animate = { changes, completion in
                UIView.animate(
                    withDuration: max(0, duration),
                    delay: 0,
                    options: [
                        .curveEaseInOut,
                        .allowUserInteraction,
                        .beginFromCurrentState
                    ],
                    animations: changes
                ) { _ in
                    completion()
                }
            }
        } else {
            update()
            return
        }

        switch animation {
        case .cellLayout:
            animateCellLayoutChanges(
                scrollViewController: scrollViewController,
                coordinator: context.coordinator,
                update: update,
                animate: animate
            )

        case .items(let insertion):
            animateItemChanges(
                scrollViewController: scrollViewController,
                coordinator: context.coordinator,
                insertion: insertion,
                removal: animationConfiguration.removal,
                update: update,
                animate: animate
            )
        }
    }
    
    func updateScrollHandlers(
        for scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) {
        let scrollView = scrollViewController.scrollView
        scrollView.delegate = coordinator
        coordinator.onScrollActivityChange = { [weak coordinator] scrollView in
            guard let coordinator else { return }
            notifyScrollMetricsChangeIfNeeded(
                scrollView: scrollView,
                coordinator: coordinator
            )
        }
        scrollViewController.onBoundsSizeChange = { [weak scrollViewController] size in
            guard let scrollViewController else { return }

            _ = updateProposedSize(
                .init(width: size.width, height: size.height),
                scrollViewController: scrollViewController,
                coordinator: coordinator
            )
        }
        scrollView.setContentOffsetWillSet { [weak scrollViewController] newValue in
            guard let scrollViewController,
                  coordinator.isFirstFramePrepared,
                  !itemIDs.isEmpty,
                  shouldProcessNewContentOffset(newValue: newValue, coordinator: coordinator)
                    else { return }
            
            contentOffsetWillSet(
                newValue,
                scrollViewController: scrollViewController,
                coordinator: coordinator
            )
        }
    }
    
    func animateChanges(
        _ changes: @escaping () -> Void,
        completion: @escaping () -> Void,
        context: Context
    ) {
        guard !UIAccessibility.isReduceMotionEnabled else {
            UIView.performWithoutAnimation(changes)
            completion()
            return
        }
        
        if #available(iOS 18.0, *) {
            context.animate(
                changes: changes,
                completion: completion
            )
        } else {
            UIView.animate(
                withDuration: max(0,animationConfiguration.fallbackDuration),
                delay: 0,
                options: [
                    .allowUserInteraction,
                    .beginFromCurrentState
                ],
                animations: changes
            ) { _ in
                completion()
            }
        }
    }
    
    func applyConfiguration(to scrollView: UIScrollView) {
        let isVertical = axis == .vertical
        (scrollView as? InterceptableScrollView)?.axis = axis
        scrollView.alwaysBounceVertical = isVertical && alwaysBounce
        scrollView.alwaysBounceHorizontal = !isVertical && alwaysBounce
        scrollView.bounces = bounces
        scrollView.showsVerticalScrollIndicator = isVertical && showsIndicators
        scrollView.showsHorizontalScrollIndicator = !isVertical && showsIndicators
        scrollView.isScrollEnabled = isScrollEnabled
    }
    
    func _sizeThatFits(
        in proposedSize: LayoutSize,
        uiViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) -> CGSize? {
        guard
            isValidProposedSize(proposedSize)
                else {
            return nil
        }
        
        let proposedSize = calculateAdjustedProposedSize(
            by: uiViewController,
            proposedSize: proposedSize
        )

        if updateProposedSize(
            proposedSize,
            scrollViewController: uiViewController,
            coordinator: coordinator
        ) {
            return nil
        }
        
        guard !coordinator.isFirstFramePrepared else {
            
            let (minY, maxY) = computeHeightRange(
                contentOffset: coordinator.currentContentOffset,
                contentTopInset: coordinator.axis.leadingInset(of: uiViewController.scrollView.contentInset),
                in: coordinator
            )
            
            coordinator.currentCachedHeightRange = (minY, maxY)
            notifyScrollMetricsChangeIfNeeded(
                scrollView: uiViewController.scrollView,
                coordinator: coordinator
            )
            return nil
        }
        
        firstFrameWillAppear(
            scrollViewController: uiViewController,
            coordinator: coordinator
        )
        coordinator.isFirstFramePrepared = true
        return nil
    }

    @discardableResult
    func updateProposedSize(
        _ proposedSize: LayoutSize,
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) -> Bool {
        guard isValidProposedSize(proposedSize) else { return false }

        let previousCrossLength = coordinator.currentProposedSize.crossLength(for: coordinator.axis)
        coordinator.currentProposedSize = proposedSize

        guard coordinator.isFirstFramePrepared,
              previousCrossLength != proposedSize.crossLength(for: coordinator.axis)
        else {
            return false
        }

        dataDidReload(
            scrollViewController: scrollViewController,
            coordinator: coordinator,
            preservingCachedSizes: false,
            preservingScrollPosition: true
        )
        return true
    }
}

private extension LazyScrollStackHost {
    func layoutCells<Indices: Sequence>(
        at indexes: Indices,
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) where Indices.Element == Int {
        for index in indexes {
            cellWillLayout(
                itemIndex: index,
                scrollViewController: scrollViewController,
                in: coordinator
            )
        }
    }
}
