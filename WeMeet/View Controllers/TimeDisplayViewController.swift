//
//  ViewController.swift
//  DisplayTimebuttons
//
//  Created by Alexandre Yang on 7/31/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

protocol TimeDisplayViewControllerDataSource {
    func timeslotsForDisplay() -> [Timeslot]
}

class TimeDisplayViewController: UIViewController {
    
    var selectedTimeslots: [Timeslot]!
    
    var dataSource: TimeDisplayViewControllerDataSource?
    
    var spacing: CGFloat = 3
    var BUTTON_SIZE: CGFloat!
    
    var buttonsArray: [TimeDisplayButton] = [TimeDisplayButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // calculate button size
        // Formula: (screen width - margins - space that spacing take) == space buttons have available to occupy
        //          divide that by 6 and you get size of each individual button
        BUTTON_SIZE = self.view.frame.width - 16 - spacing*5
        BUTTON_SIZE = BUTTON_SIZE/6
        spacing = spacing + BUTTON_SIZE
        
        reloadDisplay()
    }
    
    func reloadDisplay() {
        selectedTimeslots = dataSource?.timeslotsForDisplay()
        clearView()
        
        if selectedTimeslots.isEmpty {
            let clockImage = UIImage(named: "Clock")
            let imageView = UIImageView(image: clockImage)
            imageView.frame = CGRectMake(self.view.frame.width/2 - 50, self.view.frame.height/2 - 100, 100, 100)
            
            let label = UILabel(frame: CGRectMake(0, self.view.frame.height/2 + 10, self.view.frame.width, 20))
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor(red: 116/255, green: 116/255, blue: 116/255, alpha: 1.0)
            label.text = "No matched timeslots available"
            
            
            let descriptionLabel = UILabel(frame: CGRectMake(0, label.frame.origin.y+label.frame.height+5, self.view.frame.width, 20))
            descriptionLabel.font = UIFont(name: "HelveticaNeue", size: 13)
            descriptionLabel.textAlignment = NSTextAlignment.Center
            descriptionLabel.textColor = UIColor(red: 116/255, green: 116/255, blue: 116/255, alpha: 1.0)
            descriptionLabel.text = "Try selecting different times or filtering members."
            
            self.view.addSubview(label)
            self.view.addSubview(descriptionLabel)
            self.view.addSubview(imageView)
        } else {
            loadButtons()
            highlightButtons()
        }
    }
    
    
    func highlightButtons() {
        selectedTimeslots.sort({$0 < $1})
        var startOfCluster: Int = -1
        var endOfCluster: Int = -1
        
        for i in 0..<selectedTimeslots.count {
            if startOfCluster == -1 {
                startOfCluster = fromTimeToIndex(selectedTimeslots[i])
                if i == selectedTimeslots.count-1 {
                    println("last timeslot \(selectedTimeslots[i].stringDescription())")
                    endOfCluster = fromTimeToIndex(selectedTimeslots[i])
                    highlightFrom(startOfCluster, endIndex: endOfCluster)
                }
            } else {
                if isNeighboringTimeslot(selectedTimeslots[i], rhs: selectedTimeslots[i-1]) == false {
                    endOfCluster = fromTimeToIndex(selectedTimeslots[i-1])
                    highlightFrom(startOfCluster, endIndex: endOfCluster)
                    startOfCluster = fromTimeToIndex(selectedTimeslots[i])
                    endOfCluster = -1
                    if i == selectedTimeslots.count-1 {
                        endOfCluster = fromTimeToIndex(selectedTimeslots[i])
                        highlightFrom(startOfCluster, endIndex: endOfCluster)
                    }
                } else {
                    if i == selectedTimeslots.count-1 {
                        endOfCluster = fromTimeToIndex(selectedTimeslots[i])
                        highlightFrom(startOfCluster, endIndex: endOfCluster)
                    }
                }
            }
        }
        
    }
    
    func highlightFrom(startIndex: Int, endIndex: Int) {
        // startIndex is left handle
        if startIndex < endIndex {
            
            if contains(rightEdgeIndexes, startIndex) {
                buttonsArray[startIndex].timeState = .Single
            } else {
                buttonsArray[startIndex].setBackgroundImage(UIImage(named: "ButtonEdgeLeftGreen"), forState: .Normal)
                buttonsArray[startIndex].timeState = .Edge
            }
            
            if contains(leftEdgeIndexes, endIndex) {
                buttonsArray[endIndex].timeState = .Single
            } else {
                buttonsArray[endIndex].setBackgroundImage(UIImage(named: "ButtonEdgeRightGreen"), forState: .Normal)
                buttonsArray[endIndex].timeState = .Edge
            }
            
            // make paths
            for i in startIndex+1..<endIndex {
                if contains(leftEdgeIndexes, i) {   // left edges
                    buttonsArray[i].timeState = .Path
                    buttonsArray[i].setBackgroundImage(UIImage(named: "ButtonEdgeLeftGreen"), forState: .Normal)
                    buttonsArray[i].backgroundColor = UIColor.clearColor()
                } else if contains(rightEdgeIndexes, i) {   // right edges
                    buttonsArray[i].timeState = .Path
                    buttonsArray[i].setBackgroundImage(UIImage(named: "ButtonEdgeRightGreen"), forState: .Normal)
                    buttonsArray[i].backgroundColor = UIColor.clearColor()
                } else {    // non edge
                    buttonsArray[i].timeState = .Path
                }
            }
            
            // handle neighboring edges
            if endIndex - startIndex == 1 && buttonsArray[startIndex].timeState == TimeDisplayButton.TimeDisplayState.Edge && buttonsArray[endIndex].timeState == TimeDisplayButton.TimeDisplayState.Edge {
                var fillerRect = UIView(frame: CGRectMake(buttonsArray[startIndex].frame.origin.x+BUTTON_SIZE, buttonsArray[startIndex].frame.origin.y, spacing-BUTTON_SIZE, BUTTON_SIZE))
                fillerRect.tag = 15
                fillerRect.backgroundColor = greenColor
                view.addSubview(fillerRect)
            }
            
            // endIndex is the left handle
        } else if endIndex < startIndex {
            
            if contains(rightEdgeIndexes, endIndex) {
                buttonsArray[endIndex].timeState = .Single
            } else {
                buttonsArray[endIndex].setBackgroundImage(UIImage(named: "ButtonEdgeLeft"), forState: .Normal)
                buttonsArray[endIndex].timeState = .Edge
            }
            
            if contains(leftEdgeIndexes, startIndex) {
                buttonsArray[startIndex].timeState = .Single
            } else {
                buttonsArray[startIndex].setBackgroundImage(UIImage(named: "ButtonEdgeRight"), forState: .Normal)
                buttonsArray[startIndex].timeState = .Edge
            }
            
            // make paths
            for i in endIndex+1..<startIndex {
                if contains(leftEdgeIndexes, i) {   // left edges
                    buttonsArray[i].timeState = .Path
                    buttonsArray[i].setBackgroundImage(UIImage(named: "ButtonEdgeLeft"), forState: .Normal)
                    buttonsArray[i].backgroundColor = UIColor.clearColor()
                } else if contains(rightEdgeIndexes, i) {   // right edges
                    buttonsArray[i].timeState = .Path
                    buttonsArray[i].setBackgroundImage(UIImage(named: "ButtonEdgeRight"), forState: .Normal)
                    buttonsArray[i].backgroundColor = UIColor.clearColor()
                } else {    // non edges
                    buttonsArray[i].timeState = .Path
                }
            }
        } else { // start and end are the same
            buttonsArray[startIndex].timeState = .Single
        }
    }
    
    
    func isNeighboringTimeslot(lhs: Timeslot, rhs: Timeslot) -> Bool {
        if abs(fromTimeToIndex(lhs) - fromTimeToIndex(rhs)) == 1 {
            return true
        } else {
            return false
        }
    }
    
    func clearView() {
        buttonsArray.removeAll(keepCapacity: true)
        
        for subview in self.view.subviews {
            if subview is UIButton || subview.tag == 15 || subview is UIImageView || subview is UILabel {
                subview.removeFromSuperview()
            }
        }
    }
    
    func loadButtons() {
        
        // Load buttons from timeslots
        var currentY: CGFloat = UIApplication.sharedApplication().statusBarFrame.height
        var currentX: CGFloat = 8
        var elementsInRow = 0
        
        var updateCoordinates = { () -> () in
            elementsInRow++
            // if row is filled up
            if elementsInRow == 6 {
                currentY = currentY + CGFloat(self.BUTTON_SIZE+10)
                currentX = 8
                elementsInRow = 0
            } else {
                currentX = currentX + self.spacing
            }
        }
        
        for hour in 0...23 {
            var newButton: TimeDisplayButton!
            if hour < 9 {
                newButton = buildTimeButton("0\(hour):00", atX: currentX, atY: currentY)
            } else {
                newButton = buildTimeButton("\(hour):00", atX: currentX, atY: currentY)
            }
            self.view.addSubview(newButton)
            buttonsArray.append(newButton)
            updateCoordinates()
            
            
            if hour < 9 {
                newButton = buildTimeButton("0\(hour):30", atX: currentX, atY: currentY)
            } else {
                newButton = buildTimeButton("\(hour):30", atX: currentX, atY: currentY)
            }
            self.view.addSubview(newButton)
            buttonsArray.append(newButton)
            updateCoordinates()
        }
        
    }
    
    
    
    func buildTimeButton(withTitle: String, atX x: CGFloat, atY y: CGFloat) -> TimeDisplayButton {
        
        var newButton = TimeDisplayButton(frame: CGRectMake(x, y, CGFloat(BUTTON_SIZE), CGFloat(BUTTON_SIZE)))
        newButton.spacing = self.spacing
        newButton.backgroundColor = UIColor.whiteColor()
        newButton.layer.borderWidth = 1.5
        newButton.layer.borderColor = buttonColor.CGColor
        newButton.layer.cornerRadius = 0.5 * newButton.frame.size.width
        newButton.setTitle(withTitle, forState: UIControlState.Normal)
        
        var fontSize: CGFloat = 0
        let screenHeight = UIScreen.mainScreen().bounds.height
        switch screenHeight {
        case 480:
            fontSize = 16
        case 568:
            fontSize = 16
        case 667:
            fontSize = 19
        case 736:
            fontSize = 20
        default:
            fontSize = 16
        }
        
        if fromTimeToIndex(time: withTitle) % 2 == 0 {
            newButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        } else {
            newButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: fontSize)
        }
        newButton.setTitleColor(buttonColor, forState: UIControlState.Normal)
        
        newButton.userInteractionEnabled = false
        
        return newButton
    }
    
    
    func fromTimeToIndex(#time: String) -> Int {
        var timeArray = time.componentsSeparatedByString(":")
        
        let hour = Int(timeArray[0].toInt()!)
        let minute = Int(timeArray[1].toInt()!)
        
        if minute != 0 {
            return hour*2 + 1
        } else {
            return hour*2
        }
    }
    
    
    func fromTimeToIndex(timeslot: Timeslot) -> Int {
        return fromTimeToIndex(time: timeslot.stringDescription())
    }
}
























