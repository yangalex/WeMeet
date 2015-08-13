//
//  DatesTableViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/13/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit
import SVProgressHUD

class DatesTableViewController: UITableViewController, NewDateViewControllerDelegate {
    
    var currentGroup: Group!
    var dates = [TimeDate]()
    var timeslots: [Timeslot] = [Timeslot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        
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
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
