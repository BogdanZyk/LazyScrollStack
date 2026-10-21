import UIKit

extension LazyScrollStackHost {
    // Restore safe-area dimensions omitted from the proposed size.
    func calculateAdjustedProposedSize(
        by uiViewController: InterceptableScrollViewController,
        proposedSize: LayoutSize
    ) -> LayoutSize {
        let safeAreaInsets = uiViewController.view.safeAreaInsets

        return if axis == .vertical {
            .init(
                width: proposedSize.width,
                height: proposedSize.height + safeAreaInsets.top + safeAreaInsets.bottom
            )
        } else {
            .init(
                width: proposedSize.width + safeAreaInsets.left + safeAreaInsets.right,
                height: proposedSize.height
            )
        }
    }
}
