//
//  SurveyTrigger.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 23/04/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import Foundation
import Parse

class SurveyTrigger : PFObject, PFSubclassing {
    
    
    @NSManaged var study : Study
    @NSManaged var mqolUser : MqolUser
    @NSManaged var survey : Survey
    @NSManaged var eventType : String
    
    static func parseClassName() -> String {
        return "SurveyTrigger"
    }
    
    static func basicQuery() -> PFQuery<SurveyTrigger> {
        return self.query() as! PFQuery<SurveyTrigger>
    }
    
    func initialize (event : String, survey : Survey, mqolUser : MqolUser, study : Study) {
        self.eventType = event
        self.survey = survey
        self.mqolUser = mqolUser
        self.study = study
    }
    
}
