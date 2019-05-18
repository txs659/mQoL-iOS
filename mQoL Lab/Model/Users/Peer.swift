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
    private static let PARTICIPANT              = "participant";
    private static let OBSERVER                 = "observer";
    private static let STATUS                   = "status";
    private static let BASELINE_SURVEY_DONE     = "baselineSurveyDone";
    private static let ENTRY_SURVEY_DONE        = "entrySurveyDone";
    private static let EXIT_SURVEY_DONE         = "exitSurveyDone";
    private static let DEMOGRAP_SURVEY_DONE     = "demographicsSurveyDone";
    private static let CAN_FINISH               = "canFinish";

    @NSManaged var participant : StudyUser
    @NSManaged var survey1Done : Bool
    @NSManaged var survey2Done : Bool
    @NSManaged var survey3Done : Bool
    @NSManaged var exitSurveyDone : Bool
    
    static func parseClassName() -> String {
        return "Peer"
    }
    
    static func getPeerByMqolUserQuery(mqolUser : MqolUser) -> PFQuery<Peer> {
        return PFQuery.init(className: parseClassName()).whereKey(OBSERVER, equalTo: mqolUser)
    }
    
    public func getParticipant() -> StudyUser {
        return value(forKey: Peer.PARTICIPANT) as! StudyUser
    }
    
    public func setSurvey1Done () {
        self.survey1Done = true
    }
    
    public func setSurvey2Done () {
        self.survey2Done = true
    }
    
    public func setSurvey3Done () {
        self.survey3Done = true
    }
    
    public func setExitSurveyDone () {
        self.exitSurveyDone = true
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
    
    
}
