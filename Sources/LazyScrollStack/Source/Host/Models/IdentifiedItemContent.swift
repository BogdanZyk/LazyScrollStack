import SwiftUI

struct IdentifiedItemContent<ID: Hashable, Content: View>: View {
    let id: ID
    let content: Content

    var body: some View {
        content.id(id)
    }
}
