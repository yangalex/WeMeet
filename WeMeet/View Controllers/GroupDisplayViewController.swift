//
//  GroupDisplayViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 7/28/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

class GroupDisplayViewController: UIViewController {
    
    var currentGroup: Group?
    var timeslots = [Timeslot]()
    var users: [PFUser]!
    
    @IBOutlet weak var memberTableView: UITableView!
    @IBOutlet weak var selectTimesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = currentGroup?.name
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // setup table height
//        memberTableView.tableFooterView = UIView(frame: CGRectMake(0, 0, memberTableView.frame.width, 0))
        memberTableView.frame = CGRectMake(memberTableView.frame.origin.x, memberTableView.frame.origin.y, memberTableView.frame.size.width, memberTableView.rowHeight*CGFloat(currentGroup!.users.count))
        
        // setup button design
        selectTimesButton.backgroundColor = UIColor(red: 86/255, green: 212/255, blue: 243/255, alpha: 1.0)
        selectTimesButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        selectTimesButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 18)
        
        memberTableView.dataSource = self
        memberTableView.delegate = self
        users = currentGroup?.users
        
        
        loadTimeslots()
        
    }
    
    
    func loadTimeslots() {
        var timeQuery = Timeslot.query()
        timeQuery?.whereKey("group", equalTo: currentGroup!)
        
        timeQuery?.findObjectsInBackgroundWithBlock { objects, error in
            if let timeslots = objects as? [Timeslot] {
                self.timeslots = self.matchTimeslots(timeslots, forUsers: self.currentGroup!.users)
                for timeslot in self.timeslots {
                    println(timeslot.stringDescription())
                }
            }
            
        }
    }
    
    func matchTimeslots(timeslots: [Timeslot], forUsers users: [PFUser]) -> [Timeslot] {
        var userArrays: [[Timeslot]] = [[Timeslot]]()
        for user in users {
            var tempUserArray = timeslots.filter({$0.user.username == user.username})
            userArrays.append(tempUserArray)
            
        }
        // intialize intersection with first array
        var matchedTimeslots: [Timeslot] = userArrays[0]
        
        
        for i in 1..<userArrays.count {
            matchedTimeslots = intersectArrays(matchedTimeslots, secondArray: userArrays[i])
        }
        
        return matchedTimeslots
    }
    
    
    func intersectArrays(firstArray: [Timeslot], secondArray: [Timeslot]) -> [Timeslot] {
        
        var intersection = [Timeslot]()
        for i in 0..<firstArray.count {
            for j in 0..<secondArray.count {
                if firstArray[i].equalTo(secondArray[j]) {
                    intersection.append(firstArray[i])
                }
            }
        }
        
        return intersection
    }
    
    
    
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectTimeSegue" {
            let destinationController = segue.destinationViewController as! SelectTimeViewController
            destinationController.currentGroup = self.currentGroup
        }
    }
    

}

extension GroupDisplayViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return users.count+1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MemberCell") as! UITableViewCell
        
        if indexPath.row == users.count {
            cell.textLabel?.textColor = UIColor(red: 86/255, green: 212/255, blue: 243/255, alpha: 1.0)
            cell.textLabel?.text = "Add Member"
            return cell
        } else {
            var user = users[indexPath.row]
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.text = user.username
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Members"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == users.count {
            // Temporary alert controller to add member
            let alertController = UIAlertController(title: "Add Member", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addTextFieldWithConfigurationHandler { textField in
                textField.placeholder = "Name"
            }
            
            let doneAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default) { action in
                let nameTextField = alertController.textFields![0] as! UITextField
                
                // query for user
                var usersQuery = PFUser.query()!
                usersQuery.whereKey("username", equalTo: nameTextField.text)
                usersQuery.findObjectsInBackgroundWithBlock { results, error in
                    if let results = results as? [PFUser] {
                        // if user was not found
                        if results.count == 0 {
                            let errorController = UIAlertController(title: "Invalid Username", message: "This user does not exist", preferredStyle: .Alert)
                            errorController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                            self.presentViewController(errorController, animated: true, completion: nil)
                        } else {
                            
                            var userAlreadyInGroup: Bool = false
                            for user in self.currentGroup!.users {
                                if user.username == results[0].username {
                                    userAlreadyInGroup = true
                                }
                            }
                            
                            if userAlreadyInGroup {
                                let errorController = UIAlertController(title: "Inavlid User", message: "User is already in this group", preferredStyle: .Alert)
                                errorController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                                self.presentViewController(errorController, animated: true, completion: nil)
                            } else {
                                self.currentGroup?.users.append(results[0])
                                self.users = self.currentGroup?.users
                                self.currentGroup?.saveInBackground()
                                self.memberTableView.reloadData()
                            }
                        }
                        
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            alertController.addAction(doneAction)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            memberTableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        }
    }
}
















