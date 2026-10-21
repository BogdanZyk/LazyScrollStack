import SwiftUI

extension LazyScrollStackHost {
    
    func createCellController(
        itemIndex: Int,
        in coordinator: Coordinator
    ) -> CellHostingController {
        let id = coordinator.itemIDs[itemIndex]

        if let controller = coordinator.activeCellControllers[id] {
            prepareHostingControllerForUse(
                controller,
                itemIndex: itemIndex
            )
            controller.rootView = makeCellContent(
                itemIndex: itemIndex,
                id: id
            )

            return controller
        }

        let content = makeCellContent(
            itemIndex: itemIndex,
            id: id
        )

        let controller: CellHostingController

        if let reusable = coordinator.reusableCellControllers.popLast() {
            controller = reusable

            prepareHostingControllerForUse(
                controller,
                itemIndex: itemIndex
            )

            controller.rootView = content
        } else {
            controller = UIHostingController(
                rootView: content,
                ignoreSafeArea: true
            )

            prepareHostingControllerForUse(
                controller,
                itemIndex: itemIndex
            )
        }

        coordinator.activeCellControllers[id] = controller

        return controller
    }
    
    func prepareForReuseCellController(
        cellIndex: Int,
        in coordinator: Coordinator
    ) {
        guard coordinator.itemIDs.indices.contains(cellIndex) else {
            return
        }

        prepareForReuseCellController(id: coordinator.itemIDs[cellIndex], in: coordinator)
    }

    func prepareForReuseCellController(id: ID, in coordinator: Coordinator) {
        guard let hostingController = deactivateCellController(id: id, in: coordinator) else {
            return
        }

        cacheCellController(hostingController, in: coordinator)
    }

    func deactivateCellController(id: ID, in coordinator: Coordinator) -> CellHostingController? {
        guard let hostingController = coordinator.activeCellControllers.removeValue(forKey: id) else {
            return nil
        }

        hostingController.view.frame = .zero
        hostingController.view.isHidden = true
        hostingController.view.accessibilityIdentifier = nil

        return hostingController
    }

    func cacheCellController(_ hostingController: CellHostingController, in coordinator: Coordinator) {

        if coordinator.reusableCellControllers.count < coordinator.reusableCellControllerLimit {
            coordinator.reusableCellControllers.append(hostingController)
        } else {
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
        }
    }
}

private extension LazyScrollStackHost {
    func makeCellContent(itemIndex: Int, id: ID) -> CellContent {
        .init(id: id, content: rowContent(itemIndex))
    }

    func prepareHostingControllerForUse(_ value: UIHostingController<some View>, itemIndex: Int) -> Void {
        value.view.layer.removeAllAnimations()
        value.view.alpha = 1
        value.view.transform = .identity
        value.view.isHidden = false
        value.view.accessibilityIdentifier = getIdentifier(by: itemIndex)
    }
}
