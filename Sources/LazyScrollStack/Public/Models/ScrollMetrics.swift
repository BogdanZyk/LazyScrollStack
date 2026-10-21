import CoreGraphics

/// A snapshot of a stack's current scroll state.
public struct ScrollMetrics: Equatable {
    /// The direction of the most recent scroll movement.
    public enum Direction: Equatable {
        /// The scroll position is moving toward the content's leading edge.
        case towardStart

        /// The scroll position is moving toward the content's trailing edge.
        case towardEnd

        /// The scroll position is not moving.
        case stationary
    }

    /// The current phase of scrolling.
    public enum Activity: Equatable {
        /// The stack is not scrolling.
        case idle

        /// The user is actively dragging the content.
        case dragging

        /// The content is decelerating after the user ends a drag.
        case decelerating
    }

    /// The distance from the scrollable content's leading edge along the configured axis.
    public let offset: CGFloat

    /// The scroll position normalized to the range `0...1`.
    public let progress: CGFloat

    /// The scrolling velocity, in points per second.
    ///
    /// Positive values indicate movement toward the end of the content.
    public let velocity: CGFloat

    /// The direction of the latest scroll movement.
    public let direction: Direction

    /// The current phase of scrolling.
    public let activity: Activity

    /// Creates a snapshot of a scroll state.
    ///
    /// - Parameters:
    ///   - offset: The distance, in points, from the content's leading edge.
    ///   - progress: The scroll position normalized to the range `0...1`.
    ///   - velocity: The scrolling velocity, in points per second.
    ///   - direction: The direction of the most recent movement.
    ///   - activity: The current phase of scrolling.
    public init(
        offset: CGFloat,
        progress: CGFloat,
        velocity: CGFloat = .zero,
        direction: Direction = .stationary,
        activity: Activity = .idle
    ) {
        self.offset = offset
        self.progress = progress
        self.velocity = velocity
        self.direction = direction
        self.activity = activity
    }
}
