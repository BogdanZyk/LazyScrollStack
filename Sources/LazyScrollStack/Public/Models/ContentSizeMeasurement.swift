import CoreGraphics

/// A content size measurement and an indication of its accuracy.
public struct ContentSizeMeasurement: Equatable {
    /// The current content size, including any estimated height.
    public let size: CGSize

    /// The measured or estimated state of the content height.
    public let measuredHeight: MeasuredHeight

    /// Creates a measurement for a content size.
    ///
    /// - Parameters:
    ///   - size: The current content size.
    ///   - measuredHeight: The measured or estimated state of the height.
    public init(size: CGSize, measuredHeight: MeasuredHeight) {
        self.size = size
        self.measuredHeight = measuredHeight
    }
}
