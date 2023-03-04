import Foundation

/// Describes the requirements for an object to be able to filter a structure that conforms to `FilterKeyPathRepresentable`
public protocol FilterPerformable {
    associatedtype FilterableObject
    associatedtype RawKeyType: StringProtocol
    
    /// Represents the initial key for the filter. Is used to point to a keypath for structures in `FilterKeyPathRepresentable`
    var rawKey: RawKeyType { get set }
    
    /// All possible values for the filter
    var values: [AnyEquatable] { get set }
    
    /// The KeyPath for the structure that will be compared when applying the filter. Is used when calling `matches(:)`
    var comparisonTarget: KeyPath<FilterableObject, AnyEquatable> { get set }
    
    /// Current values that are active and compared against when calling `matches(:)`
    var activeValues: [AnyEquatable] { get set }
    
    func matches(_ object: FilterableObject) -> Bool
}

public extension FilterPerformable {
    
    /// Checks if the corresponding object to the  `FilterableObject` matches the  `activeValues`
    ///
    /// Returns true if activeValues is empty
    ///
    /// - Parameter object: will be compared against  `activeValues`
    /// - Returns: a Boolean value that represents if the passed object matches any of the `activeValues`
    func matches(_ object: FilterableObject) -> Bool {
        guard !activeValues.isEmpty else { return true }
        
        return activeValues.contains(object[keyPath: comparisonTarget])
    }
    
    /// Returns a dictionary that represents the `FilterPerformable` object. Returns all filter values in the value by default
    /// - Returns: a dictionary with a string key representing the rawKey, and the values - representing either all or active values.
    func asDictionary(forValues valueScope: FilterRepresentationScope = .all) -> [String: [Any]] {
        return [String(describing: rawKey): activeValues.map(\.value)]
    }
    
    /// A string representing active values separated by commas. Returns All if active values contains all possible values, or if it is empty.
    var activeValuesStringArguments: String {
        guard !activeValues.isEmpty,
              !values.allSatisfy({ activeValues.contains($0) }),
              values.count > 1 else {
            return "All"
        }
        
        let stringValues = activeValues.map({ $0.description })
        return stringValues.joined(separator: ", ")
    }
}

public extension Array where Element: FilterPerformable {
    
    /// Attempts to update fthe array of filters with the provided filter. If the filter does not exist in the array, an error is thrown
    /// - Parameter filter: a FilterPerformable element
    mutating func update(filter: Element) throws {
        guard contains(where: { $0.rawKey == filter.rawKey }) else {
            throw FilterError.undefinedValue
        }
        
        self = self.map({ $0.rawKey == filter.rawKey ? filter : $0 })
    }
    
    /// Returns a filter from the array with the specified raw key. Return nil if not found.
    /// - Parameter rawKey: the string key for the filter to retrieve
    /// - Returns: an optional FilterPerformable matching the provided raw key
    func filter(for rawKey: String) -> Element? {
        return self.first(where: { $0.rawKey == rawKey })
    }
    
    /// Returns only FilterPerformables that contain active values
    /// - Returns: an array of FilterPerformables
    func activeValuesOnly() -> Array<Element> {
        return self.filter({ !$0.activeValues.isEmpty })
    }
    
    /// Converts the array of FilterPerformables to a raw dictionary with string keys and array of any values
    /// - Parameter valueScope: defines if disctionary values are all or active values (returns all values by default)
    /// - Returns: a dictionary representing the keys and values of the FilterPerformable
    func asRawFilters(forValues valueScope: FilterRepresentationScope = .all) -> [String: [Any]] {
        var rawFilters: [String: [Any]] = [:]
        self.forEach { filter in
            rawFilters[String(filter.rawKey)] = (valueScope == .all ? filter.values : filter.activeValues).map(\.value)
        }
        
        return rawFilters
    }
}

public extension Array where Element: FilterPerformable {
    
    mutating func deactivateAll() {
        var deactivatedFilters: [Element] = []
        
        self.forEach { filter in
            var deactivatedFilter = filter
            deactivatedFilter.activeValues = []
            deactivatedFilters.append(deactivatedFilter)
        }
        
        self = deactivatedFilters
    }
    
    mutating func activateAll() {
        var activatedFilters: [Element] = []
        
        self.forEach { filter in
            var activatedFilter = filter
            activatedFilter.activeValues = filter.values
            activatedFilters.append(activatedFilter)
        }
        
        self = activatedFilters
    }
}
