import SwiftUI

extension LazyScrollStackHost {
    func updateSUIView(
        in hostingController: CellHostingController,
        with itemIndex: Int
    ) {
        hostingController.rootView = .init(
            id: itemIDs[itemIndex],
            content: rowContent(itemIndex)
        )
    }
}
