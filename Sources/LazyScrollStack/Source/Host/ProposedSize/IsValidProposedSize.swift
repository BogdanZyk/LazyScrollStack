import SwiftUI

extension LazyScrollStackHost {
    func isValidProposedSize(_ value: LayoutSize) -> Bool {
        value.height != .zero && value.height != .infinity && value.width != .zero && value.width != .infinity
    }
}
