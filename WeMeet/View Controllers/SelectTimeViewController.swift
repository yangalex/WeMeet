//
//  SelectTimeViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 7/29/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol SelectTimeViewControllerDelegate {
    func didFinishUpdatingTimeslots(success: Bool)
}

class SelectTimeViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    var delegate: SelectTimeViewControllerDelegate?
    var timeGrid: TimeGridViewController!
    var currentGroup: Group?
    var selectedTimeslots: [Timeslot]!
    
    var saveSuccess: Bool?
    var deleteSuccess: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCurrentUserTimeslots()
    }
    
    func loadCurrentUserTimeslots() {
        SVProgressHUD.show()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        var timeQuery = Timeslot.query()
        timeQuery?.whereKey("user", equalTo: PFUser.currentUser()!)
        timeQuery?.whereKey("group", equalTo: currentGroup!)
        timeQuery?.findObjectsInBackgroundWithBlock { objects, error in
            if error == nil {
                if let timeslots = objects as? [Timeslot] {
                    self.selectedTimeslots = timeslots
                    self.selectedTimeslots.sort({$0 < $1})
                }
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
                AlertControllerHelper.displayErrorController(self.presentingViewController!, withMessage: "Unable to retrieve timeslots")
            }
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            SVProgressHUD.dismiss()
        }
    }
    

    @IBAction func donePressed(sender: AnyObject) {
        // todo: modify function so it doesn't append a timeslot that was already in the selectedtimeslots
        // and removes any that are not in the selected timeslots anymore
        var updatedSelectedTimeslots = [Timeslot]()
        for button in timeGrid.view.subviews {
            if let timeButton = button as? TimeButton {
                if timeButton.selected == true {
                    let newTimeslot = Timeslot.fromString(timeButton.titleLabel!.text!)
                    newTimeslot.user = PFUser.currentUser()!
                    newTimeslot.group = currentGroup!
                    updatedSelectedTimeslots.append(newTimeslot)
                }
            }
        }
        
        self.saveTimeslots(updatedSelectedTimeslots)
    }
    
    func saveTimeslots(updatedTimeslots: [Timeslot]) {
        SVProgressHUD.showWithStatus("Saving")
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        // remove timeslots that are now unselected
        var deletedTimeslots = [Timeslot]()
        for timeslot in selectedTimeslots {
            if !contains(updatedTimeslots, timeslot) {
                deletedTimeslots.append(timeslot)
            }
        }
       
        // add any new timeslot
        var newTimeslots = [Timeslot]()
        for timeslot in updatedTimeslots {
            if !contains(selectedTimeslots, timeslot) {
                newTimeslots.append(timeslot)
            }
        }
        
        // asynchronously delete and save
        PFObject.deleteAllInBackground(deletedTimeslots) { success, error in
            if success {
                PFObject.saveAllInBackground(newTimeslots) { success, error in
                    if success {
                        SVProgressHUD.showSuccessWithStatus("Saved timeslots")
                        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "dismissAfterUpdating:", userInfo: true, repeats: false)
                    } else {
                        SVProgressHUD.showErrorWithStatus("Failed to save time")
                        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "dismissAfterUpdating:", userInfo: false, repeats: false)
                    }
                    
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                }
            } else {
                SVProgressHUD.showErrorWithStatus("Failed to update time")
                NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "dismissAfterUpdating:", userInfo: false, repeats: false)
                
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
            
        }
    }
   
    func dismissAfterUpdating(timer: NSTimer) {
        dismissViewControllerAnimated(true, completion: nil)
        let success = timer.userInfo as? Bool
        self.delegate?.didFinishUpdatingTimeslots(success!)
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
