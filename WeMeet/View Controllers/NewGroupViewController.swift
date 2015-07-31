//
//  NewGroupViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 7/27/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

protocol NewGroupViewControllerDelegate {
    func didFinishSavingGroup(newGroup: Group)
}

class NewGroupViewController: UIViewController {

    @IBOutlet weak var groupNameTextField: UITextField!
    var delegate: NewGroupViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set groupNameTextField borders
        setupGroupNameTextField()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupGroupNameTextField() {
        let borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1.0)
        var bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0, groupNameTextField.frame.height-1, groupNameTextField.frame.width, 1.0)
        bottomBorder.backgroundColor = borderColor.CGColor
        groupNameTextField.layer.addSublayer(bottomBorder)
        var topBorder = CALayer()
        topBorder.frame = CGRectMake(0, 0, groupNameTextField.frame.width, 1.0)
        topBorder.backgroundColor = borderColor.CGColor
        groupNameTextField.layer.addSublayer(topBorder)
        
    }
    
    @IBAction func createButtonPressed(sender: UIBarButtonItem) {
        if groupNameTextField.text != "" {
            var newGroup = Group(name: groupNameTextField.text)
            newGroup.users.append(PFUser.currentUser()!)
            newGroup.saveInBackgroundWithBlock { success, error in
                if success {
//                    println("Successfully saved new group")
                    self.delegate?.didFinishSavingGroup(newGroup)
                } else {
                    println("\(error?.localizedDescription)")
                }
            }
            
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            let errorController = UIAlertController(title: "Invalid Group Name", message: "Group name text field cannot be empty", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            errorController.addAction(okAction)
            self.presentViewController(errorController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
