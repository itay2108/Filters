//
//  FilterDisplayPriority.swift
//  Filters
//
//  Created by Itay Gervash on 04/03/2023.
//

import Foundation

public enum FilterDisplayPriority: Int, Comparable {
    public static func < (lhs: FilterDisplayPriority, rhs: FilterDisplayPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case lowest = 0
    case low = 250
    case normal = 500
    case high = 750
    case highest = 900
    case first = 1000
}
