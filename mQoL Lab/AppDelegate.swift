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
            $0.server = "https://qol1.unige.ch/mqol-parse-next/"
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
        
        //Register for remote push notifications
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        application.registerForRemoteNotifications()
        
        //Check if the app was launched due to a push notification
        if let notificationPayload = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary {
            
            //Get the surveyID from the payload.
            let survey = notificationPayload["argument"] as? String
            
            //Store the information in the local cache
            UserDefaults.standard.set(true, forKey: "fireNotificationSurvey")
            UserDefaults.standard.set(survey, forKey: "surveyToFire")
        }
        
        return true
    }
    
    //Function that handles the incomming dynamic links
    func handleIncommingDynamicLinks(_ dynamicLink : DynamicLink) {
        guard let url = dynamicLink.url else {
            print ("Error: No url was found")
            return
        }
        print ("\n\n\nIncomming link with parameters: \(url.absoluteString) \n\n\n")
        
        //Check how confident we are that this is the right link
       guard (dynamicLink.matchType == .unique || dynamicLink.matchType == .default) else {
            print ("We are not sure that this is the right link")
            return
        }
        
        //Parse the parameters 
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems else { return }
        
        print("\n\n\nLink parameters are:")
        for item in queryItems {
            
            //Used if the dynamic link has been created by an iOS.
            if item.name == "inviterIdKey" {
                let studyUserId = item.value
                
                //Setting variables in local cache for later use
                UserDefaults.standard.set(true, forKey: "isPeer")
                UserDefaults.standard.set(studyUserId, forKey: "peerSubjectID")
            }
            //Used if the dynamic link has been created by an Android
            else if item.name == "link" {                
                let newURL = URL(string: item.value!)
                guard let components = URLComponents(url: newURL!, resolvingAgainstBaseURL: false),
                    let newQueryItems = components.queryItems else { return }
                
                for newItem in newQueryItems {
                    let studyUserId = newItem.value
                    
                    //Setting variables in local cache for later use
                    UserDefaults.standard.set(true, forKey: "isPeer")
                    UserDefaults.standard.set(studyUserId, forKey: "peerSubjectID")
                }
            }
        }
    }
    
    //Is called if the app is opened through a universal link
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            print("Incomming URL: \(incomingURL)")
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else {
                    print ("Error: \(error!.localizedDescription)")
                    return
                }
                if let dynamicLink = dynamicLink {
                    self.handleIncommingDynamicLinks(dynamicLink)
                }
            }
            if linkHandled {
                return true
            }
            else {
                return false
            }
        }
        return false
    }
    
    //Is called when app is opened through a URL scheme
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print ("URL received through a custom scheme! \(url.absoluteString)")
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            self.handleIncommingDynamicLinks(dynamicLink)
            return true
        }
        else {
            return false
        }
    }
    
    //Is called when the app successfully signs up for remote push notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        if let installation = PFInstallation.current() {
            installation.setDeviceTokenFrom(deviceToken)
            installation.saveInBackground()
        }
    }
    
    //Is called if push notification is recieved when the app is running
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let survey = userInfo["argument"] as? String {
            //Store the information in the local cache
            UserDefaults.standard.set(true, forKey: "fireNotificationSurvey")
            UserDefaults.standard.set(survey, forKey: "surveyToFire")
            completionHandler(UIBackgroundFetchResult.newData)
        }
        completionHandler(UIBackgroundFetchResult.noData)
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

// MARK:- Local notification extensions

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

