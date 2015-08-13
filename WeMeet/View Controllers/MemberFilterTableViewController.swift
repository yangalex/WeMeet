//
//  MemberFilterTableViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 7/31/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

protocol MemberFilterTableViewControllerDelegate {
    func didFinishFilteringUsers(selectedUsers: [PFUser])
}

class MemberFilterTableViewController: UITableViewController {
    
    var delegate: MemberFilterTableViewControllerDelegate?
    var users: [PFUser]!
    var selectedUsers: [PFUser]!

    override func viewDidLoad() {
        super.viewDidLoad()
        users.sort({$0.username < $1.username})
    }

    
    // MARK: - Table view data source
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemberCheckCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = users[indexPath.row].objectForKey("name") as? String ?? "[No name]"
        // check for selected users
        if contains(selectedUsers!, users[indexPath.row]) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell?.accessoryType == UITableViewCellAccessoryType.Checkmark {
            cell?.accessoryType = .None
            selectedUsers = selectedUsers.filter({$0 != self.users[indexPath.row]})
        } else if cell?.accessoryType == UITableViewCellAccessoryType.None {
            cell?.accessoryType = .Checkmark
            selectedUsers.append(users[indexPath.row])
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func donePressed(sender: UIBarButtonItem) {
        delegate?.didFinishFilteringUsers(self.selectedUsers)
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
