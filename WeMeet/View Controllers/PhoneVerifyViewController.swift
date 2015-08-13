//
//  PhoneVerifyViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/10/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

class PhoneVerifyViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var sendVerificationButton: UIButton!
    @IBOutlet weak var verificationCodeTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneTextFieldConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        setupTextField()
        setupButton()
        // Do any additional setup after loading the view.
    }
    
    func setupTextField() {
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5).CGColor 
        bottomBorder.frame = CGRectMake(0, phoneTextField.frame.height-1, phoneTextField.frame.width, 1.0)
        phoneTextField.layer.addSublayer(bottomBorder)
        phoneTextField.tintColor = UIColor.whiteColor()
        phoneTextField.keyboardType = UIKeyboardType.PhonePad
        
        let verificationBottomBorder = CALayer()
        verificationBottomBorder.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5).CGColor
        verificationBottomBorder.frame = CGRectMake(0, verificationCodeTextField.frame.height-1, verificationCodeTextField.frame.width, 1.0)
        verificationCodeTextField.layer.addSublayer(verificationBottomBorder)
        verificationCodeTextField.tintColor = UIColor.whiteColor()
        verificationCodeTextField.keyboardType = UIKeyboardType.NumberPad
        
        phoneTextField.delegate = self
    }
    
    func setupButton() {
        sendVerificationButton.backgroundColor = UIColor.whiteColor()
    }

    
    @IBAction func sendPressed(sender: UIButton) {
        // horrible way of differentiating button state change, but whatever
        if sender.titleLabel?.text != "Verify" {
            if count(cleanPhoneString(phoneTextField.text!)) == 10 {
                PFCloud.callFunctionInBackground("sendVerificationCode", withParameters: ["phoneNumber" : phoneTextField.text]) {
                    (response: AnyObject?, error: NSError?) -> Void in
                    if error == nil {
                        let msg = response as! String
                        println(msg)
                    } else {
                        AlertControllerHelper.displayErrorController(self, withMessage: error!.localizedDescription)
                    }
                    
                    // update user to get verificationCode value
                    PFUser.currentUser()?.fetchInBackground()
                }
                
                self.view.layoutIfNeeded()
                verificationCodeTextField.hidden = false
                UIView.animateWithDuration(1.0) {
                    self.phoneTextFieldConstraint.constant = -600
                    self.verificationCodeTextFieldConstraint.constant = 0
                    self.verificationCodeTextField.becomeFirstResponder()
                    self.sendVerificationButton.setTitle("Verify", forState: .Normal)
                    self.view.layoutIfNeeded()
                }
            } else {
                AlertControllerHelper.displayErrorController(self, withMessage: "Invalid phone number")
            }
        } else {
            // check if verification code is right
            let currentUser = PFUser.currentUser()!
            let verificationCode = currentUser.objectForKey("phoneVerificationCode") as? Int
            if verificationCodeTextField.text! == String(verificationCode!) {
                PFUser.currentUser()?.setObject(phoneTextField.text, forKey: "phone")
                PFUser.currentUser()?.saveInBackground()
                performSegueWithIdentifier("VerifiedSuccessSegue", sender: nil)
            } else {
                AlertControllerHelper.displayErrorController(self, withMessage: "Wrong verification code")
            }
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField == phoneTextField
        {
            var newString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            var components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            var decimalString = "".join(components) as NSString
            var length = decimalString.length
            var hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                var newLength = (textField.text as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            var formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                var areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3
            {
                var prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            var remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            return false
        }
        else
        {
            return true
        }
    }
    
    
    func cleanPhoneString(phone: String) -> String {
        var phoneArray = map(phone) { String($0) }
        phoneArray = phoneArray.filter {
            if let num = $0.toInt() {
                return true
            } else {
                return false
            }
        }
        
        return "".join(phoneArray)
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
