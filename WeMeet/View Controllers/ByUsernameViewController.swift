//
//  ByUsernameViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/5/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

class ByUsernameViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    var currentGroup: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupUsernameTextField()
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
 
    }
    
    func setupUsernameTextField() {
        let borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1.0)
        var bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0, usernameTextField.frame.height-1, usernameTextField.frame.width, 1.0)
        bottomBorder.backgroundColor = borderColor.CGColor
        usernameTextField.layer.addSublayer(bottomBorder)
        var topBorder = CALayer()
        topBorder.frame = CGRectMake(0, 0, usernameTextField.frame.width, 1.0)
        topBorder.backgroundColor = borderColor.CGColor
        usernameTextField.layer.addSublayer(topBorder)
        
        // set a left margin (can also be used for images later on
        let leftView = UIView(frame: CGRectMake(0, 0, 10, usernameTextField.frame.height))
        leftView.backgroundColor = usernameTextField.backgroundColor
        usernameTextField.leftView = leftView
        usernameTextField.leftViewMode = UITextFieldViewMode.Always
    }

    @IBAction func addPressed(sender: AnyObject) {
        var usersQuery = PFUser.query()!
        usersQuery.whereKey("username", equalTo: usernameTextField.text)
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
                        self.currentGroup?.saveInBackground()
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
                
            }
        }

    }

    @IBAction func cancelPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
