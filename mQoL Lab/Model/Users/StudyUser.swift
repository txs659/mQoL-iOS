//
//  StudyUser.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 15/04/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import Parse
import PDFKit

class StudyUser : PFObject, PFSubclassing {
    
    public static let STUDY_FLOW_STATE_1 = "awaiting";
    public static let STUDY_FLOW_STATE_2 = "ongoing";
    public static let STUDY_FLOW_STATE_3 = "finished";

    
    public static let  STATUS_NONE = "none";
    public static let  STATUS_ACTIVE = "active";
    public static let  STATUS_INACTIVE = "inactive";
    public static let  STATUS_QUITED = "quited";
    public static let  STATUS_FINISHED = "finished";

    
    @NSManaged var observersChannel : String
    @NSManaged var study : Study
    @NSManaged var mqolUser : MqolUser
    @NSManaged var status : String
    @NSManaged var entrySurveyDone : Bool
    @NSManaged var exitSurveyDone : Bool
    @NSManaged var baselineSurveyDone : Bool
    @NSManaged var demographicsSurveyDone : Bool
    @NSManaged var flowState : String
    @NSManaged var endDate : Date
    @NSManaged var elapsedDays : Int
    @NSManaged var studyConsent : PFFileObject
    @NSManaged var survey1Done : Bool
    @NSManaged var survey2Done : Bool
    @NSManaged var survey3Done : Bool
    
    static func parseClassName() -> String {
        return "StudyUser"
    }
    
    func initialize (mUser : MqolUser, stud : Study, channel : String) {
        mqolUser = mUser
        study = stud
        observersChannel = channel
        status = "active"
        survey1Done = false
        survey2Done = false
        survey3Done = false
        exitSurveyDone = false
        flowState = "awaiting"
    }
    
    func setEndDate (_ duration : Int) {
        self.endDate = Calendar.current.date(byAdding: .day, value: duration, to: Date())!
        
    }
    
    func setStatus (_ newStatus : String) {
        self.status = newStatus
    }
    
    func setStudyFlowState (_ statusFlow : String) {
        self.flowState = statusFlow
    }
    
    func setElapsedDays (days : Int) {
        self.elapsedDays = days
    }
    
    func setSurveyDone (_ surveyNumber : Int) {
        if surveyNumber == 1 {
            self.survey1Done = true
        }
        else if surveyNumber == 2 {
            self.survey2Done = true
        }
        else {
            self.survey3Done = true
        }
    }
    
    func setExitSurveyDone () {
        self.exitSurveyDone = true
    }
    
    
    
    
    
    //DOES NOT WORK ATM
    
    //Puts the users name and current date into the PDF file
    func setAndSignInformedConsent (file : PFFileObject, name : String) {
        let fileUrl = URL(string : file.url!)
        let document = PDFDocument(url: fileUrl!)
        
        let lastPage = document?.page(at: 3)
        let annotations = lastPage!.annotations
        
        for annotation in annotations {
            if annotation.fieldName == "name" {
                annotation.setValue(name, forAnnotationKey: .widgetValue)
                annotation.contents = name
                lastPage!.removeAnnotation(annotation)
                lastPage!.addAnnotation(annotation)
            }
            else if annotation.fieldName == "date" {
                let date : Date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                let dateString = dateFormatter.string(from: date)
                annotation.setValue(dateString, forAnnotationKey: .widgetValue)
                annotation.contents = dateString
                lastPage!.removeAnnotation(annotation)
                lastPage!.addAnnotation(annotation)
            }
        }
        
        do {
            let dataUrl = document?.documentURL
            let data = try Data(contentsOf: dataUrl!)
            
            let newDoc = try PFFileObject(name: "file.pdf", data: data, contentType: "application/pdf")
            self.studyConsent = newDoc
        } catch {
            print ("Error")
        }
        
        
        
    }
    
    
    
}
