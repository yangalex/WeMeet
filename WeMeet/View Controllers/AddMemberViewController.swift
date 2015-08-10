//
//  AddMemberViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/5/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

class AddMemberViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var currentGroup: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
   
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ByUsernameSegue" {
            let destinationController = segue.destinationViewController as! ByUsernameViewController
            destinationController.currentGroup = self.currentGroup
        } else if segue.identifier == "ShowAddressBookSegue" {
            let destinationController = segue.destinationViewController as! AddressBookTableViewController
            destinationController.currentGroup = self.currentGroup
        }
    }

}

extension AddMemberViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddMemberCell", forIndexPath: indexPath) as! UITableViewCell
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Add by Username"
            cell.imageView?.image = UIImage(named: "Search")
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Add from Address Book"
            cell.imageView?.image = UIImage(named: "Book")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // add by username
        if indexPath.row == 0 {
            performSegueWithIdentifier("ByUsernameSegue", sender: self)
        } else if indexPath.row == 1 {    // Add from address book
            performSegueWithIdentifier("ShowAddressBookSegue", sender: self)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}












