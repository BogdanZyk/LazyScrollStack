import UIKit

struct LazyScrollCellAnimationState {
    let bounds: CGRect
    let center: CGPoint
    let alpha: CGFloat
    let transform: CGAffineTransform

    init(view: UIView) {
        let presentation = view.layer.presentation()

        bounds = presentation?.bounds ?? view.bounds
        center = presentation?.position ?? view.center
        alpha = presentation.map {
            CGFloat($0.opacity)
        } ?? view.alpha

        transform = presentation?.affineTransform()
            ?? view.transform
    }
}
