//
//  Peer.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 17/05/2019.
//  Copyright © 2019 mQoL. All rights reserved.
//

import Foundation
import Parse

class Peer : PFObject, PFSubclassing {
    
    // all the keys
    private let PARTICIPANT              = "participant";
    private let OBSERVER                 = "observer";
    private let STATUS                   = "status";
    private let BASELINE_SURVEY_DONE     = "baselineSurveyDone";
    private let ENTRY_SURVEY_DONE        = "entrySurveyDone";
    private let EXIT_SURVEY_DONE         = "exitSurveyDone";
    private let DEMOGRAP_SURVEY_DONE     = "demographicsSurveyDone";
    private let CAN_FINISH               = "canFinish";

    @NSManaged var participant : StudyUser
    @NSManaged var survey1Done : Bool
    @NSManaged var survey2Done : Bool
    @NSManaged var survey3Done : Bool
    @NSManaged var exitSurveyDone : Bool
    
    static func parseClassName() -> String {
        return "Peer"
    }
    
    public func getParticipant() -> StudyUser {
        return value(forKey: self.PARTICIPANT) as! StudyUser
    }
    
    public func setSurvey1Done () {
        self.survey1Done = true
    }
    
    public func setSurvey2Done () {
        self.survey1Done = true
    }
    
    public func setSurvey3Done () {
        self.survey3Done = true
    }
    
    public func setExitSurveyDone () {
        self.exitSurveyDone = true
    }
    
    
}
