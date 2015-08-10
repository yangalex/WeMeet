//
//  ContactCell.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/8/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit
import APAddressBook

class ContactUser {
    
    var username: String = ""
    var name: String = ""
    var phone: String = ""
    
    
}

protocol ContactCellDelegate {
    func didPressAddButton(sender: ContactCell)
}

class ContactCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    
    var delegate: ContactCellDelegate?
    var contact: ContactUser = ContactUser()
    
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        delegate?.didPressAddButton(self)
    }
}
