//
//  GroupDisplayViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 7/28/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

class GroupDisplayViewController: UIViewController, MemberFilterTableViewControllerDelegate, TimeDisplayViewControllerDataSource {
    
    var timeDisplayController: TimeDisplayViewController!
    var currentGroup: Group?
    var timeslots = [Timeslot]()
    var selectedUsers: [PFUser]!
    
    @IBOutlet weak var selectTimesButton: UIButton!
    @IBOutlet weak var membersButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = currentGroup?.name
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // setup button designs
        setUpButtons()
        
        selectedUsers = currentGroup?.users
        loadTimeslots()
    }
    
    func setUpButtons() {
        let highlightedColor = UIColor(red: 220/255, green: 221/255, blue: 247/255, alpha: 1.0)
        selectTimesButton.backgroundColor = blueColor
        selectTimesButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        selectTimesButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        selectTimesButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 13)
        selectTimesButton.setBackgroundColor(highlightedColor, forUIControlState: UIControlState.Highlighted)
        
        membersButton.backgroundColor = blueColor
        membersButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        membersButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        membersButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 13)
        membersButton.setBackgroundColor(highlightedColor, forUIControlState: .Highlighted)
        
        // mini divisor
        var divisor = CALayer()
        divisor.frame = CGRectMake(0, membersButton.frame.height/4, 1, membersButton.frame.height/2)
        divisor.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).CGColor
        membersButton.layer.addSublayer(divisor)
    }
    
    
    func loadTimeslots() {
        var timeQuery = Timeslot.query()
        timeQuery?.whereKey("group", equalTo: currentGroup!)
        
        timeQuery?.findObjectsInBackgroundWithBlock { objects, error in
            if let timeslots = objects as? [Timeslot] {
                self.timeslots = self.matchTimeslots(timeslots, forUsers: self.selectedUsers)
                self.timeslots.sort({$0 < $1})
                self.timeDisplayController.reloadDisplay()
                    println("=============")
                for timeslot in self.timeslots {
                    println(timeslot.stringDescription())
                }
            }
        }
    }
    
    // How this works: initialize separate arrays of timeslots for their respective user and put them in an array of arrays
    // find intersection among all arrays
    func matchTimeslots(timeslots: [Timeslot], forUsers users: [PFUser]) -> [Timeslot] {
        if users.count == 0 {
            return [Timeslot]()
        }
        
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
    
    func didFinishFilteringUsers(selectedUsers: [PFUser]) {
        self.selectedUsers = selectedUsers
        loadTimeslots()
    }
    
    func timeslotsForDisplay() -> [Timeslot] {
        return self.timeslots
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectTimeSegue" {
            let destinationController = segue.destinationViewController as! SelectTimeViewController
            destinationController.currentGroup = self.currentGroup
        } else if segue.identifier == "FilterSegue" {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let destinationController = destinationNavigationController.topViewController as! MemberFilterTableViewController
            
            destinationController.users = currentGroup?.users
            destinationController.selectedUsers = self.selectedUsers
            destinationController.delegate = self
        } else if segue.identifier == "TimeDisplaySegue" {
            let destinationController = segue.destinationViewController as! TimeDisplayViewController
            timeDisplayController = destinationController
            destinationController.dataSource = self
        } else if segue.identifier == "MembersSegue" {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let destinationController = destinationNavigationController.topViewController as! MembersTableViewController
            
            destinationController.currentGroup = self.currentGroup
        }
    }
    

}

extension UIButton {
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func setBackgroundColor(color: UIColor, forUIControlState state: UIControlState) {
        self.setBackgroundImage(imageWithColor(color), forState: state)
    }
    
    public override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        
        var inside = super.pointInside(point, withEvent: event)
        
        if inside != highlighted && event?.type == .Touches {
            highlighted = inside
        }
        
        return inside
        
    }
}

/*
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
*/















