//
//  NotificationScheduler.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 11/05/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationScheduler {
    
    private let manager = LocalNotificationManager()
    private var scheduleInfo = [String : Any]()
    private var durationDays = 0
    let language = UserDefaults.standard.string(forKey: "language")
    
    
    //This function calls the two other functions and schedules the notifications.
    public func scheduleAllNotifications (info : [String : Any], days : Int) {
        
        self.scheduleInfo = info
        self.durationDays = days
        
        self.scheduleFixedEvents()
        self.scheduleRandomEvents()
        
        manager.schedule()
    }
    
    //This function creates the random event notifications
    private func scheduleRandomEvents() {
        let today = Date()
        var randomAcceptedDays = [String]()
        
        //First we want to dissect the info about the notifications schedulling
        let randomInfo = scheduleInfo["random"] as! [String : Any]
        let randomDays = randomInfo["days"] as! [String : Any]
        let randomSurveyInfo = randomInfo["info"] as! [String : Any]
        let randomSurvey = randomSurveyInfo["survey"] as! String
        
        let startHour = randomSurveyInfo["start_hour"] as! Int
        let endHour = randomSurveyInfo["end_hour"] as! Int
        let numberOfPrompts = randomSurveyInfo["num_prompts"] as! Int
        
        //Populating an array with accepted days to schedule notifications
        for (key, value) in randomDays {
            let boolValue = value as! Bool
            if boolValue {
                randomAcceptedDays.append(key.capitalized)
            }
        }
        
        //Iterates through a time period calculated from the current day and a number of days
        //equal to the study duration forward. For each day a number of random events is
        //scheduled
        for day in 1...durationDays{
            
            //Making a dateformater so we can compare accepted days with the calculated day
            //with the format "Mon", "Tue" etc.
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
            let date = Calendar.current.date(byAdding: .day, value: day, to: today)
            let weekDay = dateFormatter.string(from: date!)
            
            //If the calculated day is in the accepted days array go make a notification
            if randomAcceptedDays.contains(weekDay) {
                
                //Makes sure that we make a specific number of random notifications
                for randomNum in 1...numberOfPrompts {
                    
                    //Generates a random hour and minute within the given hour interval
                    let randomHour = Int.random(in: startHour..<endHour)
                    let randomMinute = Int.random(in: 0..<60)
                    
                    //if language is French add French text to notification
                    if language == "fr" {
                        //Adds the notification to the notification array
                        manager.notifications.append(surveyNotification(
                            id: "randomDay\(day)Num\(randomNum)",
                            title: FrStrings.survey_notification,
                            body: FrStrings.survey_notification_text,
                            survey: randomSurvey,
                            datetime: DateComponents(
                                calendar: Calendar.current,
                                year: Calendar.current.component(.year, from: date!),
                                month: Calendar.current.component(.month, from: date!),
                                day: Calendar.current.component(.day, from: date!),
                                hour: randomHour,
                                minute: randomMinute
                        )))
                    }
                    //if language is English add English text to notification
                    else {
                        //Adds the notification to the notification array
                        manager.notifications.append(surveyNotification(
                            id: "randomDay\(day)Num\(randomNum)",
                            title: EnStrings.survey_notification,
                            body: EnStrings.survey_notification_text,
                            survey: randomSurvey,
                            datetime: DateComponents(
                                calendar: Calendar.current,
                                year: Calendar.current.component(.year, from: date!),
                                month: Calendar.current.component(.month, from: date!),
                                day: Calendar.current.component(.day, from: date!),
                                hour: randomHour,
                                minute: randomMinute
                        )))
                    }
                }
            }
        }
    }
    
    //This function creates the fixed event notifications
    private func scheduleFixedEvents() {
        
        let today = Date()
        var fixedAcceptedDays = [String]()
        
        //First we want to dissect the info about the notifications schedulling
        let fixedInfo = scheduleInfo["fixed"] as! [String : Any]
        let fixedDays = fixedInfo["days"] as! [String : Any]
        let fixedSurveyInfo = fixedInfo["info"] as! [String : Any]
        let fixedPromptHour = fixedSurveyInfo["prompt_hour"] as! Int
        let fixedSurvey = fixedSurveyInfo["survey"] as! String
        
        //Populating an array with accepted days to schedule notifications
        for (key, value) in fixedDays {
            let boolValue = value as! Bool
            if boolValue {
                fixedAcceptedDays.append(key.capitalized)
            }
        }
        
        //Iterates through a time period calculated from the current day and a number of days
        //equal to the study duration forward.
        for day in 1...durationDays {
            
            //Making a dateformater so we can compare accepted days with the calculated day
            //with the format "Mon", "Tue" etc.
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
            let date = Calendar.current.date(byAdding: .day, value: day, to: today)
            let weekDay = dateFormatter.string(from: date!)
            
            //For each day we only want 1 notification and the time is fixed.
            if fixedAcceptedDays.contains(weekDay) {
                
                //if language is French add French text to notification
                if language == "fr" {
                    //Adds the notification to the notification array
                    manager.notifications.append(surveyNotification(
                        id: "fixedDay\(day)",
                        title: FrStrings.survey_notification,
                        body: FrStrings.survey_notification_text,
                        survey: fixedSurvey,
                        datetime: DateComponents(
                            calendar: Calendar.current,
                            year: Calendar.current.component(.year, from: date!),
                            month: Calendar.current.component(.month, from: date!),
                            day: Calendar.current.component(.day, from: date!),
                            hour: fixedPromptHour,
                            minute: 0
                    )))
                }
                //if language is English add English text to notification
                else {
                    //Adds the notification to the notification array
                    manager.notifications.append(surveyNotification(
                        id: "fixedDay\(day)",
                        title: EnStrings.survey_notification,
                        body: EnStrings.survey_notification_text,
                        survey: fixedSurvey,
                        datetime: DateComponents(
                            calendar: Calendar.current,
                            year: Calendar.current.component(.year, from: date!),
                            month: Calendar.current.component(.month, from: date!),
                            day: Calendar.current.component(.day, from: date!),
                            hour: fixedPromptHour,
                            minute: 0
                    )))
                }
            }
        }
    }
}
