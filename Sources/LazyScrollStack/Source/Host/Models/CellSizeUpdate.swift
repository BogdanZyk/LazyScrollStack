import CoreFoundation

extension LazyScrollStackHost {
    final class CellSizeUpdate {
        var index: Int
        var newSize: CGSize
        var oldSize: CGSize
        
        init(index: Int, newSize: CGSize, oldSize: CGSize) {
            self.index = index
            self.newSize = newSize
            self.oldSize = oldSize
        }
    }
}
