import SwiftUI

/// A scrollable stack that lazily creates and reuses item views.
///
/// Each item must have a unique, stable identifier. Changing an identifier
/// removes the existing item and inserts a new one.
public struct LazyScrollStack<
    ItemContent: View,
    FooterContent: View,
    ID: Hashable
> {
    typealias RowContentBuilder = (Int) -> ItemContent
    typealias FooterContentBuilder = () -> FooterContent
    typealias OnContentSizeChangeAction = (ContentSizeMeasurement) -> Void
    typealias OnScrollMetricsChangeAction = (ScrollMetrics) -> Void
    
    var axis: Axis
    var itemIDs: [ID]

    var rowContent: RowContentBuilder
    var footerContent: FooterContentBuilder?

    var onContentSizeChangeAction: OnContentSizeChangeAction?
    var onScrollMetricsChangeAction: OnScrollMetricsChangeAction?
    var animationConfiguration: LazyScrollAnimationConfiguration = .init()

    var alwaysBounce: Bool
    var bounces: Bool
    var showsIndicators: Bool
    var isScrollEnabled: Bool
    var spacing: CGFloat

    init(
        axis: Axis,
        itemIDs: [ID],
        spacing: CGFloat,
        @ViewBuilder
        rowContent: @escaping RowContentBuilder,
        footerContent: FooterContentBuilder? = nil,
        onContentSizeChangeAction: OnContentSizeChangeAction? = nil,
        onScrollMetricsChangeAction: OnScrollMetricsChangeAction? = nil,
        alwaysBounce: Bool = false,
        bounces: Bool = true,
        showsIndicators: Bool = true,
        isScrollEnabled: Bool = true
    ) {
        self.axis = axis
        self.itemIDs = itemIDs
        self.spacing = spacing
        self.rowContent = rowContent
        self.footerContent = footerContent
        self.onContentSizeChangeAction = onContentSizeChangeAction
        self.onScrollMetricsChangeAction = onScrollMetricsChangeAction
        self.alwaysBounce = alwaysBounce
        self.bounces = bounces
        self.showsIndicators = showsIndicators
        self.isScrollEnabled = isScrollEnabled
    }
}


public extension LazyScrollStack where FooterContent == EmptyView {

    /// Creates a stack from a collection of identifiable elements.
    ///
    /// - Parameters:
    ///   - data: The collection that provides the stack's items.
    ///   - axis: The scroll axis. The default value is ``SwiftUI/Axis/vertical``.
    ///   - spacing: The distance, in points, between adjacent items.
    ///   - content: A view builder that creates a view for each element.
    init<Data>(
        _ data: Data,
        axis: Axis = .vertical,
        spacing: CGFloat = .zero,
        @ViewBuilder content: @escaping (Data.Element) -> ItemContent
    )
    where
        Data: RandomAccessCollection,
        Data.Element: Identifiable,
        ID == Data.Element.ID
    {
        self.init(
            data,
            id: \.id,
            axis: axis,
            spacing: spacing,
            content: content
        )
    }

    /// Creates a stack from a collection using a key path for item identity.
    ///
    /// - Parameters:
    ///   - data: The collection that provides the stack's items.
    ///   - id: A key path to a unique, stable identifier for each element.
    ///   - axis: The scroll axis. The default value is ``SwiftUI/Axis/vertical``.
    ///   - spacing: The distance, in points, between adjacent items.
    ///   - content: A view builder that creates a view for each element.
    init<Data>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        axis: Axis = .vertical,
        spacing: CGFloat = .zero,
        @ViewBuilder content: @escaping (Data.Element) -> ItemContent
    )
    where Data: RandomAccessCollection
    {
        let ids = data.map {
            $0[keyPath: id]
        }

        assert(Set(ids).count == ids.count, "LazyScrollStack IDs must be unique")

        self.init(
            axis: axis,
            itemIDs: ids,
            spacing: spacing,
            rowContent: { offset in
                let index = data.index(
                    data.startIndex,
                    offsetBy: offset
                )

                return content(data[index])
            }
        )
    }

    // MARK: Binding + Identifiable

    /// Creates a stack with editable views for identifiable elements.
    ///
    /// - Parameters:
    ///   - data: A binding to the mutable collection that provides the stack's items.
    ///   - axis: The scroll axis. The default value is ``SwiftUI/Axis/vertical``.
    ///   - spacing: The distance, in points, between adjacent items.
    ///   - content: A view builder that receives a binding to each element.
    init<Data>(
        _ data: Binding<Data>,
        axis: Axis = .vertical,
        spacing: CGFloat = .zero,
        @ViewBuilder content: @escaping (Binding<Data.Element>) -> ItemContent
    )
    where
        Data: MutableCollection & RandomAccessCollection,
        Data.Element: Identifiable,
        Data.Index: Hashable,
        ID == Data.Element.ID
    {
        self.init(
            data,
            id: \.id,
            axis: axis,
            spacing: spacing,
            content: content
        )
    }

    // MARK: Binding + Explicit ID

    /// Creates a stack with editable views and a key path for item identity.
    ///
    /// - Parameters:
    ///   - data: A binding to the mutable collection that provides the stack's items.
    ///   - id: A key path to a unique, stable identifier for each element.
    ///   - axis: The scroll axis. The default value is ``SwiftUI/Axis/vertical``.
    ///   - spacing: The distance, in points, between adjacent items.
    ///   - content: A view builder that receives a binding to each element.
    init<Data>(
        _ data: Binding<Data>,
        id: KeyPath<Data.Element, ID>,
        axis: Axis = .vertical,
        spacing: CGFloat = .zero,
        @ViewBuilder content: @escaping (Binding<Data.Element>) -> ItemContent
    )
    where
        Data: MutableCollection & RandomAccessCollection,
        Data.Index: Hashable
    {
        let snapshot = data.wrappedValue

        let ids = snapshot.map {
            $0[keyPath: id]
        }

        assert(Set(ids).count == ids.count, "LazyScrollStack IDs must be unique")

        self.init(
            axis: axis,
            itemIDs: ids,
            spacing: spacing,
            rowContent: { offset in
                let initialIndex = snapshot.index(
                    snapshot.startIndex,
                    offsetBy: offset
                )

                let binding = Self.elementBinding(
                    data,
                    id: ids[offset],
                    idKeyPath: id,
                    initialIndex: initialIndex,
                    fallback: snapshot[initialIndex]
                )

                return content(binding)
            }
        )
    }

    // MARK: Range<Int>

    /// Creates a stack from a range of integers.
    ///
    /// Each integer also serves as the item's identifier.
    ///
    /// - Parameters:
    ///   - data: The range that provides the stack's items.
    ///   - axis: The scroll axis. The default value is ``SwiftUI/Axis/vertical``.
    ///   - spacing: The distance, in points, between adjacent items.
    ///   - content: A view builder that creates a view for each integer.
    init(
        _ data: Range<Int>,
        axis: Axis = .vertical,
        spacing: CGFloat = .zero,
        @ViewBuilder content: @escaping (Int) -> ItemContent
    )
    where ID == Int
    {
        self.init(
            data,
            id: \.self,
            axis: axis,
            spacing: spacing,
            content: content
        )
    }
}

// MARK: - Binding Support

private extension LazyScrollStack {

    static func elementBinding<Data>(
        _ data: Binding<Data>,
        id: ID,
        idKeyPath: KeyPath<Data.Element, ID>,
        initialIndex: Data.Index,
        fallback: Data.Element
    ) -> Binding<Data.Element>
    where Data: MutableCollection & RandomAccessCollection
    {

        func currentIndex(
            in collection: Data
        ) -> Data.Index? {
            if initialIndex >= collection.startIndex,
               initialIndex < collection.endIndex,
               collection[initialIndex][keyPath: idKeyPath] == id {
                return initialIndex
            }

            return collection.indices.first {
                collection[$0][keyPath: idKeyPath] == id
            }
        }

        return Binding(
            get: {
                let collection = data.wrappedValue

                guard let index = currentIndex(in: collection) else {
                    return fallback
                }

                return collection[index]
            },
            set: { newValue in
                let collection = data.wrappedValue

                guard let index = currentIndex(in: collection) else {
                    return
                }

                data.wrappedValue[index] = newValue
            }
        )
    }
}

// MARK: - Modifiers

public extension LazyScrollStack {

    /// Adds an action to perform when the measured content size changes.
    ///
    /// - Parameter action: The action to perform with the new measurement.
    /// - Returns: A view that performs the action when the size changes.
    func onContentSizeChange(
        _ action: @escaping (ContentSizeMeasurement) -> Void
    ) -> Self {
        var copy = self
        copy.onContentSizeChangeAction = action
        return copy
    }

    /// Adds an action to perform when the scroll state changes.
    ///
    /// - Parameter action: The action to perform with the latest scroll metrics.
    /// - Returns: A view that reports changes to its scroll state.
    func onScrollMetricsChange(
        _ action: @escaping (ScrollMetrics) -> Void
    ) -> Self {
        var copy = self
        copy.onScrollMetricsChangeAction = action
        return copy
    }

    /// Controls whether the stack bounces when its content is smaller than the viewport.
    ///
    /// - Parameter enabled: A Boolean value that enables bouncing for undersized content.
    /// - Returns: A view with the updated bounce behavior.
    func alwaysBounce(_ enabled: Bool) -> Self {
        var copy = self
        copy.alwaysBounce = enabled
        return copy
    }

    /// Controls whether the stack bounces at the edges of its content.
    ///
    /// - Parameter enabled: A Boolean value that enables edge bouncing.
    /// - Returns: A view with the updated bounce behavior.
    func bounces(_ enabled: Bool) -> Self {
        var copy = self
        copy.bounces = enabled
        return copy
    }

    /// Controls whether the stack displays scroll indicators.
    ///
    /// - Parameter visible: A Boolean value that shows or hides the indicators.
    /// - Returns: A view with the updated indicator visibility.
    func showsIndicators(_ visible: Bool) -> Self {
        var copy = self
        copy.showsIndicators = visible
        return copy
    }

    /// Controls whether the user can scroll the stack.
    ///
    /// - Parameter enabled: A Boolean value that enables or disables scrolling.
    /// - Returns: A view with the updated scrolling behavior.
    func isScrollEnabled(_ enabled: Bool) -> Self {
        var copy = self
        copy.isScrollEnabled = enabled
        return copy
    }

    // MARK: Footer

    /// Adds a footer after the final item.
    ///
    /// - Parameter content: A view builder that creates the footer.
    /// - Returns: A stack that includes the footer.
    func footer<Content: View>(
        @ViewBuilder _ content: @escaping () -> Content
    ) -> LazyScrollStack<ItemContent, Content, ID> {
        .init(
            axis: axis,
            itemIDs: itemIDs,
            spacing: spacing,
            rowContent: rowContent,
            footerContent: content,
            onContentSizeChangeAction: onContentSizeChangeAction,
            onScrollMetricsChangeAction: onScrollMetricsChangeAction,
            alwaysBounce: alwaysBounce,
            bounces: bounces,
            showsIndicators: showsIndicators,
            isScrollEnabled: isScrollEnabled
        )
    }
    
    /// Configures the animations used for item and layout updates.
    ///
    /// - Parameter configuration: The transitions and durations to use.
    /// - Returns: A view with the specified animation configuration.
    func itemAnimations(
        _ configuration: LazyScrollAnimationConfiguration
    ) -> Self {
        var copy = self
        copy.animationConfiguration = configuration
        return copy
    }

    /// Configures the transitions used when items change.
    ///
    /// - Parameters:
    ///   - insertion: The initial visual state for inserted items.
    ///   - removal: The final visual state for removed items.
    ///   - pagination: The initial visual state for items added during pagination.
    ///   - fallbackDuration: The duration, in seconds, used on systems that cannot
    ///     bridge the SwiftUI animation.
    /// - Returns: A view with the specified item transitions.
    func itemAnimations(
        insertion: LazyScrollItemTransition = .opacity,
        removal: LazyScrollItemTransition = .opacity,
        pagination: LazyScrollItemTransition = .opacity,
        fallbackDuration: TimeInterval = 0.25
    ) -> Self {
        itemAnimations(
            .init(
                insertion: insertion,
                removal: removal,
                pagination: pagination,
                fallbackDuration: fallbackDuration
            )
        )
    }
}
