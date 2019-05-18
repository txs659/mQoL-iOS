//
//  StudyConfig.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 15/04/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import Foundation
import Parse

class StudyConfig : PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "StudyConfig"
    }
    
    static func basicQuery() -> PFQuery<StudyConfig> {
        return self.query() as! PFQuery<StudyConfig>
    }
    
    static func getStudyConfigByStudyQuery(study : Study) -> PFQuery<StudyConfig> {
        return self.query()?.whereKey("study", equalTo: study) as! PFQuery<StudyConfig>
    }
    
    public func isSurvey1Peer () -> Bool {
        let survey = value(forKey: "survey1_survey_peer")
        return survey != nil
    }
    
    public func isSurvey2Peer () -> Bool {
        let survey = value(forKey: "survey2_survey_peer")
        return survey != nil
    }
    
    public func isSurvey3Peer () -> Bool {
        let survey = value(forKey: "survey3_survey_peer")
        return survey != nil
    }
    
    public func isExitSurveyPeer () -> Bool {
        let survey = value(forKey: "exitSurveyPeer")
        return survey != nil
    }
    
}
