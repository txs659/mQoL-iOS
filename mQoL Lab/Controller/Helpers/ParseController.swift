//
//  ParseController.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 19/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import Parse

class ParseController {
    
    private static let SURVEY_STORE_KEY = "survey";

    private static let STUDY_STORE_KEY = "studies";

    private static let STUDY_CONFIG_STORE_KEY = "study_configs";
    
    private static let TRIGGER_STORE_KEY = "triggers";
    
    private static let ACTIVE_STUDY_KEY = "active_study";
    // should not reset
    // Bucket is the same for all the study users
    // In this bucket there are the following objects: STUDY_USER
    private static let STUDY_USER_STORE_KEY = "study_users";
    
    
    
    
    // Get the current user that is logged in
    static func getCurrentParseUser() -> PFUser {
        return PFUser.current()!
    }
    
    
    
    // Get the current MqolUser that is logged in
    static func getMqolUser() -> BFTask<AnyObject> {
        let parseUser = getCurrentParseUser()
        let mqolUserId = (parseUser.object(forKey: "mqolUser") as AnyObject).objectId!!
        let query = PFQuery(className: "MqolUser")
        return query.getObjectInBackground(withId: "\(mqolUserId)").continueWith { (task) -> MqolUser in
            let mqolUser = task.result as! MqolUser
            return mqolUser
        }
    }
    
    
    
    
    
    
    /*
     // Changes the 'labAgreementAccepted' property to true for
     // the MqolUser Parse object
     */
    static func mqolUserAcceptLabAgreement() {
        let parseUser = getCurrentParseUser()
        if parseUser.isAuthenticated {
            let mqolUserId = (parseUser.object(forKey: "mqolUser") as AnyObject).objectId!!
            let query = PFQuery(className: "MqolUser")
            query.getObjectInBackground(withId: "\(mqolUserId)") { (user : PFObject?, error : Error?) in
                
                if error != nil {
                    print (error!)
                }
                else {
                    let mqolUser : MqolUser = user as! MqolUser
                    mqolUser.acceptLabAgreement()
                    mqolUser.saveEventually()
                }
            }
        }
    }
    
    
    
    
    
    // Retreive an array of all the avaiable studies.
    static func getStudyList() -> BFTask<AnyObject> {
        let studyQuery : PFQuery<Study> = Study.getStudiesByStatusQuery()!
        return studyQuery.findObjectsInBackground().continueWith { (task) -> Array<Study> in
            let studies = task.result as! Array<Study>
            return studies
            }
    }
    
    
    
    
    
    static func getStudy(studyId : String) -> BFTask<Study> {
        return Study.basicQuery().fromLocalDatastore().getObjectInBackground(withId: studyId).continueWith(block: { (task) -> BFTask<Study> in
            if task.error != nil {
                return Study.basicQuery().getObjectInBackground(withId: studyId).continueWith(block: { (task) -> BFTask<AnyObject> in
                    let study : Study = task.result! as Study
                    return study.pinInBackground(withName: STUDY_STORE_KEY).continueOnSuccessWith(block: { (task) -> Any? in
                        return study
                    })
                }) as! BFTask<Study>
            }
            return task
        }) as! BFTask<Study>
    }
    
    
    
    
    static func getSurvey(_ surveyId : String) -> BFTask<Survey> {
        return Survey.basicQuery().fromLocalDatastore().getObjectInBackground(withId: surveyId).continueWith(block: { (task) -> BFTask<Survey> in
            if task.error != nil {
                return Survey.basicQuery().getObjectInBackground(withId: surveyId).continueWith(block: { (task) -> BFTask<AnyObject> in
                    let survey : Survey = task.result! as Survey
                    return survey.pinInBackground(withName: SURVEY_STORE_KEY).continueOnSuccessWith(block: { (task) -> Any? in
                        return survey
                    })
                }) as! BFTask<Survey>
            }
            return task
        }) as! BFTask<Survey>
    }
    
    
    
    

    static func createStudyUser(studyId : String, name : String) {
        var mqolUser = MqolUser()
        var study = Study()
        getMqolUser().continueOnSuccessWith { (task) -> BFTask<Study> in
            mqolUser = task.result as! MqolUser
            return getStudy(studyId: studyId)
            }.continueWith { (task) -> Any? in
                study = task.result as! Study
                return nil
            }.continueOnSuccessWith { (task) -> Any? in
                let channelCode : String = "OBSER-" + "\(mqolUser.objectId!)" + "-" + "\(studyId)"
                
                // Creating object and initializing
                let studyUser = StudyUser()
                studyUser.initialize(mUser: mqolUser, stud: study, channel: channelCode)
                
                let file = study.value(forKey: "informedConsent") as! PFFileObject
                studyUser.setAndSignInformedConsent(file: file, name: name)
                
                return studyUser.pinInBackground(withName: STUDY_USER_STORE_KEY).continueOnSuccessWith(block: { (task) -> Any? in
                    studyUser.saveInBackground()
                })
                

            }.continueOnSuccessWith { (task) -> Void in
                self.processStudyConfiguration(study: study)
            }.continueOnSuccessWith { (task) -> Void in
                self.saveActiveStudy(study: study)
        }
    }
    
    
    
    
    
    
    static func getStudyUserByStudyId (_ studyId : String) -> BFTask<StudyUser> {
        PFObject.unpinAllObjectsInBackground(withName: STUDY_USER_STORE_KEY)
        var mqolUser = MqolUser()
        var study = Study()
        return getMqolUser().continueOnSuccessWith(block: { (task) -> Any? in
            mqolUser = task.result as! MqolUser
            return getStudy(studyId: studyId)
        }).continueOnSuccessWith(block: { (task) -> Any? in
            study = task.result as! Study
            let query = PFQuery(className: StudyUser.parseClassName())
            return query.fromLocalDatastore().whereKey("study", equalTo: study).whereKey("mqolUser", equalTo: mqolUser).getFirstObjectInBackground().continueWith(block: { (task) -> Any? in
                if task.error != nil {
                    let query = PFQuery(className: StudyUser.parseClassName())
                    return query.whereKey("study", equalTo: study).whereKey("mqolUser", equalTo: mqolUser).getFirstObjectInBackground().continueWith(block: { (task) -> Any? in
                        let studyUser : StudyUser = task.result as! StudyUser
                        return studyUser.pinInBackground(withName: STUDY_USER_STORE_KEY).continueOnSuccessWith(block: { (task) -> Any? in
                            return studyUser
                        })
                    })
                }
                return task
            })
        }) as! BFTask<StudyUser>
    }
    
    
    
    
    
    
    static func getStudyConfigByStudy(_ study : Study) -> BFTask<StudyConfig> {
        PFObject.unpinAllObjectsInBackground(withName: STUDY_CONFIG_STORE_KEY)
        return StudyConfig.getStudyConfigByStudyQuery(study: study).fromLocalDatastore().getFirstObjectInBackground().continueWith(block: { (task) -> BFTask<StudyConfig> in
            if task.error != nil {
                return StudyConfig.getStudyConfigByStudyQuery(study: study).getFirstObjectInBackground().continueWith(block: { (task) -> BFTask<AnyObject> in
                    let studyConfig = task.result! as StudyConfig
                    return studyConfig.pinInBackground(withName: STUDY_CONFIG_STORE_KEY).continueOnSuccessWith(block: { (task) -> Any? in
                        return studyConfig
                    })
                }) as! BFTask<StudyConfig>
            }
            return task
        }) as! BFTask<StudyConfig>
    }
    
    
    
    
    
    
    
    static func processStudyConfiguration (study : Study) {
        var mqolUser = MqolUser()
        var studyConfig = StudyConfig()
        
        getMqolUser().continueOnSuccessWith { (task) -> Void in
            mqolUser = task.result as! MqolUser
        }.continueWith { (task) -> Void in
            getStudyConfigByStudy(study).continueOnSuccessWith { (task) -> Void in
                studyConfig = task.result! as StudyConfig
            }.continueOnSuccessWith(block: { (task) -> Void in
                let array : Array<Array<String>> = studyConfig.value(forKey: "eventSurveys") as! Array<Array<String>>
                for subArray in array {
                    let event : String =  subArray[0]
                    let surveyId : String = subArray[1]
                    
                    let surveyTrigger = SurveyTrigger()
                    
                    getSurvey(surveyId).continueOnSuccessWith(block: { (task) -> Void in
                        let survey = task.result! as Survey
                        
                        surveyTrigger.initialize(event: event, survey: survey, mqolUser: mqolUser, study: study)
                        
                        surveyTrigger.pinInBackground(withName: TRIGGER_STORE_KEY)
                        
                    }).continueOnSuccessWith(block: { (task) -> Void in
                        surveyTrigger.saveInBackground()
                    })
                }
            })
        }
    }
    
    
    
    
    static func saveActiveStudy (study : Study) {
        study.pinInBackground(withName: ACTIVE_STUDY_KEY)
    }
    
    

    
    static func disableUserFromStudy (studyId : String, status : String) {
        var studyUser = StudyUser()
        getStudyUserByStudyId(studyId).continueOnSuccessWith { (task) -> Void in
            studyUser = task.result! as StudyUser
            studyUser.setStatus(status)
            studyUser.pinInBackground()
        }.continueOnSuccessWith { (task) -> Void in
            cleanUpSurveyTriggersForUser(studyId)
        }.continueOnSuccessWith { (task) -> Void in
            studyUser.saveEventually()
        }
    }
    
    
    
    static func cleanUpSurveyTriggersForUser (_ studyId : String) {
        var study = Study()
        var arrayOfTriggers = NSArray()
        getStudy(studyId: studyId).continueOnSuccessWith { (task) -> Void in
            study = task.result! as Study
            let query = SurveyTrigger.basicQuery()
            query.whereKey("study", equalTo: study)
            query.fromLocalDatastore().findObjectsInBackground().continueWith(block: { (task) -> Void in
                
                if task.error != nil {
                    let query = SurveyTrigger.basicQuery()
                    query.whereKey("study", equalTo: study)
                    query.findObjectsInBackground().continueOnSuccessWith(block: { (task) -> Void in
                        arrayOfTriggers = task.result!
                    })
                }
                else {
                    arrayOfTriggers = task.result!
                }
            }).continueOnSuccessWith(block: { (task) -> Void in
                PFObject.unpinAll(inBackground: arrayOfTriggers as? [PFObject])
                PFObject.deleteAll(inBackground: arrayOfTriggers as? [PFObject])
            })
        }
    }
    
    
    
    
    

}
