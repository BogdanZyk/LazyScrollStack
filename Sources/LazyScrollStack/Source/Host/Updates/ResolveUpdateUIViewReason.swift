extension LazyScrollStackHost {
    func resolveUpdateUIViewReason(
        coordinator: Coordinator
    ) -> UpdateUIViewReason {
        guard coordinator.isFirstFramePrepared else {
            return .firstFrame
        }

        if coordinator.axis != axis || coordinator.spacing != spacing {
            coordinator.axis = axis
            coordinator.spacing = spacing
            return .reset(preservingCachedSizes: false)
        }

        if coordinator.itemIDs == itemIDs {
            guard !itemIDs.isEmpty else {
                return .unknown
            }

            return .updateCellLayout(indexes: Array(coordinator.itemsRange))
        }

        if !coordinator.itemIDs.isEmpty,
           itemIDs.starts(with: coordinator.itemIDs) {
            return .pagination
        }

        return .reset(preservingCachedSizes: true)
    }
}
