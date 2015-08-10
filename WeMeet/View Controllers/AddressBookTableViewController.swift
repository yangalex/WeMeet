//
//  AddressBookTableViewController.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/7/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit
import APAddressBook
import SVProgressHUD

class AddressBookTableViewController: UITableViewController, ContactCellDelegate {
    
    let addressBook = APAddressBook()
    var contactsArray: [APContact]!
    var phoneMask: [String] = [String]()
    
    var currentGroup: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.allowsSelection = false
        
        loadAddressBook()
    }
    
    func loadAddressBook() {
        addressBook.fieldsMask = APContactField.Default
        addressBook.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true), NSSortDescriptor(key: "lastName", ascending: true)]
        
        self.addressBook.filterBlock = {(contact: APContact!) -> Bool in
            return contact.phones.count > 0
        }
        
        
        addressBook.loadContacts { (contacts: [AnyObject]!, error: NSError!) in
            if contacts != nil {
                let contacts = contacts as! [APContact]
                self.filterForUsers(contacts)
            }
        }
 
    }

    func filterForUsers(contacts: [APContact]!) {
        // initialize new array
        var filteredContacts = [APContact]()
        // get query of users
        let userQuery = PFUser.query()
        userQuery?.cachePolicy = .CacheElseNetwork
        SVProgressHUD.show()
        userQuery?.findObjectsInBackgroundWithBlock { objects, error in
            if let users = objects as? [PFUser] {
                
                let userPhoneNumbers: [String] = users.map {
                     $0.objectForKey("phone") as! String
                }
                
                for contact in contacts {
                    let phonesArray = contact.phones as! [String]
                    
                    // iterate through phones array
                    for phoneNumber in phonesArray {
                        // format phone string
                        let phoneString = self.cleanPhoneString(phoneNumber)
                        if contains(userPhoneNumbers, phoneString) {
                            filteredContacts.append(contact)
                            self.phoneMask.append(phoneString)
                            break
                        }
                    }
                }
                
                // set contacts array and reload tableview
                self.contactsArray = filteredContacts
                self.tableView.reloadData()
            }
            SVProgressHUD.dismiss()
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
    
    func didPressAddButton(sender: ContactCell) {
        if sender.addButton.selected == false {
            sender.addButton.selected = true
            sender.addButton.setImage(UIImage(named: "CheckCell"), forState: .Selected)
            
            // get user that matches contact's phone
            let userQuery = PFUser.query()
            userQuery?.cachePolicy = .CacheElseNetwork
            userQuery?.whereKey("phone", equalTo: sender.contact.phone)
            userQuery?.findObjectsInBackgroundWithBlock { objects, error in
                if error != nil {
                    println("error getting user")
                } else {
                    let objects = objects as! [PFUser]
                    let user = objects[0]
                    
                    self.currentGroup.users.append(user)
                    self.currentGroup.saveInBackground()
                }
            }
        }
    }
    
}

extension AddressBookTableViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if contactsArray == nil {
            return 0
        } else {
            return contactsArray.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! ContactCell
        
        let tempContact = contactsArray[indexPath.row]
        
        // check if contact is already in group
        var contactAlreadyAdded: Bool = false
    
        for user in currentGroup.users {
            if phoneMask[indexPath.row] == user.objectForKey("phone") as! String {
                contactAlreadyAdded = true
                break
            }
        }
        
        // set name
        var fullName: String?
        if tempContact.firstName != nil && tempContact.lastName != nil {
            fullName = tempContact.firstName + " " + tempContact.lastName
        } else if tempContact.firstName == nil || tempContact.lastName == nil {
            fullName = (tempContact.firstName != nil) ? tempContact.firstName : tempContact.lastName
        }
        cell.nameLabel.text = fullName
        
        // set button appearance if contact is already in group
        if contactAlreadyAdded {
            cell.addButton.selected = true
            cell.addButton.setImage(UIImage(named: "CheckCell"), forState: .Normal)
        }
        
        
        cell.contact.name = fullName!
        cell.contact.phone = phoneMask[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
}


















