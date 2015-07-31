//
//  SelectTimeViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 7/29/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

class SelectTimeViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    var timeGrid: TimeGridViewController!
    var currentGroup: Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // design done button
        doneButton.backgroundColor = UIColor(red: 86/255, green: 212/255, blue: 243/255, alpha: 1.0)
        doneButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
    }

    @IBAction func donePressed(sender: AnyObject) {
        var selectedTimeslots = [Timeslot]()
        for button in timeGrid.view.subviews {
            if let timeButton = button as? TimeButton {
                if timeButton.selected == true {
                    let newTimeslot = Timeslot.fromString(timeButton.titleLabel!.text!)
                    newTimeslot.user = PFUser.currentUser()!
                    newTimeslot.group = currentGroup!
                    selectedTimeslots.append(newTimeslot)
                }
            }
        }
        
        self.saveTimeslots(selectedTimeslots)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveTimeslots(timeslots: [Timeslot]) {
        for timeslot in timeslots {
            timeslot.saveInBackgroundWithBlock { success, error in
                if success {
                } else {
                    println("\(error?.localizedDescription)")
                }
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TimeGridSegue" {
            timeGrid = segue.destinationViewController as! TimeGridViewController
        }
    }

}
