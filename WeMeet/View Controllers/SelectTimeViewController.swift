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
    
    var timeGrid: TimeGridViewController!
    var currentGroup: Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TimeGridSegue" {
            timeGrid = segue.destinationViewController as! TimeGridViewController
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
