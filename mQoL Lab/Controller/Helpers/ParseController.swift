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

    private static let STUDY_USER_STORE_KEY = "study_users";
    
    private static let PEER_STORE_KEY = "peers"
    
    
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
        let studyQuery : PFQuery<Study> = Study.getStudies()!
        return studyQuery.findObjectsInBackground().continueWith { (task) -> Array<Study> in
            let studies = task.result as! Array<Study>
            return studies
            }
    }
    
    
    
    /**
     * This function returns an object containing the detail of a study
     * @param studyId   ObjectID of the study to be retrieved
     * @return  ParseObject corresponding to the study with objectId provided encapsulated in a Task
     */
    static func getStudy(studyId : String) -> BFTask<Study> {
        PFObject.unpinAllObjectsInBackground(withName: STUDY_STORE_KEY)
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
    
    
    
    /**
     * Retrieves a parse object representing an entry in the Parse table Survey
     * @param surveyID  String representing the objectId of the survey to be retrieved
     * @return  parse object representing an entry in the Parse table Survey encapsulated in a Task
     */
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
    
    
    
    /**
     * Registers an entry in the Parse Table StudyUsers. This entry represents the fact that
     * the current user (from table MqolUsers) is joining the given study.
     *
     * @param studyId   String representing the study of interest
     * @param name      Name used to sign study informed consent
     */
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
    
    /**
     * This function returns a record from the StudyUsers table that match the parameters of
     * interest.
     *
     * @param studyId   ObjectId of the study that we are interested on
     *
     * @return  ParseObject representing a record in the StudyUsers table that matches the provided
     *                      studyId + currentMqolUser encapsulated in a Task
     */

    static func getStudyUserByStudyId (_ studyId : String) -> BFTask<StudyUser> {
        PFObject.unpinAllObjectsInBackground(withName: STUDY_USER_STORE_KEY)
        PFObject.unpinAllObjectsInBackground()
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
    
    
    
    /**
     * Returns a record from StudyConfig table that matches the study passed as argument
     * @param study study object to match against
     * @return  StudyConfig record encapsulated in a Task
     */
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
    
    
    
    /**
     * This function performs study initialization tasks after a user has been registered to a study
     * @param study   record needed to retrieved the StudyConfig corresponding record
     */
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
    
    
    /**
     * This method finds the entry in the StudyUser table and changes the statusFlow field
     *
     * @param studyId String representing the study of interest
     * @param statusFlow String containing the new status flow
     */
    static func setStudyUserFlowState (studyId : String, statusFlow : String) {
        var studyUser = StudyUser()
        getStudyUserByStudyId(studyId).continueOnSuccessWith { (task) -> Void in
            studyUser = task.result! as StudyUser
            studyUser.setStudyFlowState(statusFlow)
            studyUser.saveEventually()
        }
    }
    
    
    /**
     * This method sets the corresponding survey as done for a studyUser
     *
     * @param studyUser The current studyUser
     * @param surveyNumver:
     *      - 1 is equal to survey1
     *      - 2 is equal to survey2
     *      - 3 is equal to survey3
     */
    static func setSurveyDone (studyUser : StudyUser, surveyNumber : Int) {
        if surveyNumber >= 1 && surveyNumber <= 3 {
            
            studyUser.setSurveyDone(surveyNumber)
            studyUser.saveEventually()
            
        }
        else {
            print ("Survey number must be between 1 and 3, since it must correspond to Survey1, Survey2 or Survey3")
        }
    }
    
    static func setExitSurveyDone (studyUser : StudyUser) {
        studyUser.setExitSurveyDone()
        studyUser.saveEventually()
    }
    
    
    
    // MARK: - Functions used when user starts a study
    
    
    /**
     * This method is called when a user clicks the command to start  a study.
     * The main actions are:
     *  - estimate and set the end date for the study
     *  - set the flag Study Started to true
     *  - init elapsed days to 0
     * @param studyId the study id
     */
    static func startStudyCountDown (studyId : String) {
        var study = Study()
        var studyConfig = StudyConfig()
        var studyUser = StudyUser()
        getStudy(studyId: studyId).continueOnSuccessWith { (task) -> Void in
            study = task.result! as Study
            
            getStudyConfigByStudy(study).continueOnSuccessWith(block: { (task) -> Void in
                studyConfig = task.result! as StudyConfig
                
                getStudyUserByStudyId(study.objectId!).continueOnSuccessWith(block: { (task) -> Void in
                    studyUser = task.result! as StudyUser
                    
                    let durationDays = studyConfig.value(forKey: "durationDays") as! Int
                    studyUser.setEndDate(durationDays)
                    studyUser.setStudyFlowState(StudyUser.STUDY_FLOW_STATE_2)
                    studyUser.setElapsedDays(days: 1)
                    
                    studyUser.pinInBackground(withName: STUDY_USER_STORE_KEY).continueOnSuccessWith(block: { (task) -> Void in
                        studyUser.saveEventually()
                    })
                    
                })
                
            })
            
        }
    }
    
    

    
    
    // MARK: - Functions used when user quits a study
    
    /**
     * This method find the entry in the StudyUser table and changes the status to inactive
     * This action represents the users intention to quit a study
     *
     * @param studyId String representing the study of interest
     * @param status String containing the new status for the StudyUser
     */
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
    
    
    /**
     * This function removes survey triggers from the SurveyTrigger table when a user leaves
     * the parent study of that survey
     */
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
    
    
    
    // MARK: - Peer specific functions
    
    /**
     * Return all objects in the PEER table that match the current MqolUser
     *
     * @return  the first peer Object matching the status provided
     */

    static func getPeer () -> BFTask<Peer> {
        var mqolUser = MqolUser()
        return getMqolUser().continueOnSuccessWith { (task) -> Any? in
            mqolUser = task.result as! MqolUser
            let peerQuery : PFQuery = Peer.getPeerByMqolUserQuery(mqolUser: mqolUser)
            return peerQuery.fromLocalDatastore().getFirstObjectInBackground().continueWith(block: { (task) -> Any? in
                if task.error != nil {
                    return peerQuery.getFirstObjectInBackground().continueOnSuccessWith(block: { (task) -> Any? in
                        let peer = task.result! as Peer
                        peer.pinInBackground(withName: PEER_STORE_KEY)
                        return peer
                    })
                }
                return task
            })
        } as! BFTask<Peer>
    }
    
    
    static func setUpPeerSurveyRequirements(peer : Peer, studyUser : StudyUser) {
        var study = Study()
        var studyConfig = StudyConfig()
        
        self.getStudy(studyId: studyUser.getStudy().objectId!).continueOnSuccessWith { (task) -> Void in
            study = task.result!
            self.getStudyConfigByStudy(study).continueOnSuccessWith(block: { (task) -> Void in
                studyConfig = task.result!
                
                if !studyConfig.isSurvey1Peer() {
                    peer.setSurvey1Done()
                }
                
                if !studyConfig.isSurvey2Peer() {
                    peer.setSurvey2Done()
                }
                
                if !studyConfig.isSurvey3Peer() {
                    peer.setSurvey3Done()
                }
                
                if !studyConfig.isExitSurveyPeer() {
                    peer.setExitSurveyDone()
                }
                
                peer.pinInBackground(withName: PEER_STORE_KEY).continueOnSuccessWith(block: { (task) -> Void in
                    peer.saveEventually()
                })
            })
        }
        
    }
    
    /**
     * This method sets the corresponding survey as done for a peer
     *
     * @param peer The current peer
     * @param surveyNumver:
     *      - 1 is equal to survey1
     *      - 2 is equal to survey2
     *      - 3 is equal to survey3
     */
    static func peerSetSurveyDone (peer : Peer, surveyNumber : Int) {
        if surveyNumber >= 1 && surveyNumber <= 3 {
            peer.setSurveyDone(surveyNumber)
            peer.saveEventually()
        }
        else {
            print ("Survey number must be between 1 and 3, since it must correspond to Survey1, Survey2 or Survey3")
        }
    }
    
    static func peerSetExitSurveyDone (peer : Peer) {
        peer.setExitSurveyDone()
        peer.saveEventually()
    }
    
    

}
