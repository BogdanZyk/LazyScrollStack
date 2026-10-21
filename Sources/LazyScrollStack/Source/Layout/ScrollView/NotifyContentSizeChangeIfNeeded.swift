import CoreGraphics

extension LazyScrollStackHost {
    func notifyContentSizeChangeIfNeeded(coordinator: Coordinator) {
        guard let onContentSizeChangeAction else {
            return
        }

        let measuredHeight: MeasuredHeight = if coordinator.isAllCellsMeasured {
            .exact(value: coordinator.measuredHeight)
        } else {
            .estimated(
                total: coordinator.estimatedHeight,
                calculated: coordinator.measuredHeight,
                approximated: coordinator.estimatedHeight - coordinator.measuredHeight
            )
        }

        guard measuredHeight != coordinator.lastSentMeasuredHeight else {
            return
        }

        onContentSizeChangeAction(
            .init(
                size: coordinator.axis.size(
                    length: measuredHeight.total,
                    crossLength: coordinator.currentProposedSize.crossLength(for: coordinator.axis)
                ),
                measuredHeight: measuredHeight
            )
        )
        coordinator.lastSentMeasuredHeight = measuredHeight
    }
}
