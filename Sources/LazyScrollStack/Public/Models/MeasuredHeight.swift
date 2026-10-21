import Foundation

/// The measurement state of a stack's content height.
public enum MeasuredHeight: Equatable {
    /// A state in which no content height is available.
    case unknown

    /// A state in which the complete content height is known.
    ///
    /// - Parameter value: The measured height, in points.
    case exact(value: CGFloat)

    /// A state in which the content height includes an approximation.
    ///
    /// - Parameters:
    ///   - total: The combined calculated and approximated height, in points.
    ///   - calculated: The height of measured items, in points.
    ///   - approximated: The estimated height of unmeasured items, in points.
    case estimated(total: CGFloat, calculated: CGFloat, approximated: CGFloat)
    
    /// A formatted description of the height and its measurement state.
    public var formatted: String {
        switch self {
        case .unknown:
            return "Unknown"
        case let .exact(value):
            return String(
                format: "MeasuredHeight: full(total: %.2f)",
                value
            )

        case let .estimated(total, calculated, approximated):
            return String(
                format: "MeasuredHeight: estimated(total: %.2f = calculated: %.2f + approximated: %.2f)",
                total,
                calculated,
                approximated
            )
        }
    }
}

extension MeasuredHeight {
    var total: CGFloat {
        switch self {
        case .unknown:
            .zero
        case let .exact(value):
            value
        case let .estimated(total, _, _):
            total
        }
    }
}
