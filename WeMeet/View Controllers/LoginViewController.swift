//
//  LoginViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/9/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // check if user is already logged in
//        if let user = PFUser.currentUser() {
//            if user.isAuthenticated() {
//                performSegueWithIdentifier("SignInSegue", sender: nil)
//            }
//        }
        
        let viewTapGesture = UITapGestureRecognizer(target: self, action: "dismissTextFields")
        viewTapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(viewTapGesture)
        
        setUpTextFields()
        setUpButton()

    }
    
    func dismissTextFields() {
        if usernameTextField.isFirstResponder() {
            usernameTextField.resignFirstResponder()
        } else if passwordTextField.isFirstResponder() {
            passwordTextField.resignFirstResponder()
        }
    }
    
    func setUpTextFields() {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0, usernameTextField.frame.height-1, usernameTextField.frame.width, 1.0)
        bottomBorder.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5).CGColor
        
        usernameTextField.tintColor = UIColor.whiteColor()
        passwordTextField.tintColor = UIColor.whiteColor()
        
        usernameTextField.layer.addSublayer(bottomBorder)
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func setUpButton() {
        loginButton.backgroundColor = UIColor.whiteColor()
        signUpButton.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func signInPressed(sender: UIButton) {
        let usernameText = usernameTextField.text
        let passwordText = passwordTextField.text
        
        PFUser.logInWithUsernameInBackground(usernameText, password: passwordText) { (user: PFUser?, error: NSError?) in
            if user != nil {
                self.performSegueWithIdentifier("SignInSegue", sender: nil)
            } else {
                AlertControllerHelper.displayErrorController(self, withMessage: "Invalid Login")
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            signInPressed(loginButton)
        }
        
        return true
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
