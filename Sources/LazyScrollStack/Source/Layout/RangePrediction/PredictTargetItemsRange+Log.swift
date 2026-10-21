#if DEBUG
import Foundation
import os

extension LazyScrollStackHost {
    func logPredictTargetItemsRange(
        cachedHeightRange: ClosedRange<CGFloat>,
        direction: ScrollDirection,
        coordinator: Coordinator
    ) {
        coordinator.logger.log("Visible item range: \(coordinator.itemsRange, privacy: .public)")
        coordinator.logger.log("Predicted item range: \(coordinator.targetItemsRange, privacy: .public)")

        if !coordinator.shouldResetContentSize {
            let isScrollingDown = direction == .down
            let index = isScrollingDown
            ? coordinator.targetItemsRange.lowerBound
            : min(coordinator.targetItemsRange.upperBound + 1, coordinator.cellSizes.count - 1)
            
            let startY = coordinator.placements[index]
                .map { coordinator.axis.length(of: $0) } ?? .zero
            let directionLabel = isScrollingDown ? "downward" : "upward"
            
            coordinator.logger.log(
            """
            Layout update begins at item \(index, privacy: .public), moving \(directionLabel, privacy: .public). \
            Starting offset: \(startY.formatted2, privacy: .public); cached span: \(cachedHeightRange.formatted2, privacy: .public)
            """
            )
        }
    }
}

private extension CGFloat {
    var formatted2: String {
        String(format: "%.2f", self)
    }
}

private extension ClosedRange where Bound == CGFloat {
    var formatted2: String {
        "\(lowerBound.formatted2)...\(upperBound.formatted2)"
    }
}
#endif
