//
//  AppDelegate.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 08/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import Parse
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Register parse subclasses
        MqolUser.registerSubclass()
        Study.registerSubclass()
        StudyUser.registerSubclass()
        Survey.registerSubclass()
        SurveyTrigger.registerSubclass()
        Peer.registerSubclass()
        
        // Initializing call to the Parse server
        let parseConfig = ParseClientConfiguration {
            $0.isLocalDatastoreEnabled = true
            $0.applicationId = "mQoL-app-dev"
            $0.server = "https://qol1.unige.ch/mqol-parse-dev/"
        }
        Parse.initialize(with: parseConfig)
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        // Checks preferred language list from device
        let prefferedLan = NSLocale.preferredLanguages[0]
        if prefferedLan.prefix(2) == "fr" {
            UserDefaults.standard.set("fr", forKey: "language")
        }
        else {
            UserDefaults.standard.set("en", forKey: "language")
        }        
        
        //Setting this class as UserNotificationCenter delegate, so we are able to make custom actions for the notification
        UNUserNotificationCenter.current().delegate = self
        
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //Function that handles notifications when the app is background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        let id = response.notification.request.identifier
        let survey : String = response.notification.request.content.userInfo["survey"] as! String
        
        UserDefaults.standard.set(true, forKey: "fireNotificationSurvey")
        UserDefaults.standard.set(survey, forKey: "surveyToFire")
        
        print("Received notification with ID = \(id)")
        print("The survey is: \(survey)")
        
        Switcher.updateRootVC()
        
        completionHandler()
    }
    
    //Function that handles notifications when the app is running
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let id = notification.request.identifier
        print("Received notification with ID = \(id)")
        
        completionHandler([.sound, .alert])
    }
}

