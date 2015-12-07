//
//  ProfileViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/20/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

protocol ProfileViewControllerDelegate {
    func logout()
}

class ProfileViewController: UIViewController {
    
    var delegate: ProfileViewControllerDelegate?
    var user: PFUser!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = PFUser.currentUser()
        setLabels()
    }
    
    func setLabels() {
        nameLabel.text = user.objectForKey("name") as? String
        usernameLabel.text = user.username
        phoneLabel.text = user.objectForKey("phone") as? String
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneClicked(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func logoutClicked(sender: UIBarButtonItem) {
        delegate?.logout()
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
