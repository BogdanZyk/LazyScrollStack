import SwiftUI

extension UIHostingController {
    // Hosted rows and footers must not inherit container safe-area insets.
    convenience init(rootView: Content, ignoreSafeArea: Bool) {
        self.init(rootView: rootView)

        if ignoreSafeArea {
            if #available(iOS 16.4, *) {
                self.safeAreaRegions = []
            } else {
                disableSafeArea()
            }
        }
    }
}

private extension UIHostingController {
    typealias SafeAreaInsetsGetterType = @convention(block) (AnyObject) -> UIEdgeInsets
    
    func disableSafeArea() {
        guard let viewClass = object_getClass(view) else {
            return
        }

        let viewSubclassName = String(cString: class_getName(viewClass))
            .appending("_getSafeAreaInsetsInterceptor")

        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        } else {
            guard
                let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String,
                let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0)
            else {
                return
            }

            if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                let safeAreaInsets: SafeAreaInsetsGetterType = { _ in
                    return .zero
                }

                class_addMethod(
                    viewSubclass,
                    #selector(getter: UIView.safeAreaInsets),
                    imp_implementationWithBlock(safeAreaInsets),
                    method_getTypeEncoding(method)
                )
            }

            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
        }
    }
}
