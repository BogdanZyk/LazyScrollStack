#if DEBUG
import Foundation
import os

extension LazyScrollStackHost {
    func logSetContentSize(
        newHeight: CGFloat,
        coordinator: Coordinator
    ) {
        if coordinator.shouldResetContentSize {
            coordinator.logger.log("Scroll content height reset to \(newHeight.formatted2, privacy: .public)")
        }
    }
}

private extension CGFloat {
    var formatted2: String {
        String(format: "%.2f", self)
    }
}
#endif
