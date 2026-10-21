#if DEBUG
import Foundation
import os

extension LazyScrollStackHost {
    func logPlaceItems(
        minY: CGFloat,
        maxY: CGFloat,
        coordinator: Coordinator
    ) {
        let minYFormatted = minY.formatted2
        let maxYFormatted = maxY.formatted2
        
        coordinator.logger.log("Layout applied to viewport \(minYFormatted, privacy: .public)...\(maxYFormatted, privacy: .public); active items: \(coordinator.itemsRange, privacy: .public)")
    }
}

private extension CGFloat {
    var formatted2: String {
        String(format: "%.2f", self)
    }
}
#endif
