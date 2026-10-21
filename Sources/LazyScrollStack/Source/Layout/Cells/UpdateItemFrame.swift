import SwiftUI

extension LazyScrollStackHost {
    func updateItemFrame(
        at index: Int,
        to scrollView: UIScrollView,
        toPosition: CGFloat,
        extraLength: CGFloat = .zero,
        axis: Axis,
        coordinator: Coordinator
    ) {
        guard let subview = findHostingController(with: index, in: coordinator)?.view else {
            return
        }
        
        let newSize = axis.size(
            length: axis.length(of: subview.bounds.size) + extraLength,
            crossLength: axis == .vertical ? subview.bounds.width : subview.bounds.height
        )
        let origin = axis.point(
            length: toPosition,
            crossLength: axis == .vertical ? scrollView.bounds.minX : scrollView.bounds.minY
        )

        subview.frame = CGRect(origin: origin, size: newSize)
    }
}
