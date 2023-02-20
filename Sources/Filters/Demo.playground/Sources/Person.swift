import Foundation

public struct Person: CustomStringConvertible {
    
    public var description: String {
        return "\(name) (\(gender)) - aged \(age)\n"
    }
    
    var name: String
    var age: Int
    var gender: String
    
    public static func placeholder() -> Person {
        let names = ["Noam", "Alex", "Tal", "Tom", "Or", "Maayan"]
        let genders = ["male", "female"] //there are only two genders
        return .init(name: names.randomElement() ?? "Noam",
                     age: Int.random(in: 10...35),
                     gender: genders.randomElement() ?? "male")
    }
}

extension Person: Filterable {
    
    enum FilterKeys: String, FilterKey {
        case age = "age"
        case name = "name"
        case gender = "gender"
    }
    
    var filterName: AnyEquatable {
        return AnyEquatable(name)
    }
    
    var filterAge: AnyEquatable {
        return AnyEquatable(age)
    }
    
    var filterGender: AnyEquatable {
        return AnyEquatable(gender)
    }
    
    public static func keypath(for rawKey: String) -> KeyPath<Person, AnyEquatable>? {
        
        switch rawKey.lowercased() {
        case FilterKeys.name.rawKey:
            return \.filterName
        case FilterKeys.age.rawKey:
            return \.filterAge
        case FilterKeys.gender.rawKey:
            return \.filterGender
        default:
            return nil
        }
    }
}
