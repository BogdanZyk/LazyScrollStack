import Foundation
import SwiftUI

extension LazyScrollStackHost {
    struct LayoutSize {
        let width: Double
        let height: Double
        
        init(width: CGFloat?, height: CGFloat?) {
            self.width = width ?? .zero
            self.height = height ?? .zero
        }

        func length(along axis: Axis) -> CGFloat {
            axis == .vertical ? height : width
        }

        func crossLength(for axis: Axis) -> CGFloat {
            axis == .vertical ? width : height
        }
    }
}
