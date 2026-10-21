import SwiftUI
import UIKit

final class InterceptableScrollView: UIScrollView {
    var axis: Axis = .vertical
    private var contentOffsetWillSet: ContentOffsetWillSetType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        turnOnSetContentOffsetIntercepting()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContentOffsetWillSet(
        newValue: @escaping ContentOffsetWillSetType
    ) {
        contentOffsetWillSet = newValue
    }
}

private extension InterceptableScrollView {
    func turnOnSetContentOffsetIntercepting() {
        guard let originalClass = object_getClass(self) else { return }

        let subclassName = "\(originalClass)_setContentOffsetInterceptor"

        let subclass: AnyClass
        if let existing = NSClassFromString(subclassName) {
            subclass = existing
        } else {
            guard let newSubclass = objc_allocateClassPair(
                originalClass, subclassName, .zero
            ) else {
                return
            }
            
            subclass = newSubclass
            overrideContentOffsetSetter(in: subclass, originalClass: originalClass)
            objc_registerClassPair(subclass)
        }

        object_setClass(self, subclass)
    }
    
    func overrideContentOffsetSetter(
        in subclass: AnyClass,
        originalClass: AnyClass
    ) {
        let selector = #selector(setter: InterceptableScrollView.contentOffset)
        guard let method = class_getInstanceMethod(originalClass, selector) else {
            return
        }

        let originalIMP = method_getImplementation(method)

        let newSetterBlock: NewSetContentOffsetSetterType = { scrollView, proposedOffset in
            let offset = scrollView.axis.constrain(
                proposedOffset,
                to: scrollView.adjustedContentInset
            )
            assert(
                scrollView.axis == .vertical
                    ? offset.x == -scrollView.adjustedContentInset.left
                    : offset.y == -scrollView.adjustedContentInset.top
            )
            scrollView.contentOffsetWillSet?(scrollView.axis.length(of: offset))

            let originalSetter = unsafeBitCast(
                originalIMP, to: OriginalSetContentOffsetSetterType.self
            )
            originalSetter(scrollView, selector, offset)
        }

        let newIMP = imp_implementationWithBlock(newSetterBlock)
        
        class_addMethod(
            subclass,
            selector,
            newIMP,
            method_getTypeEncoding(method)
        )
    }
}
