import Foundation

/// A structure that conforms to FilterPerformable, and is able filter any object that conforms to Filterable,
/// but also implements additional methods that make manipulating FilterPerformables & Filterables easier in UI (and programmatic) environments.
///
/// This structure is generic, and acquires it's Filterable target when the comparisonTarget is passed in its initializer
public struct Filter<T: Filterable>: FilterPerformable, Identifiable {
    
    public var id: String {
        return rawKey
    }
    
    /// Represents the initial key for the filter. Is used to point to a keypath for structures in `FilterKeyPathRepresentable`
    public var rawKey: String
    
    /// The keyPath against which the active values of the object will be compared
    public var comparisonTarget: KeyPath<T, AnyEquatable>
    
    /// All Possible values for the filter
    public var values: [AnyEquatable]
    
    /// Controls whether active values gets reset when all possible values are activated
    public var dismissValuesWhenAllAreSelected: Bool = true
    
    /// Active values that will be compared against the specified KeyPath of the target object
    public var activeValues: [AnyEquatable] = [] {
        didSet {
            if allValuesAreActive, dismissValuesWhenAllAreSelected {
                activeValues = []
            }
        }
    }
    
    /// Inactive values that will not be compared against the specified KeyPath of the target object
    public var inactiveValues: [AnyEquatable] {
        return values.filter({ !activeValues.contains($0) })
    }
    
    /// Returns a boolean value that describes if all values are set to active.
    /// - Warning: Returns true if active values is empty as well!
    public var allValuesAreActive: Bool {
        return values.allSatisfy({ activeValues.contains($0) }) || allValuesAreInactive
    }
    
    /// Returns a boolean value that describes if none of the values are set to active
    public var allValuesAreInactive: Bool {
        return activeValues.isEmpty
    }
    
    /// Returns the display (UI) name for the Filter rawKey - defined in the associated Filterable object
    public var keyDiesplayName: String {
        return T.keyDisplayName(for: self)
    }
    
    public var displayPriotity: FilterDisplayPriority {
        return T.displayPriotity(for: self)
    }
    
    /// A string representing the display names of active values separated by commas. Returns All if active values contains all possible values, a single selected value if there's only one possible value, or an empty string if no active values at all
    public var activeValuesDisplayArguments: String {
        let stringValues = activeValues.map({ self.valueDisplayName(for: $0) })
        
        guard !allValuesAreActive else {
            return values.count != 1 ? "All" : values.map({ self.valueDisplayName(for: $0) }).joined(separator: ", ")
        }
        
        return stringValues.joined(separator: ", ")
    }
    
    /// Returns the display (UI) name for a provided value - defined in the associated Filterable object
    /// - Parameter value: the value for which to return the formatted name
    /// - Returns: a String representing the formatted UI display value
    public func valueDisplayName(for value: AnyEquatable) -> String {
        return T.valueDisplayName(for: self, value: value)
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
    
    /// Activates a specified filter value. Returns if value is alredy active
    /// - Warning: Throws if passed value is not in possible values
    /// - Parameter filterValue: the value to activate
    public mutating func activate(value filterValue: AnyEquatable) throws {
        guard values.contains(filterValue) else {
            throw FilterError.undefinedValue
        }
        
        if !self.activeValues.contains(filterValue) {
            activeValues.append(filterValue)
        }
    }
    
    /// Deactivates a specified filter value. Returns if value is alredy inactive
    /// - Warning: Throws if passed value is not in possible values
    /// - Parameter filterValue: the value to deactivate
    public mutating func deactivate(value filterValue: AnyEquatable) throws {
        guard values.contains(filterValue) else {
            throw FilterError.undefinedValue
        }
        
        if self.activeValues.contains(filterValue) {
            activeValues.removeAll(where: { $0 == filterValue })
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

extension Filter: Equatable {
    public static func ==(lhs: Filter, rhs: Filter) -> Bool {
        return lhs.rawKey == rhs.rawKey && lhs.activeValues == rhs.activeValues
    }
}
