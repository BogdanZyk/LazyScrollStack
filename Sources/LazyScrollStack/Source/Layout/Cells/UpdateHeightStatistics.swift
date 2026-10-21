import Foundation

extension LazyScrollStackHost {
    func updateHeightStatistics(
        coordinator: Coordinator,
        measuredHeight: CGFloat,
        measuredCountInPass: Int
    ) {
        coordinator.measuredHeight = measuredHeight
        coordinator.measuredCellsCount += measuredCountInPass
        
        let measuredCellHeight = measuredHeight - (coordinator.spacing * CGFloat(coordinator.measuredCellsCount - 1))
        let measuredCellCount = CGFloat(coordinator.measuredCellsCount)
        coordinator.estimatedCellHeight = measuredCellHeight / measuredCellCount
        
        let estimatedCellHeight = coordinator.estimatedCellHeight * (CGFloat(coordinator.cellSizes.count) - measuredCellCount)
        let spacers = coordinator.spacing * (CGFloat(coordinator.cellSizes.count) - 1)
        coordinator.estimatedHeight = measuredCellHeight + estimatedCellHeight + spacers
    }
}
