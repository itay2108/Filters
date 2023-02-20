import Foundation

/// A type that describe error cases in filter manipulation
public enum FilterError: Error {
    case undefinedValue
    case parseError
    case rawConvertionError
    case filterNotFound
    
    var localizedDescription: String {
        switch self {
        case .undefinedValue:
            return "selected value is not allowed for this filter"
        case .parseError:
            return "could not parse filters from raw model"
        case .rawConvertionError:
            return "could not encode filters to raw model"
        case .filterNotFound:
            return "could not find filter to modify"
        }
    }
}
