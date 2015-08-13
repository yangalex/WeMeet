//
//  HomeTableViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 7/13/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController, NewGroupViewControllerDelegate {

    @IBOutlet weak var newGroupButton: UIBarButtonItem!
    
    var groups: [Group] = [Group]()
    
    var currentGroup: Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        loadGroups()
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateGroupSegue" {
            let destinationController = segue.destinationViewController as! NewGroupViewController
            destinationController.delegate = self
        } else if segue.identifier == "DatesSegue" {
            let destinationController = segue.destinationViewController as! DatesTableViewController
            destinationController.currentGroup = self.currentGroup
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
        performSegueWithIdentifier("DatesSegue", sender: self)
    }
 
}
