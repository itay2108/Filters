import Foundation
import SwiftUI

/// Represents a type that can be filtered by a FilterPerformable. Must conform to FilterKeyPAthRepresentable.
public protocol Filterable: FilterKeyPathRepresentable {

    static func keyDisplayName<T: FilterPerformable>(for filter: T) -> String
    static func valueDisplayName<T: FilterPerformable>(for filter: T, value filterValue: AnyEquatable) -> String
    static func displayPriotity<T: FilterPerformable>(for filter: T) -> FilterDisplayPriority
    static func displayImageName<T: FilterPerformable>(for filter: T, value filterValue: AnyEquatable) -> String?
    static func displayColor<T: FilterPerformable>(for filter: T, value filterValue: AnyEquatable) -> Color?
}

public extension Filterable {
    
    static func keyDisplayName<T: FilterPerformable>(for filter: T) -> String {
        return filter.rawKey.description
    }
    
    static func valueDisplayName<T: FilterPerformable>(for filter: T, value filterValue: AnyEquatable) -> String {
        return filterValue.description
    }
    
    static func displayPriotity<T: FilterPerformable>(for filter: T) -> FilterDisplayPriority {
        return .normal
    }
    
    static func displayImageName<T: FilterPerformable>(for filter: T, value filterValue: AnyEquatable) -> String? {
        return nil
    }
    
    static func displayColor<T: FilterPerformable>(for filter: T, value filterValue: AnyEquatable) -> Color? {
        return nil
    }
}

extension Array where Element: Filterable {
    
    /// Returns the array only with object matching to the passed FilterPerformables
    /// - Parameter filters: an array of FilterPerformables that specify which objects are matching
    /// - Returns: an array of Filterable objects
    public func filtered<T: FilterPerformable>(by filters: [T]) -> [Element] where T.FilterableObject == Element {
        
        return self.filter { element in
            filters.allSatisfy({ $0.matches(element) })
        }
    }
}
