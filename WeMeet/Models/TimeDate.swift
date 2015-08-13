//
//  TimeDate.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/13/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import Foundation

class TimeDate: PFObject, Comparable {
    @NSManaged var year: Int
    @NSManaged var month: Int
    @NSManaged var day: Int
    
    @NSManaged var group: Group
    
    init(year: Int, month: Int, day: Int) {
        super.init()
        self.year = year
        self.month = month
        self.day = day
    }
    
    override init() {
        super.init()
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: "TimeDate")
        
        query.includeKey("group")
        
        return query
    }
    
    func stringDescription() -> String {
        var monthString: String!
        
        switch month {
        case 1:
            monthString = "January"
        case 2:
            monthString = "February"
        case 3:
            monthString = "March"
        case 4:
            monthString = "April"
        case 5:
            monthString = "May"
        case 6:
            monthString = "June"
        case 7:
            monthString = "July"
        case 8:
            monthString = "August"
        case 9:
            monthString = "September"
        case 10:
            monthString = "October"
        case 11:
            monthString = "November"
        case 12:
            monthString = "December"
        default:
            monthString = "[unknown]"
            
        }
        
        return "\(monthString) \(day), \(year)"
    }
}

extension TimeDate: PFSubclassing {
    static func parseClassName() -> String {
        return "TimeDate"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}

func <(lhs: TimeDate, rhs: TimeDate) -> Bool {
    if lhs.year < rhs.year {
        return true
    } else if lhs.year > rhs.year {
        return false
    } else {
        if lhs.month < rhs.month {
            return true
        } else if lhs.month > rhs.month {
            return false
        } else {
            if lhs.day < rhs.day {
                return true
            } else {
                return false
            }
        }
    }
}

func ==(lhs: TimeDate, rhs: TimeDate) -> Bool {
    if lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day {
        return true
    } else {
        return false
    }
}









