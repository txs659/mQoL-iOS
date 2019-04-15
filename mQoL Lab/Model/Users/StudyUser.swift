//
//  StudyUser.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 15/04/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import Parse

class StudyUser : PFObject, PFSubclassing {
    
    @NSManaged var observersChannel : String
    @NSManaged var study : Study
    @NSManaged var mqolUser : MqolUser
    @NSManaged var status : String
    @NSManaged var entrySurveyDone : Bool
    @NSManaged var exitSurveyDone : Bool
    @NSManaged var baselineSurveyDone : Bool
    @NSManaged var demographicsSurveyDone : Bool
    @NSManaged var flowState : String
    
    static func parseClassName() -> String {
        return "StudyUser"
    }
    
    func initialize (mUser : MqolUser, stud : Study, channel : String) {
        mqolUser = mUser
        study = stud
        observersChannel = channel
        status = "active"
        entrySurveyDone = false
        exitSurveyDone = false
        baselineSurveyDone = false
        demographicsSurveyDone = false
        flowState = "awaiting"
    }
    
    
    
}
