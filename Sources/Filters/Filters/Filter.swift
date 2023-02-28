import Foundation

/// A structure that conforms to FilterPerformable, and is able filter any object that conforms to Filterable,
/// but also implements additional methods that make manipulating FilterPerformables & Filterables easier in UI (and programmatic) environments.
///
/// This structure is generic, and acquires it's Filterable target when the comparisonTarget is passed in its initializer
public struct Filter<T: FilterKeyPathRepresentable>: FilterPerformable, Identifiable {
    
    public var id: String {
        return rawKey
    }
    
    /// Represents the initial key for the filter. Is used to point to a keypath for structures in `FilterKeyPathRepresentable`
    public var rawKey: String
    
    /// The keyPath against which the active values of the object will be compared
    public var comparisonTarget: KeyPath<T, AnyEquatable>
    
    /// All Possible values for the filter
    public var values: [AnyEquatable]
    
    /// Active values that will be compared against the specified KeyPath of the target object
    public var activeValues: [AnyEquatable] = []
    
    /// Returns a boolean value that describes if all values are set to active
    public var allValuesAreActive: Bool {
        return values.allSatisfy({ activeValues.contains($0) })
    }
    
    /// Returns a boolean value that describes if none of the values are set to active
    public var allValuesAreInactive: Bool {
        return activeValues.isEmpty
    }

    //MARK: - Inits
    
    /// Default initializer for Filter
    /// - Parameters:
    ///   - rawKey: the identifier of the filter. will be passed in filterable objects to point at relevant keypaths
    ///   - comparisonTarget: the keypath against which the values of the filter will be compared to
    ///   - values: the possible balues of the filter
    public init(rawKey: String, comparisonTarget: KeyPath<T, AnyEquatable>, values: [AnyEquatable]) {
        self.rawKey = rawKey
        self.comparisonTarget = comparisonTarget
        self.values = values
    }
    
    //MARK: - Methods
    
    /// Toggles the provided value - from active to inactive, or vice versa. Throws an error if value is not valid
    /// - Parameter filterValue: an AnyFilterable value to activate or deactivate
    public mutating func toggle(value filterValue: AnyEquatable) throws {
        guard values.contains(filterValue) else {
            throw FilterError.undefinedValue
        }
        
        if self.activeValues.contains(filterValue) {
            activeValues.removeAll(where: { $0 == filterValue })
        } else {
            activeValues.append(filterValue)
        }
    }
    
    /// Activates all available values for the object
    public mutating func activateAllValues() {
        activeValues = values
    }
    
    /// Deactivates all active values in the object
    public mutating func deactivateAllValues() {
        activeValues = []
    }
    
    /// Returns a clone of self, with all available values active
    ///
    /// Use this when the filter is immutable and .activateAllValues() is not available
    /// - Returns: a Filter object
    public func asAllValuesActivated() -> Filter<T> {
        var filter = self
        filter.activeValues = filter.values
        return filter
    }
    
    /// Returns a clone of self, with no active values
    ///
    /// Use this when the filter is immutable and .deactivateAllValues() is not available
    /// - Returns: a Filter object
    public func asAllValuesDeactivated() -> Filter<T> {
        var filter = self
        filter.activeValues = []
        return filter
    }
    
    /// Checks if the provided value is active
    /// - Parameter value: an AnyEquatable value
    /// - Returns: a Boolean value represnts the activity state of the provided value
    public func isValueActive(_ value: AnyEquatable) -> Bool {
        return activeValues.contains(value)
    }
}

extension Filter: CustomStringConvertible {
    public var description: String {
        return "Filter (\(rawKey)): <Possible values: \(values), Active values: \(activeValues)>\n"
    }
}

extension Filter: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawKey)
        hasher.combine(values.map({ $0.description }))
    }
}
