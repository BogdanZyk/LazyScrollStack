import SwiftUI

extension LazyScrollStackHost {
    func createFooter(
        _ footer: FooterContentBuilder
    ) -> UIHostingController<FooterContent> {
        let footerHostingController = UIHostingController(rootView: footer(), ignoreSafeArea: true)
        footerHostingController.view.accessibilityIdentifier = "LazyScrollStack: footer"
        
        return footerHostingController
    }
    
    func removeFooter(
        scrollView: UIScrollView
    ) {
        guard let subview = scrollView
            .subviews
            .first(where: { $0.accessibilityIdentifier == "LazyScrollStack: footer" })
        else {
            return
        }
        subview.removeFromSuperview()
    }
}
