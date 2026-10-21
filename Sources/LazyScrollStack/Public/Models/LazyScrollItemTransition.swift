import UIKit

/// The opacity and transform that define one endpoint of an item transition.
public struct LazyScrollItemTransition {
    /// The opacity to apply to the item, where `0` is transparent and `1` is opaque.
    public var alpha: CGFloat

    /// The affine transform to apply to the item.
    public var transform: CGAffineTransform
    
    /// Creates a visual state for an item transition.
    ///
    /// - Parameters:
    ///   - alpha: The opacity to apply to the item.
    ///   - transform: The affine transform to apply to the item.
    public init(
        alpha: CGFloat = 1,
        transform: CGAffineTransform = .identity
    ) {
        self.alpha = alpha
        self.transform = transform
    }
}

public extension LazyScrollItemTransition {
    /// A transition that leaves the item's appearance unchanged.
    static let identity = Self()
    
    /// A transition that makes the item fully transparent.
    static let opacity = Self(alpha: 0)
    
    /// Creates a transition that scales the item uniformly.
    ///
    /// - Parameter value: The scale factor to apply along both axes.
    /// - Returns: A transition with the specified scale transform.
    static func scale(_ value: CGFloat) -> Self {
        Self(
            transform: CGAffineTransform(
                scaleX: value,
                y: value
            )
        )
    }
    
    /// Creates a transition that offsets the item from its position.
    ///
    /// - Parameters:
    ///   - x: The horizontal offset, in points.
    ///   - y: The vertical offset, in points.
    /// - Returns: A transition with the specified translation transform.
    static func offset(
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> Self {
        Self(
            transform: CGAffineTransform(
                translationX: x,
                y: y
            )
        )
    }
    
    /// Creates a transition that rotates the item.
    ///
    /// - Parameter angle: The rotation angle, in radians.
    /// - Returns: A transition with the specified rotation transform.
    static func rotation(_ angle: CGFloat) -> Self {
        Self(
            transform: CGAffineTransform(
                rotationAngle: angle
            )
        )
    }
    
    /// Concatenates this transition with another transition.
    ///
    /// The resulting opacity is the product of both opacity values. The resulting
    /// transform applies this transition followed by `other`.
    ///
    /// - Parameter other: The transition to concatenate with this transition.
    /// - Returns: A transition containing the combined opacity and transform.
    func combined(with other: Self) -> Self {
        Self(
            alpha: alpha * other.alpha,
            transform: transform.concatenating(other.transform)
        )
    }
}

/// The transitions and timing values used for item and layout updates.
public struct LazyScrollAnimationConfiguration {
    /// The initial visual state of an inserted item.
    public var insertion: LazyScrollItemTransition

    /// The final visual state of a removed item.
    public var removal: LazyScrollItemTransition

    /// The initial visual state of an item inserted during pagination.
    public var pagination: LazyScrollItemTransition

    /// The duration, in seconds, used on systems that cannot bridge the SwiftUI animation.
    public var fallbackDuration: TimeInterval

    /// The fallback duration, in seconds, for layout changes without a SwiftUI animation.
    ///
    /// A value of `nil` disables fallback layout animation.
    public var layoutDuration: TimeInterval?

    /// Creates an animation configuration for stack updates.
    ///
    /// - Parameters:
    ///   - insertion: The initial visual state of an inserted item.
    ///   - removal: The final visual state of a removed item.
    ///   - pagination: The initial visual state of an item inserted during pagination.
    ///   - layoutDuration: The fallback duration, in seconds, for layout changes.
    ///     Pass `nil` to disable fallback layout animation.
    ///   - fallbackDuration: The duration, in seconds, used on systems that cannot
    ///     bridge the SwiftUI animation.
    public init(
        insertion: LazyScrollItemTransition = .scale(0.96).combined(with: .opacity),
        removal: LazyScrollItemTransition = .scale(0.96).combined(with: .opacity),
        pagination: LazyScrollItemTransition = .opacity,
        layoutDuration: TimeInterval? = 0.25,
        fallbackDuration: TimeInterval = 0.25
    ) {
        self.insertion = insertion
        self.removal = removal
        self.pagination = pagination
        self.layoutDuration = layoutDuration
        self.fallbackDuration = fallbackDuration
    }
}

extension LazyScrollItemTransition {
    func apply(to view: UIView) {
        view.alpha = alpha
        view.transform = transform
    }
    
    static func reset(_ view: UIView) {
        view.alpha = 1
        view.transform = .identity
    }
}
