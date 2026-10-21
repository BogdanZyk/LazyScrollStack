import SwiftUI

extension LazyScrollStackHost {
    typealias RowContentBuilder = (Int) -> ItemContent
    typealias FooterContentBuilder = () -> FooterContent
    typealias OnContentSizeChangeAction = (ContentSizeMeasurement) -> Void
    typealias OnScrollMetricsChangeAction = (ScrollMetrics) -> Void
    typealias CellContent = IdentifiedItemContent<ID, ItemContent>
    typealias CellHostingController = UIHostingController<CellContent>
}
