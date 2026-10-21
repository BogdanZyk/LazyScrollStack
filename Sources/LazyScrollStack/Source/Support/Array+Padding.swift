import Foundation

extension Array {
    mutating func pad(to size: Int, with element: Element) {
        guard count < size else { return }
        append(contentsOf: repeatElement(element, count: size - count))
    }
}
