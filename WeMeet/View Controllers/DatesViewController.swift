//
//  DatesViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/14/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit
import SVProgressHUD
import DZNEmptyDataSet

class DatesViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewVerticalConstraint: NSLayoutConstraint!
    
    var currentGroup: Group!
    var currentDate: TimeDate!
    var selectedWeekDay: String!
    var dates = [TimeDate]()
//    var timeslots: [Timeslot] = [Timeslot]()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        setupButtons()
        setupNavigationBar()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        
        if currentGroup.dayOfWeekOnly {
            tableView.scrollEnabled = false
        }
        
        // handle case where group is specific dates type
        if currentGroup.dayOfWeekOnly == false {
            loadDates()
        }
        
        datePicker.minimumDate = NSDate()

    }
    
    func setupButtons() {
        addButton.backgroundColor = UIColor(red:0.31, green:0.83, blue:0.96, alpha:1)
        addButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        addButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)

    }
    
    func setupNavigationBar() {
        if !currentGroup.dayOfWeekOnly {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addDate:")
        }
        
        navigationItem.title = currentGroup.name
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
    }

    func loadDates() {
        let dateQuery = TimeDate.query()
        dateQuery?.whereKey("group", equalTo: currentGroup)
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        SVProgressHUD.show()
        dateQuery?.findObjectsInBackgroundWithBlock { objects, error in
            if error != nil {
                AlertControllerHelper.displayErrorController(self, withMessage: "Unable to retrieve dates!")
            } else {
                if let timeDates = objects as? [TimeDate] {
                    self.dates = timeDates
                    self.dates.sort({$0 < $1})
                    self.tableView.reloadData()
                }
            }
            
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            SVProgressHUD.dismiss()
        }
    }

    @IBAction func createDatePressed(sender: UIButton) {
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitYear, fromDate: datePicker.date)
        
        var newDate = TimeDate(year: components.year, month: components.month, day: components.day)
        newDate.group = self.currentGroup
        
        // First check if the date already exists
        if contains(dates, newDate) {
            AlertControllerHelper.displayErrorController(self, withMessage: "Date already exists!")
        } else {
            SVProgressHUD.show()
            newDate.saveInBackgroundWithBlock { success, error in
                SVProgressHUD.dismiss()
                if success {
                    self.view.layoutIfNeeded()
                    UIView.animateWithDuration(0.3) {
                        self.tableViewVerticalConstraint.constant = 0
                        self.view.layoutIfNeeded()
                    }

                    self.loadDates()
                } else {
                    AlertControllerHelper.displayErrorController(self, withMessage: "Oops, there was an error while adding date")
                }
            }
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addDate:")
 
    }
    
    
    func addDate(sender: UIBarButtonItem) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelAdding")
            
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.3) {
            self.tableViewVerticalConstraint.constant = self.datePicker.frame.height + self.addButton.frame.height
            self.tableView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
            self.tableView.layer.borderWidth = 1.0
            self.view.layoutIfNeeded()
        }
    }
    
    func cancelAdding() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addDate:")
        
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5) {
            self.tableViewVerticalConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GroupDisplaySegue" {
            let destinationController = segue.destinationViewController as! GroupDisplayViewController
            
            if currentGroup.dayOfWeekOnly {
                destinationController.weekday = self.selectedWeekDay
            } else {
                destinationController.timeDate = self.currentDate
            }
            
            destinationController.currentGroup = self.currentGroup
            destinationController.selectedUsers = currentGroup.users
        }
    }

}

extension DatesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentGroup.dayOfWeekOnly {
            return 7
        } else {
            return dates.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if currentGroup.dayOfWeekOnly {
            return self.view.frame.height/7
        } else {
            return 60
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DateCell", forIndexPath: indexPath) as! UITableViewCell
        
        if currentGroup.dayOfWeekOnly {
            switch indexPath.row {
            case 0:
                cell.textLabel!.text = "Monday"
            case 1:
                cell.textLabel!.text = "Tuesday"
            case 2:
                cell.textLabel!.text = "Wednesday"
            case 3:
                cell.textLabel!.text = "Thursday"
            case 4:
                cell.textLabel!.text = "Friday"
            case 5:
                cell.textLabel!.text = "Saturday"
            case 6:
                cell.textLabel!.text = "Sunday"
            default:
                cell.textLabel!.text = ""
            }
        } else {
            cell.textLabel!.text = dates[indexPath.row].stringDescription()
        }
        
        cell.textLabel!.textColor = UIColor(red: 116/255, green: 116/255, blue: 116/255, alpha: 1.0)
        cell.textLabel!.font = UIFont(name: "Helvetica", size: 20)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if currentGroup.dayOfWeekOnly == false {
            currentDate = dates[indexPath.row]
        } else {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                selectedWeekDay = cell.textLabel!.text!
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("GroupDisplaySegue", sender: nil)
    }
}

extension DatesViewController : DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "Calendar")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No Dates Available"
        let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(20)]
        let attributedString = NSAttributedString(string: text, attributes: attrs)
        return attributedString
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Press the '+' button to start adding some dates"
        let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(15)]
        let attributedString = NSAttributedString(string: text, attributes: attrs)
        return attributedString
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.whiteColor()
    }
    
    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowTouch(scrollView: UIScrollView!) -> Bool {
        return false
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return false
    }
}













