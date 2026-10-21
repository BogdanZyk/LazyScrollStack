import UIKit

extension InterceptableScrollView {
    typealias OriginalSetContentOffsetSetterType = @convention(c) (InterceptableScrollView, Selector, CGPoint) -> Void
    typealias NewSetContentOffsetSetterType = @convention(block) (InterceptableScrollView, CGPoint) -> Void
    typealias ContentOffsetWillSetType = (_ contentOffset: CGFloat) -> Void
}
