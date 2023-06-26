import Foundation

/// A structure that is used to type-erase equatable conforming objects. Is used in FilterPerformables so that types with unrelated object values can be contained together.
public struct AnyEquatable: Equatable {
    public let value: Any
    public let equals: (Any) -> Bool

    public static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        if let stringLhs = (lhs.value as? String)?.lowercased(),
           let stringRhs = (rhs.value as? String)?.lowercased() {
            
            return stringLhs == stringRhs
        } else {
           return lhs.equals(rhs.value) || rhs.equals(lhs.value)
        }
    }
    
    public init<C: Equatable>(_ value: C) {
        self.value = value
        self.equals = { $0 as? C == value }
    }
}

extension AnyEquatable: CustomStringConvertible {
    public var description: String {
        return String(describing: value)
    }
}

extension AnyEquatable: Identifiable {
    public var id: String {
        return description
    }
}

public extension Equatable {
    
    /// Retruns the value as `AnyEquatable`
    var anyEquatable: AnyEquatable {
        .init(self)
    }
}

public extension Dictionary where Value == Any {
    
    /// Converts a dictionary values of type Any - to AnyEquatable type-erased values.
    ///
    /// - Warning: Any value that does not confirm to Equatable will be removed
    /// - Returns: a Dictionary with AnyEquatable values
    func asAnyComparableValues() -> [Key: AnyEquatable] {
        
        return self.compactMapValues { value in
            if let equatableValue = value as? (any Equatable) {
                return equatableValue.anyEquatable
            } else {
                return nil
            }
        }
    }
}

public extension Array where Element == Any {
    
    /// Converts Array values of type Any - to AnyEquatable type-erased values.
    ///
    /// - Warning: Any array value which elements that do not confirm to Equatable will be removed
    /// - Returns: a Dictionary with AnyEquatable values
    func asAnyEquatableElements() -> [AnyEquatable] {
        return self.compactMap { element in
            if let equatableValue = element as? (any Equatable) {
                return equatableValue.anyEquatable
            } else {
                return nil
            }
        }
    }
}

public extension Dictionary where Key == String, Value == [Any] {
    
    /// Converts a dictionary values of type [Any] - to an array of AnyEquatable type-erased values.
    ///
    /// - Warning: Any array value which elements that do not confirm to Equatable will be removed
    /// - Returns: a Dictionary with AnyEquatable values
    func asAnyEquatableValues() -> [Key: [AnyEquatable]] {
        
        return self.compactMapValues { arrayValue in
            return arrayValue.asAnyEquatableElements()
        }
    }
    
    /// Converts a dectionary to
    /// - Parameter type: <#type description#>
    /// - Returns: <#description#>
    func asFilters<T: Filterable>(for type: T.Type) -> [Filter<T>] {
        return self.asAnyEquatableValues().compactMap { filter in
            if let targetKeyPath = T.keypath(for: filter.key) {
                var filter = Filter(rawKey: filterData.key, comparisonTarget: targetKeyPath, values: filterData.value)
                filter.dismissValuesWhenAllAreSelected = T.dismissActiveValuesWhenAllAreSelected(for: filterData.key)
                return filter
            } else {
                return nil
            }
        }
    }
}

public extension Dictionary where Key == String, Value == [AnyEquatable] {
    
    func asFilters<T: Filterable>(for type: T.Type) -> [Filter<T>] {
        return self.compactMap { filterData in
            if let targetKeyPath = T.keypath(for: filterData.key) {
                var filter = Filter(rawKey: filterData.key, comparisonTarget: targetKeyPath, values: filterData.value)
                filter.dismissValuesWhenAllAreSelected = T.dismissActiveValuesWhenAllAreSelected(for: filterData.key)
                return filter
            } else {
                return nil
            }
        }
        
    }
}
