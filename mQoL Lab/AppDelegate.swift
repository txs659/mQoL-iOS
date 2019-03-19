//
//  AppDelegate.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 08/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import CoreData
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initializing call to the Parse server
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = "mQoL-app-dev"
            $0.server = "https://qol1.unige.ch/mqol-parse-dev/"
        }
        Parse.initialize(with: parseConfig)
        
        // Calls the cloud code to either login or create a user with the UUID
        PFCloud.callFunction(inBackground: "registerOrLoginUser", withParameters: ["google_ad_id":"testFromiOS"], block: { (object: Any?, error: Error?) in
            
            if error != nil {
                print ("An error orrcured!")
                print (error!)
            }
            
            if object != nil {
                print ("Login Successful")
                print (object!)

                if let user = PFUser.current() {
                    print (user)
                }
            }
        })
        
        // Creates a unique identifier for the device
        if let identifier = UIDevice.current.identifierForVendor?.uuidString {
            print (identifier)
        }
        
        // Decides what view to show the user
        Switcher.updateRootVC()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

