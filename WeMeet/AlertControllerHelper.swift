//
//  AlertControllerHelper.swift
//  WeMeet
//
//  Created by Alexandre Yang on 8/6/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import Foundation

class AlertControllerHelper {
    static func displayErrorController(controller: UIViewController, withMessage message: String) {
        let errorController = UIAlertController(title: "Error", message: message , preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        errorController.addAction(okAction)
        
        controller.presentViewController(errorController, animated: true, completion: nil)
        }
}