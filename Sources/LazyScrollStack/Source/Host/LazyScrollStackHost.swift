import SwiftUI

struct LazyScrollStackHost<ItemContent: View, FooterContent: View, ID: Hashable> {
    let axis: Axis
    let itemIDs: [ID]
    
    let rowContent: RowContentBuilder
    let footerContent: FooterContentBuilder?
    let onContentSizeChangeAction: OnContentSizeChangeAction?
    let onScrollMetricsChangeAction: OnScrollMetricsChangeAction?
    let alwaysBounce: Bool
    let bounces: Bool
    let showsIndicators: Bool
    let isScrollEnabled: Bool
    let spacing: CGFloat
    let animationConfiguration: LazyScrollAnimationConfiguration
}
