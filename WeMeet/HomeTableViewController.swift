//
//  HomeTableViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 7/13/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class HomeTableViewController: UITableViewController, NewGroupViewControllerDelegate, ProfileViewControllerDelegate {

    @IBOutlet weak var newGroupButton: UIBarButtonItem!
    
    var groups: [Group] = [Group]()
    
    var currentGroup: Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        
        self.navigationItem.hidesBackButton = true
        
        loadGroups()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        loadGroups()
    }

    func loadGroups() {
        // Query user's groups
        var groupQuery = Group.query()!
        if let currentUser = PFUser.currentUser() {
            groupQuery = groupQuery.whereKey("users", equalTo: PFUser.currentUser()!)
            
            groupQuery.findObjectsInBackgroundWithBlock { objects, error in
                if let objects = objects as? [Group] {
                    self.groups = objects
                    self.tableView.reloadData()
                }
                
            }
        } else {
            println("current user not found")
        }
    }
    
    
    func didFinishSavingGroup(newGroup: Group) {
        // display alert controller with group id
        let idAlert = UIAlertController(title: "Success", message: "Your group ID is: \(newGroup.uniqueId)\nShare it with your other group members!", preferredStyle: .Alert)
        idAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
           self.presentViewController(idAlert, animated: true, completion: nil)

        loadGroups()
    }
    
    
    func logout() {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            // check if is rootviewcontroller
            if self.navigationController?.viewControllers.count == 1  {
                let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let loginController = storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                
                self.navigationController!.setViewControllers([loginController], animated: false)
 
            } else {
                self.navigationController?.popToRootViewControllerAnimated(true);
            }
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateGroupSegue" {
            let destinationController = segue.destinationViewController as! NewGroupViewController
            destinationController.delegate = self
        } else if segue.identifier == "DatesSegue2" {
            let destinationController = segue.destinationViewController as! DatesViewController
            destinationController.currentGroup = self.currentGroup
        } else if segue.identifier == "ProfileSegue" {
            let destinationController = segue.destinationViewController as! ProfileViewController
            destinationController.delegate = self
        }
    }
}


extension HomeTableViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroupCell", forIndexPath: indexPath) as! UITableViewCell
        
        if groups.count != 0 {
            cell.textLabel!.text = groups[indexPath.row].name
            cell.textLabel!.textColor = UIColor(red: 116/255, green: 116/255, blue: 116/255, alpha: 1.0)
            cell.textLabel!.font = UIFont(name: "Helvetica", size: 20)
            cell.detailTextLabel?.text = String(groups[indexPath.row].users.count) + " Members"
            cell.detailTextLabel?.font = UIFont(name: "Helvetica", size: 14)
            cell.detailTextLabel?.textColor = UIColor(red: 162/255, green: 153/255, blue: 153/255, alpha: 1.0)
        }
        return cell
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let tempGroup = groups[indexPath.row]
            tempGroup.deleteInBackground()
            groups.removeAtIndex(indexPath.row)
            tableView.reloadData()
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentGroup = groups[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("DatesSegue2", sender: self)
    }

 
}


extension HomeTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "SadFace")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No Groups"
        var attrs = [NSFontAttributeName : UIFont.systemFontOfSize(20)]
        var attributedString = NSAttributedString(string: text, attributes: attrs)
        return attributedString
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Press the '+' button to start creating groups"
        var attrs = [NSFontAttributeName : UIFont.systemFontOfSize(15)]
        var attributedString = NSAttributedString(string: text, attributes: attrs)
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

