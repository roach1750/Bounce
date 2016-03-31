//
//  Extensions.swift
//  Bounce
//
//  Created by Andrew Roach on 2/27/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import Foundation
extension NSDate {
    
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool {
        return self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
    }
    
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool {
        return self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
    }
    
    func addDays(daysToAdd : Int) -> NSDate
    {
        let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        
        return self.dateByAddingTimeInterval(secondsInDays)
    }
    
    
    func addHours(hoursToAdd : Int) -> NSDate
    {
        let secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
        
        return self.dateByAddingTimeInterval(secondsInHours)
    }
}