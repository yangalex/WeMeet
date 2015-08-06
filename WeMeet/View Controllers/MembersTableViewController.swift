//
//  MembersTableViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/4/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

class MembersTableViewController: UITableViewController {
    var currentGroup: Group!
    var users: [PFUser]!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        users = currentGroup?.users
        tableView.reloadData()
    }

    @IBAction func donePressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddMemberSegue" {
            let destinationController = segue.destinationViewController as! AddMemberViewController
            destinationController.currentGroup = self.currentGroup
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return users.count+1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemberCell", forIndexPath: indexPath) as! UITableViewCell
        
        if indexPath.row == users.count {
            cell.textLabel?.textColor = UIColor(red: 86/255, green: 212/255, blue: 243/255, alpha: 1.0)
            cell.textLabel?.text = "Add Member"
            return cell
        } else {
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.text = users[indexPath.row].username
            cell.selectionStyle = .None
            return cell
        }

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == users.count {
            // code to add member
            performSegueWithIdentifier("AddMemberSegue", sender: self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
