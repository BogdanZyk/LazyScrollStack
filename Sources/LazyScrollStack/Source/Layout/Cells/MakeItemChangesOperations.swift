import SwiftUI

extension LazyScrollStackHost {
    func makeItemChangesOperations(
        currentRange: ClosedRange<Int>,
        targetRange: ClosedRange<Int>
    ) -> ItemChanges {
        var remove: [ClosedRange<Int>] = []
        var insert: [ClosedRange<Int>] = []
        
        if currentRange.upperBound < targetRange.lowerBound ||
            targetRange.upperBound < currentRange.lowerBound {
            
            remove.append(currentRange)
            insert.append(targetRange)
            return .init(remove: remove, insert: insert)
        }
        
        if targetRange.lowerBound > currentRange.lowerBound {
            let toRemove = currentRange.lowerBound...(targetRange.lowerBound - 1)
            remove.append(toRemove)
        }
        
        if targetRange.upperBound < currentRange.upperBound {
            let toRemove = (targetRange.upperBound + 1)...currentRange.upperBound
            remove.append(toRemove)
        }
        
        if currentRange.lowerBound > targetRange.lowerBound {
            let toInsert = targetRange.lowerBound...(currentRange.lowerBound - 1)
            insert.append(toInsert)
        }
        
        if currentRange.upperBound < targetRange.upperBound {
            let toInsert = (currentRange.upperBound + 1)...targetRange.upperBound
            insert.append(toInsert)
        }
        
        return .init(remove: remove, insert: insert)
    }
}
