//
//  TimeSlot.swift
//  WeMeet
//
//  Created by Alexandre Yang on 7/26/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import Foundation
import Parse

class Timeslot : PFObject, Comparable {
    
    // date variables
    @NSManaged var timeDate: TimeDate
    @NSManaged var hour: Int
    @NSManaged var isHalf: Bool
    @NSManaged var weekday: String
    
    @NSManaged var group: Group
    @NSManaged var user: PFUser
    
    init(hour: Int, isHalf: Bool) {
        super.init()
        if hour > 23 || hour < 0 {
            self.hour = 0
        } else {
            self.hour = hour
        }
        
        self.isHalf = isHalf
    }
    
    override init() {
        super.init()
    }
    
    func stringDescription() -> String {
        if isHalf == true {
            if hour > 9 {
                return "\(String(hour)):30"
            } else {
                return "0\(String(hour)):30"
            }
        } else {
            if hour > 9 {
                return "\(String(hour)):00"
            } else {
                return "0\(String(hour)):00"
            }
        }
    }
    
    static func fromString(timeString: String) -> Timeslot {
        let timeArray = timeString.componentsSeparatedByString(":")
        let hour = timeArray[0]
        let minute = timeArray[1]
        
        if minute == "30" {
            return Timeslot(hour: hour.toInt()!, isHalf: true)
        } else {
            return Timeslot(hour: hour.toInt()!, isHalf: false)
        }
    }
    
    
    func equalTo(otherTimeslot: Timeslot) -> Bool {
        if self.hour == otherTimeslot.hour && self.isHalf == otherTimeslot.isHalf {
            return true
        } else {
            return false
        }
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: "Timeslot")
        
        query.includeKey("user")
        query.includeKey("group")
        
        query.orderByAscending("hour")
        return query
    }
}

extension Timeslot : PFSubclassing {

    static func parseClassName() -> String {
        return "Timeslot"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}

func <(lhs: Timeslot, rhs: Timeslot) -> Bool {
    if lhs.hour == rhs.hour {
        if !lhs.isHalf && rhs.isHalf {
            return true
        } else {
            return false
        }
    } else if lhs.hour < rhs.hour {
        return true
    } else {
        return false
    }
}


func ==(lhs: Timeslot, rhs: Timeslot) -> Bool {
    if lhs.hour == rhs.hour && lhs.isHalf == rhs.isHalf {
        return true
    } else {
        return false
    }
}
