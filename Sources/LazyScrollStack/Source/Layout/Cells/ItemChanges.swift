extension LazyScrollStackHost {
    final class ItemChanges {
        let remove: [ClosedRange<Int>]
        let insert: [ClosedRange<Int>]
        
        init(remove: [ClosedRange<Int>], insert: [ClosedRange<Int>]) {
            self.remove = remove
            self.insert = insert
        }
    }
}
