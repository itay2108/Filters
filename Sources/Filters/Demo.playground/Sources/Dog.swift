import Foundation

public struct Dog: CustomStringConvertible {
    
    public var description: String {
        return "\(name) (\(age)) - owned by \(ownerName)\n"
    }
    
    var name: String
    var ownerName: String
    var age: Int
    
    public static func placeholder() -> Dog {
        let names = ["Lucky", "Bonnie", "Wooferz"]
        let ownerNames = ["Noam", "Alex", "Tal", "Tom", "Or", "Maayan"]
        return .init(name: names.randomElement() ?? "Rex",
                     ownerName: ownerNames.randomElement() ?? "Noam",
                     age: Int.random(in: 1...15))
    }
}

extension Dog: Filterable {
        
    public enum FilterKeys: String, FilterKey {
        case age = "age"
        case ownerName = "name"
        case name = "dogName"
    }
    
    var filterAge: AnyEquatable {
        return AnyEquatable(age)
    }
    
    var filterOwnerName: AnyEquatable {
        return AnyEquatable(ownerName)
    }
    
    var filterName: AnyEquatable {
        return AnyEquatable(name)
    }
    
    public static func keypath(for key: String) -> KeyPath<Dog, AnyEquatable>? {
        switch key.lowercased() {
        case FilterKeys.ownerName.rawKey:
            return \.filterOwnerName
        case FilterKeys.name.rawKey:
            return \.filterName
        case FilterKeys.age.rawKey:
            return \.filterAge
        default:
            return nil
        }
    }

}
