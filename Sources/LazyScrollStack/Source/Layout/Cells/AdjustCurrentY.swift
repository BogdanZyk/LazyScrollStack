import SwiftUI

extension LazyScrollStackHost {
    func incrementCurrentY(
        currentValue: CGFloat, index: Int, cellSize: CGSize, spacing: CGFloat, axis: Axis
    ) -> CGFloat {
        return if index != itemIDs.count - 1 {
            currentValue + (axis.length(of: cellSize) + spacing)
        } else {
            currentValue + axis.length(of: cellSize)
        }
    }
    
    func decrementCurrentY(
        currentValue: CGFloat, cellSize: CGSize, spacing: CGFloat, axis: Axis
    ) -> CGFloat {
        currentValue - (axis.length(of: cellSize) + spacing)
    }
}
