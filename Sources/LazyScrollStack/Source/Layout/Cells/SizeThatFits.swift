import SwiftUI

extension LazyScrollStackHost {
    func sizeThatFits(
        crossLength: CGFloat,
        axis: Axis,
        hostingController: UIHostingController<some View>
    ) -> CGSize {
        let proposedSize = axis.size(length: .zero, crossLength: crossLength)
        return hostingController.sizeThatFits(in: proposedSize)
    }
}
