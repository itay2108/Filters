import Foundation

/// Represents an Enum capable of describing raw filter keys. Is created to make conforming to FilterKeyPathRepresentable & Filterable easier.
public protocol FilterKey: RawRepresentable, CaseIterable {
    
    /// The value represeting a raw key of a FilterPerformable. Returns the rawValue of the case, lowercased by default.
    var rawKey: String { get }
}

public extension FilterKey {
     var rawKey: String {
         return String(describing: self.rawValue).lowercased()
    }
    
    init?(rawKey: any StringProtocol) {
        if let caseByKey = Self.allCases.first(where: { $0.rawKey == rawKey }) {
            self = caseByKey
        } else {
            return nil
        }
    }
}

public extension FilterKey where RawValue == String {
    
    /// Attempts to init the FilterKey in a non case-sensitive way
    /// - Parameter caseForgivingRawKey: the key to init the enmu from
    init?(caseForgivingRawKey: String) {
        if let caseByKey = Self.allCases.first(where: { $0.rawKey.lowercased() == caseForgivingRawKey.lowercased() }) ?? .init(rawValue: caseForgivingRawKey) ?? .init(rawValue: caseForgivingRawKey.lowercased()) {
            self = caseByKey
        } else {
            return nil
        }
    }
}

/// Represents an Object that is able to point at keyPath for passed FilterPerformable raw keys.
public protocol FilterKeyPathRepresentable {
    
    /// Returns optional keypaths that are pointing to selfs parameters by passing a string representing a filter key
    /// - Parameter key: a string representing a FilterPerformable raw key
    /// - Returns: an optional keypath pointing to a parameter in self
    static func keypath(for key: String) -> KeyPath<Self, AnyEquatable>?
    
    static func dismissActiveValuesWhenAllAreSelected(for key: String) -> Bool
}

public extension FilterKeyPathRepresentable {
    static func dismissActiveValuesWhenAllAreSelected(for key: String) -> Bool {
        return true
    }
}
