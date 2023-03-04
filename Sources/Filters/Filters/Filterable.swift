import Foundation

/// Represents a type that can be filtered by a FilterPerformable. Must conform to FilterKeyPAthRepresentable.
public protocol Filterable: FilterKeyPathRepresentable {

    func keyDisplayName<T: FilterPerformable>(for filter: T) -> String
    func valueDisplayName(for filterValue: String) -> String
}

public extension Filterable {
    
    func keyDisplayName<T: FilterPerformable>(for filter: T) -> String {
        return filter.rawKey.description
    }
    
    func valueDisplayName<T: FilterPerformable>(for filter: T, value filterValue: AnyEquatable) -> String {
        return filterValue.description
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
