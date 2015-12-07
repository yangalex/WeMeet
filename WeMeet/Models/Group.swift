//
//  Group.swift
//  WeMeet
//
//  Created by Alexandre Yang on 7/23/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import Foundation
import Parse

class Group : PFObject {
    @NSManaged var name: String
    @NSManaged var users: [PFUser]
    @NSManaged var dayOfWeekOnly: Bool
    @NSManaged var uniqueId: Int
    
    override init() {
        super.init()
    }
    
    init(name: String) {
        super.init()
        self.name = name
        users = [PFUser]()
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: Group.parseClassName())
        
        query.includeKey("users")
        query.orderByDescending("createdAt")
        
        return query
    }
}

extension Group : PFSubclassing {
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Group"
    }
    
}