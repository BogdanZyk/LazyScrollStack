import CoreGraphics

extension LazyScrollStackHost {
    func getScrollDirection(
        futureOffset: CGFloat,
        cachedOffset: CGFloat
    ) -> ScrollDirection {
        let delta = futureOffset - cachedOffset
        
        return delta.isZero
        ? .noChanges
        : (delta > .zero ? .down : .up)
    }
}
