//
//  LocalNotificationManager.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 09/05/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import UserNotifications

struct surveyNotification {
    var id:String
    var title:String
    var body:String
    var survey:String
    var datetime:DateComponents
}

class LocalNotificationManager {
    
    var notifications = [surveyNotification]()
    
    // Lists all scheduled notifications (used for debugging)
    func listScheduledNotifications()
    {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            
            for notification in notifications {
                print(notification)
            }
        }
    }
    
    func deleteAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    //Asks user for permission to send notifications
    private func requestAuthorization()
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            
            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    
    
    func schedule()
    {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break // Do nothing
            }
        }
    }
    
    
    private func scheduleNotifications()
    {
        for notification in notifications
        {
            let content      = UNMutableNotificationContent()
            content.title    = notification.title
            content.body     = notification.body
            content.sound    = .default
            content.userInfo = ["survey": notification.survey]
    
            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: false)
            
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                
                guard error == nil else { return }
                
                print("Notification scheduled! --- ID = \(notification.id)")
            }
        }
    }
    
    
    
    
    
    
    
    
    
}
