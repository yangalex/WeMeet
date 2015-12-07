//
//  AppDelegate.swift
//  WeMeet
//
//  Created by Alexandre Yang on 7/13/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit
import Parse
import Bolts
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storyboard: UIStoryboard?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // set status bar and navigation bar styles for app
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "NavBackground"), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        
        SVProgressHUD.setForegroundColor(blueColor)
        
        Parse.setApplicationId("Qxt2lgULCKkQyBdvTRP2LPcPRzfzUZnTYjCY7txF", clientKey:"wOSYQC2Lcrc4dOZLKR91VdYMzugT5qWNJtLL02Hp")
        PFUser.enableRevocableSessionInBackground()
        
        
        if PFUser.currentUser() != nil {
            if PFUser.currentUser()!.isAuthenticated() {
                storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let homeController = storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeTableViewController
                
                let navigationController = self.window?.rootViewController as! UINavigationController
                navigationController.setViewControllers([homeController], animated: true)
            }
        } else {
            storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let loginController = storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            
            let navigationController = self.window?.rootViewController as! UINavigationController
            navigationController.setViewControllers([loginController], animated: true)
        }
        
    
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

