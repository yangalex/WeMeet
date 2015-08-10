//
//  SignUpViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/10/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
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
       
        nameTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func setUpButton() {
        signUpButton.backgroundColor = UIColor.whiteColor()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == nameTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // check if username is valid
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
