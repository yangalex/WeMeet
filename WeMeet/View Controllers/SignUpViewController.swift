//
//  SignUpViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/10/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit
import SVProgressHUD

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var checkImageView: UIImageView!
    
    var usernameOK: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "viewTapped")
        self.view.addGestureRecognizer(tapGesture)
        
        setUpTextFields()
        setUpButton()
    }
    
    func viewTapped() {
        if nameTextField.isFirstResponder() {
            nameTextField.resignFirstResponder()
        } else if usernameTextField.isFirstResponder() {
            usernameTextField.resignFirstResponder()
        } else if passwordTextField.isFirstResponder() {
            passwordTextField.resignFirstResponder()
        }
    }
    
    func setUpTextFields() {
        var nameBottomBorder = CALayer()
        nameBottomBorder.frame = CGRectMake(0, nameTextField.frame.height-1, nameTextField.frame.width, 1.0)
        nameBottomBorder.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).CGColor
        nameTextField.layer.addSublayer(nameBottomBorder)
        
        var usernameBottomBorder = CALayer()
        usernameBottomBorder.frame = CGRectMake(0, usernameTextField.frame.height-1, usernameTextField.frame.width, 1.0)
        usernameBottomBorder.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).CGColor
        usernameTextField.layer.addSublayer(usernameBottomBorder)
        
        nameTextField.tintColor = UIColor.whiteColor()
        usernameTextField.tintColor = UIColor.whiteColor()
        passwordTextField.tintColor = UIColor.whiteColor()
        
        usernameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
       
        nameTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func setUpButton() {
        signUpButton.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func signUpPressed(sender: UIButton) {
        if usernameOK == false {
            let errorController = UIAlertController(title: "Invalid username", message: "The username is already taken", preferredStyle: .Alert)
            errorController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(errorController, animated: true, completion: nil)
        } else {
            if count(passwordTextField.text) < 6 {
                let errorController = UIAlertController(title: "Invalid password", message: "Password should be at least 6 characters long", preferredStyle: .Alert)
                errorController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(errorController, animated: true, completion: nil)
            } else if count(nameTextField.text) == 0 {
                let errorController = UIAlertController(title: "Empty name", message: "Please enter a name", preferredStyle: .Alert)
                errorController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(errorController, animated: true, completion: nil)
            } else {
                // signup new user with given information
                let newUser = PFUser()
                newUser.username = usernameTextField.text.lowercaseString
                newUser.password = passwordTextField.text
                newUser.setObject(nameTextField.text, forKey: "name")
                
                SVProgressHUD.show()
                newUser.signUpInBackgroundWithBlock { success, error in
                    if success {
                        PFUser.logInWithUsernameInBackground(newUser.username!, password: newUser.password!) { user, error in
                            if error == nil {
                                self.performSegueWithIdentifier("VerifyPhoneSegue", sender: nil)
                            } else {
                                AlertControllerHelper.displayErrorController(self, withMessage: error!.localizedDescription)
                            }
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        if error != nil {
                            AlertControllerHelper.displayErrorController(self, withMessage: error!.localizedDescription)
                        }
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == nameTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidChange(sender: UITextField) {
        if sender == usernameTextField {
            parseCheckUsername(sender.text.lowercaseString)
        }
    }
    
    func parseCheckUsername(username: String) {
        if username == "" {
            self.checkImageView.hidden = true
            usernameOK = false
            return
        }
        let userQuery = PFUser.query()
        userQuery?.whereKey("username", equalTo: username)
        userQuery?.findObjectsInBackgroundWithBlock { objects, error in
            if let users = objects as? [PFUser] {
                if users.count == 0 {
                    self.checkImageView.hidden = false
                    self.checkImageView.image = UIImage(named: "Check")
                    self.usernameOK = true
                } else {
                    self.checkImageView.hidden = false
                    self.checkImageView.image = UIImage(named: "X")
                    self.usernameOK = false
                }
            }
            
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
