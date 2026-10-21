extension LazyScrollStackHost {
    enum UpdateUIViewReason {
        case firstFrame
        case updateCellLayout(indexes: [Int])
        case pagination
        case reset(preservingCachedSizes: Bool)
        case unknown
    }
}
