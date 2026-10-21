import SwiftUI
import UIKit

extension LazyScrollStackHost {
    
    func animateItemChanges(
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator,
        insertion: LazyScrollItemTransition,
        removal: LazyScrollItemTransition,
        update: () -> Void,
        animate: (
            _ changes: @escaping () -> Void,
            _ completion: @escaping () -> Void
        ) -> Void
    ) {
        let scrollView = scrollViewController.scrollView

        let oldIDs = Set(coordinator.itemIDs)
        let newIDs = Set(itemIDs)
        let insertedIDs = newIDs.subtracting(oldIDs)

        let oldContentOffset = coordinator.axis.length(
            of: scrollView.contentOffset
        )

        let oldStates = coordinator.activeCellControllers.compactMapValues {
            controller -> LazyScrollCellAnimationState? in

            guard let view = controller.viewIfLoaded else {
                return nil
            }

            return LazyScrollCellAnimationState(view: view)
        }

        let removedSnapshots: [UIView] =
            coordinator.activeCellControllers.compactMap { id, controller in
                guard
                    !newIDs.contains(id),
                    let view = controller.viewIfLoaded,
                    let snapshot = view.snapshotView(
                        afterScreenUpdates: false
                    )
                else {
                    return nil
                }

                snapshot.frame =
                    view.layer.presentation()?.frame ?? view.frame

                snapshot.isUserInteractionEnabled = false
                snapshot.accessibilityElementsHidden = true

                scrollView.addSubview(snapshot)
                scrollView.sendSubviewToBack(snapshot)

                return snapshot
            }

        UIView.performWithoutAnimation {
            for controller in coordinator.activeCellControllers.values {
                guard let view = controller.viewIfLoaded else {
                    continue
                }

                LazyScrollItemTransition.reset(view)
            }

            update()
        }

        let contentOffsetDelta =
            coordinator.axis.length(of: scrollView.contentOffset)
            - oldContentOffset

        let targetLayouts = coordinator.activeCellControllers.compactMapValues {
            controller -> (bounds: CGRect, center: CGPoint)? in

            guard let view = controller.viewIfLoaded else {
                return nil
            }

            return (
                bounds: view.bounds,
                center: view.center
            )
        }

        UIView.performWithoutAnimation {
            for (id, controller) in coordinator.activeCellControllers {
                guard let view = controller.viewIfLoaded else {
                    continue
                }

                if let state = oldStates[id] {
                    var centerRect = CGRect(
                        origin: state.center,
                        size: .zero
                    )

                    shift(
                        &centerRect,
                        by: contentOffsetDelta,
                        axis: coordinator.axis
                    )

                    view.bounds = state.bounds
                    view.center = centerRect.origin
                    view.alpha = state.alpha
                    view.transform = state.transform

                } else if insertedIDs.contains(id) {
                    insertion.apply(to: view)
                }
            }

            for snapshot in removedSnapshots {
                var frame = snapshot.frame

                shift(
                    &frame,
                    by: contentOffsetDelta,
                    axis: coordinator.axis
                )

                snapshot.frame = frame
            }
        }

        animate({
            for (id, controller) in coordinator.activeCellControllers {
                guard let view = controller.viewIfLoaded else {
                    continue
                }

                if let layout = targetLayouts[id] {
                    view.bounds = layout.bounds
                    view.center = layout.center
                }

                LazyScrollItemTransition.reset(view)
            }

            for snapshot in removedSnapshots {
                removal.apply(to: snapshot)
            }
        }, {
            removedSnapshots.forEach {
                $0.removeFromSuperview()
            }
        })
    }
        
    func animateCellLayoutChanges(
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator,
        update: () -> Void,
        animate: (
            _ changes: @escaping () -> Void,
            _ completion: @escaping () -> Void
        ) -> Void
    ) {
        let scrollView = scrollViewController.scrollView

        let oldContentOffset = coordinator.axis.length(
            of: scrollView.contentOffset
        )

        let oldLayouts = coordinator.activeCellControllers.compactMapValues {
            controller -> CellLayoutState? in

            guard let view = controller.viewIfLoaded else {
                return nil
            }

            return CellLayoutState(
                view: view,
                presentation: true
            )
        }

        UIView.performWithoutAnimation {
            update()
        }

        let contentOffsetDelta =
            coordinator.axis.length(of: scrollView.contentOffset)
            - oldContentOffset

        let targetLayouts = coordinator.activeCellControllers.compactMapValues {
            controller -> CellLayoutState? in

            guard let view = controller.viewIfLoaded else {
                return nil
            }

            return CellLayoutState(view: view)
        }

        UIView.performWithoutAnimation {
            for (id, controller) in coordinator.activeCellControllers {
                guard
                    let view = controller.viewIfLoaded,
                    let oldLayout = oldLayouts[id]
                else {
                    continue
                }

                var centerRect = CGRect(
                    origin: oldLayout.center,
                    size: .zero
                )

                shift(
                    &centerRect,
                    by: contentOffsetDelta,
                    axis: coordinator.axis
                )

                view.bounds = oldLayout.bounds
                view.center = centerRect.origin
            }
        }

        animate({
            for (id, controller) in coordinator.activeCellControllers {
                guard
                    let view = controller.viewIfLoaded,
                    let target = targetLayouts[id]
                else {
                    continue
                }

                view.bounds = target.bounds
                view.center = target.center
            }
        }, {})
    }

    func dataDidReload(
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator,
        preservingCachedSizes: Bool,
        preservingScrollPosition: Bool = false
    ) {
        let scrollView = scrollViewController.scrollView
        let oldIDs = coordinator.itemIDs
        let shouldPreservePosition = preservingCachedSizes || preservingScrollPosition
        let oldEstimate = shouldPreservePosition ? coordinator.estimatedCellHeight : .zero
        let oldPlacements = coordinator.placements
        let firstPlacement = shouldPreservePosition
            ? oldPlacements.first.flatMap { $0 }.map { coordinator.axis.length(of: $0) } ?? .zero
            : .zero
        let newIDSet = Set(itemIDs)
        let anchor = shouldPreservePosition
            ? reloadAnchor(
                survivingIDs: newIDSet,
                scrollView: scrollView,
                coordinator: coordinator
            )
            : nil
        let invalidatedOffset = preservingCachedSizes
            ? firstInvalidatedOffset(oldIDs: oldIDs, oldPlacements: oldPlacements)
            : .zero

        var cachedSizes: [ID: CGSize] = [:]
        if preservingCachedSizes {
            cachedSizes.reserveCapacity(oldIDs.count)
            for (index, id) in oldIDs.enumerated() {
                cachedSizes[id] = coordinator.cellSizes[index]
            }
        }

        coordinator.isFirstFramePrepared = false
        removeFooter(scrollView: scrollView)
        coordinator.footerController?.removeFromParent()
        coordinator.footerController = nil
        coordinator.isFooterActive = false
        coordinator.isSetContentInsetInProgress = false
        coordinator.itemIDs = itemIDs
        coordinator.cellSizes = itemIDs.map { cachedSizes[$0] ?? .zero }
        coordinator.placements = itemIDs.indices.map { index in
            index < invalidatedOffset ? oldPlacements[index] : nil
        }
        coordinator.lastSentMeasuredHeight = .unknown
        coordinator.shouldResetContentSize = false

        guard !itemIDs.isEmpty else {
            resetEmptyState(scrollView: scrollView, coordinator: coordinator)
            return
        }

        updateHeightStatisticsFromCachedSizes(
            coordinator: coordinator,
            fallbackEstimate: oldEstimate
        )

        if coordinator.estimatedCellHeight == .zero {
            prepareFirstFrameAfterReload(
                scrollViewController: scrollViewController,
                coordinator: coordinator
            )
            return
        }

        rebuildPlacements(
            startingAt: firstPlacement,
            invalidatedFrom: invalidatedOffset,
            coordinator: coordinator
        )

        var contentOffset = resolvedContentOffset(
            anchor: anchor,
            fallback: coordinator.axis.length(of: scrollView.contentOffset),
            scrollView: scrollView,
            coordinator: coordinator
        )
        var targetRange = cachedItemsRange(
            contentOffset: contentOffset,
            scrollView: scrollView,
            coordinator: coordinator
        )

        var deferredControllers = recycleControllers(
            excluding: Set(itemIDs[targetRange]),
            coordinator: coordinator
        )
        measureItems(in: targetRange, coordinator: coordinator)
        updateHeightStatisticsFromCachedSizes(
            coordinator: coordinator,
            fallbackEstimate: oldEstimate
        )
        rebuildPlacements(
            startingAt: firstPlacement,
            invalidatedFrom: invalidatedOffset,
            coordinator: coordinator
        )

        contentOffset = resolvedContentOffset(
            anchor: anchor,
            fallback: contentOffset,
            scrollView: scrollView,
            coordinator: coordinator
        )
        targetRange = cachedItemsRange(
            contentOffset: contentOffset,
            scrollView: scrollView,
            coordinator: coordinator
        )

        deferredControllers += recycleControllers(
            excluding: Set(itemIDs[targetRange]),
            coordinator: coordinator
        )
        measureItems(in: targetRange, coordinator: coordinator)
        updateHeightStatisticsFromCachedSizes(
            coordinator: coordinator,
            fallbackEstimate: oldEstimate
        )
        rebuildPlacements(
            startingAt: firstPlacement,
            invalidatedFrom: invalidatedOffset,
            coordinator: coordinator
        )
        placeItems(
            in: targetRange,
            scrollViewController: scrollViewController,
            coordinator: coordinator
        )

        coordinator.itemsRange = targetRange
        coordinator.targetItemsRange = targetRange
        coordinator.currentContentOffset = contentOffset
        coordinator.currentCachedHeightRange = computeHeightRange(
            contentOffset: contentOffset,
            contentTopInset: coordinator.axis.leadingInset(of: scrollView.contentInset),
            in: coordinator
        )

        forceUpdateScrollViewContentSize(
            newHeight: coordinator.estimatedHeight,
            scrollView: scrollView,
            coordinator: coordinator
        )
        scrollView.setContentOffset(
            contentOffsetPoint(contentOffset, scrollView: scrollView, axis: coordinator.axis),
            animated: false
        )
        coordinator.isFirstFramePrepared = true
        updateScrollViewLayoutIfNeeded(
            scrollViewController: scrollViewController,
            coordinator: coordinator
        )
        cacheCellControllers(deferredControllers, coordinator: coordinator)
        assertValidState(coordinator)
    }
}

private extension LazyScrollStackHost {
    
    struct CellLayoutState {
        let bounds: CGRect
        let center: CGPoint

        init(view: UIView, presentation: Bool = false) {
            let layer = presentation
                ? view.layer.presentation()
                : nil

            bounds = layer?.bounds ?? view.bounds
            center = layer?.position ?? view.center
        }
    }
    
    func shift(_ frame: inout CGRect, by value: CGFloat, axis: Axis) {
        if axis == .vertical {
            frame.origin.y += value
        } else {
            frame.origin.x += value
        }
    }

    typealias ReloadAnchor = (id: ID, distanceFromViewport: CGFloat)

    func firstInvalidatedOffset(oldIDs: [ID], oldPlacements: [CGPoint?]) -> Int {
        let sharedCount = min(oldIDs.count, itemIDs.count)
        let identityChange = (0..<sharedCount).first { oldIDs[$0] != itemIDs[$0] }
            ?? sharedCount
        let missingPlacement = oldPlacements.firstIndex(of: nil) ?? oldPlacements.count

        return min(identityChange, missingPlacement)
    }

    func reloadAnchor(
        survivingIDs: Set<ID>,
        scrollView: UIScrollView,
        coordinator: Coordinator
    ) -> ReloadAnchor? {
        guard !coordinator.itemIDs.isEmpty else {
            return nil
        }

        let viewportStart = coordinator.axis.length(of: scrollView.contentOffset)
        let searchStart = min(coordinator.itemsRange.lowerBound, coordinator.itemIDs.count - 1)

        for index in searchStart..<coordinator.itemIDs.count {
            let placement = coordinator.placements[index]
                .map { coordinator.axis.length(of: $0) } ?? .zero
            let length = coordinator.axis.length(of: coordinator.cellSizes[index])

            guard placement + length >= viewportStart else {
                continue
            }

            let id = coordinator.itemIDs[index]
            if survivingIDs.contains(id) {
                return (id, placement - viewportStart)
            }
        }

        return nil
    }

    func updateHeightStatisticsFromCachedSizes(
        coordinator: Coordinator,
        fallbackEstimate: CGFloat
    ) {
        let measuredLengths = coordinator.cellSizes.lazy
            .map { coordinator.axis.length(of: $0) }
            .filter { $0 > .zero }
        let measuredCount = measuredLengths.count
        let measuredCellLength = measuredLengths.reduce(.zero, +)

        coordinator.measuredCellsCount = measuredCount
        coordinator.measuredHeight = measuredCellLength
            + coordinator.spacing * CGFloat(max(measuredCount - 1, .zero))
        coordinator.estimatedCellHeight = measuredCount > .zero
            ? measuredCellLength / CGFloat(measuredCount)
            : fallbackEstimate
        coordinator.estimatedHeight = measuredCellLength
            + coordinator.estimatedCellHeight * CGFloat(coordinator.cellSizes.count - measuredCount)
            + coordinator.spacing * CGFloat(max(coordinator.cellSizes.count - 1, .zero))
    }

    func rebuildPlacements(
        startingAt start: CGFloat,
        invalidatedFrom offset: Int,
        coordinator: Coordinator
    ) {
        guard offset < coordinator.itemIDs.count else {
            return
        }

        var position = start
        if offset > .zero {
            let previousIndex = offset - 1
            let previousPosition = coordinator.placements[previousIndex]
                .map { coordinator.axis.length(of: $0) } ?? start
            let previousLength = coordinator.axis.length(of: coordinator.cellSizes[previousIndex])
            position = previousPosition
                + (previousLength > .zero ? previousLength : coordinator.estimatedCellHeight)
                + coordinator.spacing
        }
        let lastIndex = coordinator.itemIDs.count - 1

        for index in offset...lastIndex {
            coordinator.placements[index] = coordinator.axis.point(length: position)
            let cachedLength = coordinator.axis.length(of: coordinator.cellSizes[index])
            position += cachedLength > .zero ? cachedLength : coordinator.estimatedCellHeight

            if index != lastIndex {
                position += coordinator.spacing
            }
        }
    }

    func cachedItemsRange(
        contentOffset: CGFloat,
        scrollView: UIScrollView,
        coordinator: Coordinator
    ) -> ClosedRange<Int> {
        let range = computeHeightRange(
            contentOffset: contentOffset,
            contentTopInset: coordinator.axis.leadingInset(of: scrollView.contentInset),
            in: coordinator
        )
        let lastIndex = coordinator.itemIDs.count - 1
        let lowerBound = coordinator.itemIDs.indices.first { index in
            let placement = coordinator.placements[index]
                .map { coordinator.axis.length(of: $0) } ?? .zero
            let cachedLength = coordinator.axis.length(of: coordinator.cellSizes[index])
            let length = cachedLength > .zero ? cachedLength : coordinator.estimatedCellHeight
            return placement + length >= range.minY
        } ?? lastIndex
        let upperBound = coordinator.itemIDs.indices.dropFirst(lowerBound).first { index in
            let placement = coordinator.placements[index]
                .map { coordinator.axis.length(of: $0) } ?? .zero
            return placement >= range.maxY
        }.map { max(lowerBound, $0 - 1) } ?? lastIndex

        return lowerBound...upperBound
    }

    func measureItems(in range: ClosedRange<Int>, coordinator: Coordinator) {
        for index in range {
            let hostingController = createCellController(itemIndex: index, in: coordinator)
            coordinator.cellSizes[index] = sizeThatFits(
                crossLength: coordinator.currentProposedSize.crossLength(for: coordinator.axis),
                axis: coordinator.axis,
                hostingController: hostingController
            )
        }
    }

    func placeItems(
        in range: ClosedRange<Int>,
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) {
        for index in range {
            let hostingController = createCellController(itemIndex: index, in: coordinator)
            let position = coordinator.placements[index]
                .map { coordinator.axis.length(of: $0) } ?? .zero
            place(
                hostingController: hostingController,
                with: coordinator.cellSizes[index],
                fromPosition: position,
                to: scrollViewController,
                axis: coordinator.axis
            )
        }
    }

    func resolvedContentOffset(
        anchor: ReloadAnchor?,
        fallback: CGFloat,
        scrollView: UIScrollView,
        coordinator: Coordinator
    ) -> CGFloat {
        let proposedOffset = anchor.flatMap { anchor in
            coordinator.itemIDs.firstIndex(of: anchor.id).flatMap { index in
                coordinator.placements[index].map {
                    coordinator.axis.length(of: $0) - anchor.distanceFromViewport
                }
            }
        } ?? fallback
        let minimumOffset = -coordinator.axis.leadingInset(of: scrollView.adjustedContentInset)
        let maximumOffset = max(
            minimumOffset,
            coordinator.estimatedHeight
                - coordinator.axis.length(of: scrollView.bounds.size)
                + coordinator.axis.trailingInset(of: scrollView.adjustedContentInset)
        )

        return min(max(proposedOffset, minimumOffset), maximumOffset)
    }

    func recycleControllers(
        excluding visibleIDs: Set<ID>,
        coordinator: Coordinator
    ) -> [CellHostingController] {
        var controllers: [CellHostingController] = []

        for id in Array(coordinator.activeCellControllers.keys) where !visibleIDs.contains(id) {
            if let controller = deactivateCellController(id: id, in: coordinator) {
                controllers.append(controller)
            }
        }

        return controllers
    }

    func cacheCellControllers(
        _ controllers: [CellHostingController],
        coordinator: Coordinator
    ) {
        for controller in controllers {
            cacheCellController(controller, in: coordinator)
        }
    }

    func prepareFirstFrameAfterReload(
        scrollViewController: InterceptableScrollViewController,
        coordinator: Coordinator
    ) {
        let deferredControllers = recycleControllers(excluding: [], coordinator: coordinator)
        coordinator.measuredCellsCount = .zero
        coordinator.measuredHeight = .zero
        coordinator.estimatedCellHeight = .zero
        coordinator.estimatedHeight = .zero
        coordinator.itemsRange = Int.zero...Int.zero
        coordinator.targetItemsRange = coordinator.itemsRange
        coordinator.currentContentOffset = .zero
        let minimumOffset = -coordinator.axis.leadingInset(
            of: scrollViewController.scrollView.adjustedContentInset
        )
        scrollViewController.scrollView.setContentOffset(
            contentOffsetPoint(
                minimumOffset,
                scrollView: scrollViewController.scrollView,
                axis: coordinator.axis
            ),
            animated: false
        )
        firstFrameWillAppear(
            scrollViewController: scrollViewController,
            coordinator: coordinator
        )
        coordinator.isFirstFramePrepared = true
        cacheCellControllers(deferredControllers, coordinator: coordinator)
        assertValidState(coordinator)
    }

    func resetEmptyState(scrollView: UIScrollView, coordinator: Coordinator) {
        let deferredControllers = recycleControllers(excluding: [], coordinator: coordinator)
        coordinator.cellSizes = []
        coordinator.placements = []
        coordinator.measuredCellsCount = .zero
        coordinator.measuredHeight = .zero
        coordinator.estimatedCellHeight = .zero
        coordinator.estimatedHeight = .zero
        coordinator.itemsRange = Int.zero...Int.zero
        coordinator.targetItemsRange = coordinator.itemsRange
        coordinator.currentCachedHeightRange = (.zero, .zero)
        coordinator.axis.setLeadingInset(.zero, in: &scrollView.contentInset)
        let minimumOffset = -coordinator.axis.leadingInset(of: scrollView.adjustedContentInset)
        coordinator.currentContentOffset = minimumOffset
        scrollView.setContentOffset(
            contentOffsetPoint(minimumOffset, scrollView: scrollView, axis: coordinator.axis),
            animated: false
        )
        coordinator.isFirstFramePrepared = true
        forceUpdateScrollViewContentSize(
            newHeight: .zero,
            scrollView: scrollView,
            coordinator: coordinator
        )
        cacheCellControllers(deferredControllers, coordinator: coordinator)
        assertValidState(coordinator)
    }

    func contentOffsetPoint(_ value: CGFloat, scrollView: UIScrollView, axis: Axis) -> CGPoint {
        axis == .vertical
            ? CGPoint(x: -scrollView.adjustedContentInset.left, y: value)
            : CGPoint(x: value, y: -scrollView.adjustedContentInset.top)
    }

    func assertValidState(_ coordinator: Coordinator) {
        let ids = Set(coordinator.itemIDs)
        assert(ids.count == coordinator.itemIDs.count, "LazyScrollStack IDs must be unique")
        assert(coordinator.itemIDs.count == coordinator.cellSizes.count)
        assert(coordinator.itemIDs.count == coordinator.placements.count)
        assert(coordinator.activeCellControllers.keys.allSatisfy(ids.contains))
        let activeControllers = Set(coordinator.activeCellControllers.values.map(ObjectIdentifier.init))
        let reusableControllers = Set(coordinator.reusableCellControllers.map(ObjectIdentifier.init))
        assert(activeControllers.count == coordinator.activeCellControllers.count)
        assert(activeControllers.isDisjoint(with: reusableControllers))
    }
}
