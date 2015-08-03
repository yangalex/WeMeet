//
//  TimeButton.swift
//  TimeMatch
//
//  Created by Alexandre Yang on 7/15/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit


class TimeDisplayButton: UIButton {
    
    // keep spacing constant
    var spacing: CGFloat?
    
    enum TimeState {
        case Single, Edge, Path, Unselected
    }
    
    var timeState: TimeState = .Unselected {
        
        didSet {
            // fix positioning for when button was a path
            if oldValue == .Path {
                self.frame = CGRectMake(self.frame.origin.x + (spacing! - CGFloat(self.frame.size.height)), self.frame.origin.y, CGFloat(self.frame.size.height), CGFloat(self.frame.size.height))
                self.layer.cornerRadius = 0.5 * self.frame.size.width
            }
            
            if timeState == .Single {
                self.layer.borderColor = greenColor.CGColor
                self.layer.cornerRadius = 0.5 * self.frame.size.width
                self.backgroundColor = greenColor
                self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                self.setBackgroundImage(nil, forState: .Normal)
            } else if timeState == .Edge {
                self.layer.borderColor = UIColor.clearColor().CGColor
                self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            } else if timeState == .Path {
                self.layer.borderColor = UIColor.clearColor().CGColor
                self.layer.cornerRadius = 0
                self.backgroundColor = greenColor
                self.setBackgroundImage(nil, forState: .Normal)
                self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                
                // change size of button
                self.frame = CGRectMake(self.frame.origin.x - (spacing! - CGFloat(self.frame.size.height)), self.frame.origin.y, self.frame.width + (spacing! - CGFloat(self.frame.size.height))*2, self.frame.height)
                
            } else if timeState == .Unselected {
                self.layer.cornerRadius = 0.5 * self.frame.size.width
                self.layer.borderColor = buttonColor.CGColor
                self.backgroundColor = UIColor.whiteColor()
                self.setTitleColor(buttonColor, forState: UIControlState.Normal)
                self.setBackgroundImage(nil, forState: .Selected)
            }
        }
    }
    
}
