import SwiftUI

extension LazyScrollStackHost {
    func place(
        hostingController: UIHostingController<some View>,
        with size: CGSize,
        fromPosition position: CGFloat,
        to scrollViewController: InterceptableScrollViewController,
        axis: Axis
    ) {
        guard let hostedView = hostingController.view else {
            return
        }
        
        let bounds = scrollViewController.scrollView.bounds
        let origin = axis.point(
            length: position,
            crossLength: axis == .vertical ? bounds.minX : bounds.minY
        )
        let frame = CGRect(origin: origin, size: size)
        
        hostedView.frame = frame
        
        if hostedView.superview == nil {
            scrollViewController.addChild(hostingController)
            scrollViewController.scrollView.addSubview(hostedView)
            hostingController.didMove(toParent: scrollViewController)
        }
    }
}
