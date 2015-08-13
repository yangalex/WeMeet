//
//  NewDateViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/13/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol NewDateViewControllerDelegate {
    func didFinishAddingDate()
}

class NewDateViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var currentGroup: Group!
    var existingDates: [TimeDate]!
    var delegate: NewDateViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.minimumDate = NSDate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPressed(sender: AnyObject) {
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitYear, fromDate: datePicker.date)
        
        var newDate = TimeDate(year: components.year, month: components.month, day: components.day)
        newDate.group = self.currentGroup
        
        // First check if the date already exists
        if contains(existingDates, newDate) {
            AlertControllerHelper.displayErrorController(self, withMessage: "Date already exists!")
        } else {
            SVProgressHUD.show()
            newDate.saveInBackgroundWithBlock { success, error in
                SVProgressHUD.dismiss()
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.delegate?.didFinishAddingDate()
                } else {
                    AlertControllerHelper.displayErrorController(self, withMessage: "Oops, there was an error while adding date")
                }
            }
        }
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
