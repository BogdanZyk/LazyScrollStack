import SwiftUI
import UIKit

extension Axis {
    func length(of size: CGSize) -> CGFloat {
        self == .vertical ? size.height : size.width
    }

    func length(of point: CGPoint) -> CGFloat {
        self == .vertical ? point.y : point.x
    }

    func size(length: CGFloat, crossLength: CGFloat) -> CGSize {
        self == .vertical
            ? CGSize(width: crossLength, height: length)
            : CGSize(width: length, height: crossLength)
    }

    func point(length: CGFloat, crossLength: CGFloat = .zero) -> CGPoint {
        self == .vertical
            ? CGPoint(x: crossLength, y: length)
            : CGPoint(x: length, y: crossLength)
    }

    func constrain(_ offset: CGPoint, to insets: UIEdgeInsets) -> CGPoint {
        self == .vertical
            ? CGPoint(x: -insets.left, y: offset.y)
            : CGPoint(x: offset.x, y: -insets.top)
    }

    func leadingInset(of insets: UIEdgeInsets) -> CGFloat {
        self == .vertical ? insets.top : insets.left
    }

    func trailingInset(of insets: UIEdgeInsets) -> CGFloat {
        self == .vertical ? insets.bottom : insets.right
    }

    func setLeadingInset(_ value: CGFloat, in insets: inout UIEdgeInsets) {
        if self == .vertical {
            insets.top = value
        } else {
            insets.left = value
        }
    }

    func insets(leading value: CGFloat) -> UIEdgeInsets {
        self == .vertical
            ? UIEdgeInsets(top: value, left: .zero, bottom: .zero, right: .zero)
            : UIEdgeInsets(top: .zero, left: value, bottom: .zero, right: .zero)
    }
}
