//
//  DatesTableViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/13/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit
import SVProgressHUD
import DZNEmptyDataSet

class DatesTableViewController: UITableViewController, NewDateViewControllerDelegate {
    
    var currentGroup: Group!
    var currentDate: TimeDate!
    var selectedWeekDay: String!
    var dates = [TimeDate]()
    var timeslots: [Timeslot] = [Timeslot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

    
    func addDate(sender: UIBarButtonItem) {
        performSegueWithIdentifier("NewDateSegue", sender: nil)
    }
    
    func didFinishAddingDate() {
        loadDates()
    }
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NewDateSegue" {
            let destinationController = segue.destinationViewController as! NewDateViewController
            destinationController.currentGroup = self.currentGroup
            destinationController.delegate = self
            destinationController.existingDates = dates
        } else if segue.identifier == "GroupDisplaySegue" {
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentGroup.dayOfWeekOnly {
            return 7
        } else {
            return dates.count
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if currentGroup.dayOfWeekOnly {
            return self.view.frame.height/7
        } else {
            return 60
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}


extension DatesTableViewController : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
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

















