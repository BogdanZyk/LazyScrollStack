import SwiftUI

#if DEBUG
import os
#endif

extension LazyScrollStackHost {
    final class Coordinator: NSObject, UIScrollViewDelegate {
        let cacheSize = 0.15
        let reusableCellControllerLimit = 16

        var axis: Axis
        var itemIDs: [ID]
        var cellSizes: [CGSize]
        var currentCachedHeightRange: (CGFloat, CGFloat) = (.zero, .zero)
        var currentContentOffset: CGFloat = .zero
        var currentDirection: ScrollDirection = .down
        var currentScrollActivity: ScrollMetrics.Activity = .idle
        var currentScrollVelocity: CGFloat = .zero
        var currentProposedSize: LayoutSize = .init(width: .zero, height: .zero)
        var estimatedCellHeight: CGFloat = .zero
        var estimatedHeight: CGFloat = .zero
        var footerController: UIHostingController<FooterContent>?
        var isFirstFramePrepared: Bool = false
        var isFooterActive: Bool = false
        var itemsRange: ClosedRange<Int> = Int.zero...Int.zero
        var lastSentMeasuredHeight: MeasuredHeight
        var lastSentScrollMetrics: ScrollMetrics?
        var measuredCellsCount: Int = .zero
        var measuredHeight: CGFloat = .zero
        var lastScrollSampleTime: TimeInterval?
        var onScrollActivityChange: ((UIScrollView) -> Void)?
        var placements: [CGPoint?]
        var activeCellControllers: [ID: CellHostingController] = [:]
        var reusableCellControllers: [CellHostingController] = []
        var isSetContentInsetInProgress: Bool = false
        var shouldResetContentSize: Bool = false
        var spacing: CGFloat
        var targetItemsRange: ClosedRange<Int>
        
        #if DEBUG
        let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: "LazyScrollStackLayout"
        )
        #endif
        
        init(
            axis: Axis,
            itemIDs: [ID],
            spacing: CGFloat
        ) {
            let itemCount = itemIDs.count
            
            self.axis = axis
            self.itemIDs = itemIDs
            self.cellSizes = [CGSize].init(repeating: .zero, count: itemCount)
            self.placements = [CGPoint?].init(repeating: nil, count: itemCount)
            self.spacing = spacing
            self.targetItemsRange = itemsRange
            self.lastSentMeasuredHeight = .unknown
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            currentScrollActivity = .dragging
            currentScrollVelocity = .zero
            lastScrollSampleTime = ProcessInfo.processInfo.systemUptime
            onScrollActivityChange?(scrollView)
        }

        func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            currentScrollActivity = .decelerating
            onScrollActivityChange?(scrollView)
        }

        func scrollViewDidEndDragging(
            _ scrollView: UIScrollView,
            willDecelerate decelerate: Bool
        ) {
            guard !decelerate else { return }
            finishScrolling(in: scrollView)
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            finishScrolling(in: scrollView)
        }

        private func finishScrolling(in scrollView: UIScrollView) {
            currentScrollActivity = .idle
            currentScrollVelocity = .zero
            lastScrollSampleTime = nil
            onScrollActivityChange?(scrollView)
        }
    }
}

extension LazyScrollStackHost.Coordinator {
    var isAllCellsMeasured: Bool {
        cellSizes.allSatisfy { $0 != .zero }
    }
}
