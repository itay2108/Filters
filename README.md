# DSFilters
*Created by Itay Gervash*

## TL;DR

In case you're too busy to read everything, heres how to use this package:

1. Conform the object you wish to filter to Filterable
  * implement **keypath(for key: String) -> KeyPath<Self, AnyEquatable>?**
  * in this method, point at different KeyPaths for every filter key you wish implementing

2. Get a dictionary of raw filters. It's key should be of String type
    * let myFormattedFilters = myRawFilters.asFilters(for: MyFilterableObject.self)
    * toggle the values you wish to activate with myFormattedFilter.toggle(value:)

3. Get an array of your objects the you wish to filter
    - myArray.filter(with: myFormattedFilters)
    
4. Profit.

* Altreantively, its also possible to create filters by calling the default Filter.init() and passing the needed values

* If you wish to apply filters non-locally, i.e. you have an api endpoint that expects filters in it's params - call myAwesomeFilters.asRawFilters() & pass them as parameters in your api
## Prologue

You are reading this right now, because I refuse to believe that filtering objects in a UI environment should be a headache - and probably you think the same.

What if only there was a genric, comfortable and easy way to implement object filtration? 
* To hold them in a structure - even if their values are not of the same type..
* To compare them easily with your data objects..
* Maybe even reuse the same filter values for different objects?

Well, if any of these things crossed your mind when developing filters - DSFilters is just what you need to make your job easier! 
Ok. No more wasting your time, let's get down to business:
## Filterable

Like my mom used to say - every filter needs an object *to* filter, and **Filterable** is exactly the protocol
to define how an object is filtered. Actually - this Protocol only contains conformance to another
protocol called **FilterKeyPathRepresentable**, which, as implied by its name - defines which keyPaths will be filtered by which filters. To define this, only one method is needed:

**keypath(for key: String) -> KeyPath<Self, AnyEquatable>?**

Later on, when we'll go through creating **FilterPerformable** objects, you'll see how it's used.

You've probably asked yourself: "What is this AnyEquatable thingy? is he trying to make out job easier or harder?"
Well, the short answer is that this is an implementation of type-erasing equatable-conforming values.
The fuller explanation is that Swift currently has limitations for working with different values when they are 
held in the same place. Even if they all conform to the same protocol - i.e. you cannot return a KeyPath for an Int parameter, and a String parameter in the same method. 

Sounds scary? Worry not! every equatable variable can be converted to **AnyEquatable** in two ways:

* **AnyEquatable**(<yourEquatableVar>)
* <yourEquatableVar>.**anyEquatable**

Let's go back to the main topic - in the required keyPath method I recommend switch-case-ing an enum with 
string raw values that represents the filter keys you want to work with your object.

Bonus - in this package there is a FilterKey protocol that implements a rawKey string variable for enums 
with string rawValues (it simply returns the raw value lowercased ans it's a bit safer to work with this) 

If you want to see an example for this implementation, you can check out Dog.swift & Person.swift in the Demo playground.
## FilterPerformable & Filter<T>

There's a saying "It takes two to Tango", and the same applies for **Filterable** and **FilterPerformable**! Filterable gets filtered, and FilterPerformable performs the filtration.

FilterPerformable is the protocol that contains the requirements for an object to be able to filter a **Filterable** object. DSFilters also contains an implementation for this protocol called **Filter<T>**, so you'll rarely need to re-implement this.

**Filter<T>** consists of 4 main parts:

- **rawKey**: Basically the id of the filter, when generating Filters from api jsons/dictionaries, every key in the dictionary gets to be a rawKey in the Filter object. ("size"/"age"/"assignee"/etc.)

- **comparisonTarget**: The KeyPath for a parameter in an object to compare values with, when applying the filters (must point at an **AnyEquatable** parameter for reason explained earlier). Keep in mind every Filter has a <T>, a generic value associated to it, and it will be inferred from this target.

- **values**: An array of possible values for the filter, nothing more nothing less. If it's a filter for shoe size the values can be [36, 37, 38, 39, 40...] (as AnyEquatable of course).
    
- **activeValues**: Again, pretty simple - represents the active values of the filter, which will be compared against the the value that **comparisonTarget** points at. If the user selects size 37 in the filters screen, you activate the filter with <Filter>.toggle(<value>).

So what's so easy and comfortable about this? Well:

- Create Filter Objects from [String: [Any]] raw filter dictionaries that you get from your server, by calling <[String: [Any]]>**.asFilters(for: <YourFilterableObject>.self)**. Dictionary keys are passed in the object's keyPath(for:) method to return the relevant KeyPath.

- Filter arrays of **Filterable** objects by calling [<Filterable>]**.filtered(by: [<Filter>])**

- Convert Filter objects back to raw dictionaries. Simply call [<Filter>]**.asRawFilters()**.

- Enable/Disable values easily, with <Filter>**.toggle(value:)** / <Filter>**.activateAllValues()** / <Filter>**.deactivateAllValues()**

- Reuse raw filters and initialize them for different objects - by returning different parameters in keyPath(for:)

- Hold an array of Filters in your viewModel! Return relevant in a single line of code!
## Epilogue

Got this far? I appreciate it! If you have any suggestions on how to improve DSFilters I'll be happy to hear you out.
Come by my desk or send me an email at: gervash@icloud.com

- Still have questions? check out the Demo playground to see a basic implementation.
- Seen the playground and it's not enough? download this example project https://github.com/itay2108/FiltersPOC

Good luck!
