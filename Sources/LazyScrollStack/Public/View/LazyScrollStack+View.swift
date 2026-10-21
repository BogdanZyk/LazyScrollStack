import SwiftUI

extension LazyScrollStack: View {
    /// The content and behavior of the scroll stack.
    public var body: some View {
        LazyScrollStackHost(
            axis: axis,
            itemIDs: itemIDs,
            rowContent: rowContent,
            footerContent: footerContent,
            onContentSizeChangeAction: onContentSizeChangeAction,
            onScrollMetricsChangeAction: onScrollMetricsChangeAction,
            alwaysBounce: alwaysBounce,
            bounces: bounces,
            showsIndicators: showsIndicators,
            isScrollEnabled: isScrollEnabled,
            spacing: spacing,
            animationConfiguration: animationConfiguration
        )
    }
}
