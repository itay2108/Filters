import Foundation

//Demonstration objects initiation - each .placeholder() is generated with random parameters
let allPeople: [Person] = Array(1...100).map({ _ in .placeholder() })
let allDogs: [Dog] = Array(1...50).map({ _ in .placeholder() })

//The main goal of this module is to be able to convert, easily represent & apply filters to different structures. It is assumed that most filters that are received from server endpoints will be represented as dictionaries. This variable is a basic example for one such response.
let rawFilters = [
        "age": [10, 11, 12, 13, 14, 15],
        "name": ["or", "maayan", "noam"],
        "dogName": ["wooferz", "Bonnie"],
        "gender": ["female", "male"]
]

//Activation of certain values (can be toggled by UI):
//
//Any raw filter dictionary can be converted to a Filter<T> structure by calling .asFilters(for:)
//and passing an object type that conforms to FilterKeyPathRepresentable. The mentioned protocol requires a specification of which target keypaths every raw filter key should match to. refer to FilterKeyPathRepresentable to learn more.
var dogFilters = rawFilters.asFilters(for: Dog.self)

//When referncing a sequence of Filter<T>s, it is possible to find a specific one easily by calling .filter(for:) and passing the raw key for the needed filter.
if var dogOwnerNameFilter = dogFilters.filter(for: Dog.FilterKeys.ownerName.rawKey) {
    
    //Every Filter<T> contains an array of possible values, so it is easy to display a filter screen with all of the available values for selection. On initiation, no specific values are active - to select/deselect a value simply call .toggle(value:) with the relevant filter value.
    try? dogOwnerNameFilter.toggle(value: "or".anyEquatable)
    
    //When a active values are updated for a Filter<T>, call .update(filter:) on the used filters sequence to apply the recently updated Filter<T> object.
    try? dogFilters.update(filter: dogOwnerNameFilter)
}

//Filter<T>s are comfortable CustomStringRepresentable
print(dogFilters)


//Activation of all values in filters:
var peopleFilters = rawFilters.asFilters(for: Person.self)

for filter in peopleFilters {
    
    //It is possible to activate all values by calling .activateAllValues()
    var modifiedFilter = filter.asAllValuesActivated()
    try? modifiedFilter.toggle(value: filter.values.randomElement()!)
    try? peopleFilters.update(filter: modifiedFilter)
}

print(peopleFilters)

//Apply filters by calling .filtered(by:) on a sequence containing objects that match the filter.
// a method is available for applying a sequence of Filter<T>s, as well as a single Filter<T>.
let filteredPeople = allPeople.filtered(by: peopleFilters)
let filteredDogs = allDogs.filtered(by: dogFilters)

//Conversion to raw (can be used in API calls):
//
//Call .asRawFilters(forValues:) to convert Filter<T> objects back to api request representable dictionaries.
let activeRawDogFilters = dogFilters.asRawFilters(forValues: .active)
let activeRawPeopleFilters = peopleFilters.asRawFilters(forValues: .all)
