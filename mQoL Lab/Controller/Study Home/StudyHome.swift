//
//  StudyHome.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 08/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import Parse
import UserNotifications
import MessageUI

class StudyHome: UIViewController, MFMailComposeViewControllerDelegate {
    
    //Objects are fetched when view is loaded and stored in these variables.
    var study = Study()
    var studyConfig = StudyConfig()
    var studyUser = StudyUser()
    
    //Surveys are fecthed when view is loaded and stored in these variables.
    var survey1_survey = Survey()
    var survey2_survey = Survey()
    var survey3_survey = Survey()
    
    //Used in call to mqol web application
    var urlString = ""
    
    var exitSurveyFired = false
    
    @IBOutlet weak var studyTitle : UILabel!
    @IBOutlet weak var studyDescribtion : UILabel!
    @IBOutlet weak var studyTasks : UILabel!
    @IBOutlet weak var daysInStudy : UILabel!
    
    @IBOutlet weak var survey1 : UIButton!
    @IBOutlet weak var survey2 : UIButton!
    @IBOutlet weak var survey3 : UIButton!
    @IBOutlet weak var externalSurveyBtn : UIButton!
    
    @IBOutlet weak var startBtn : UIButton!
    @IBOutlet weak var quitBtn : UIButton!
    @IBOutlet weak var addPeerBtn : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let isStudyStarted = UserDefaults.standard.bool(forKey: "studyLoaded")
        
        if isStudyStarted {
            loadStudyRunningScreen()
        } else {
            loadBeginStudyScreen()
        }
        
    }
    
    
    // Check everytime survyes is done, to see if the start study button should be displyed.
    override func viewWillAppear(_ animated: Bool) {
        let isStudyStarted = UserDefaults.standard.bool(forKey: "studyLoaded")
        
        if !isStudyStarted {
            studyUser.fetchInBackground().continueOnSuccessWith { (task) -> Void in
                let survey1Done = self.studyUser.survey1Done
                let survey2Done = self.studyUser.survey2Done
                let survey3Done = self.studyUser.survey3Done
                
                if survey1Done && survey2Done && survey3Done {
                    DispatchQueue.main.async {
                        self.startBtn.isHidden = false
                    }
                }
            }
        }
        
        
        //Checks if a notification has been pressed and thus a survey should be fired
        let fireNotificationSurvey = UserDefaults.standard.bool(forKey: "fireNotificationSurvey")
        
        
        if fireNotificationSurvey {
            let surveyToFire = UserDefaults.standard.string(forKey: "surveyToFire")
            self.goToSurveyURL(surveyId: surveyToFire!)
            UserDefaults.standard.set(false, forKey: "fireNotificationSurvey")
            UserDefaults.standard.set("", forKey: "surveyToFire")
        }
        
        if self.exitSurveyFired {
            Switcher.updateRootVC()
        }
        
        
    }
    
    
    // MARK: - Functions for screen load
    
    //This function is called if the study has not been started. It loads all the text, buttons etc.
    func loadBeginStudyScreen () {
        startBtn.isHidden = true
        let studyId = UserDefaults.standard.string(forKey: "studyId")
        ParseController.getStudy(studyId: studyId!).continueWith { (task) -> Any? in
            self.study = task.result! as Study
            DispatchQueue.main.async {
                self.studyTitle.text = self.study.object(forKey: "name") as? String
                self.studyDescribtion.text = self.study.object(forKey: "description") as? String
                self.studyTasks.text = self.study.object(forKey: "userTasks") as? String
                
            }
            return nil
            }.continueOnSuccessWith { (task) -> Any? in
                ParseController.getStudyConfigByStudy(self.study).continueOnSuccessWith { (task) -> Any? in
                    
                    self.studyConfig = task.result! as StudyConfig
                    
                    //Sets the surveys into accessible variables
                    self.survey1_survey = self.studyConfig.value(forKey: "survey1_survey") as! Survey
                    self.survey2_survey = self.studyConfig.value(forKey: "survey2_survey") as! Survey
                    self.survey3_survey = self.studyConfig.value(forKey: "survey3_survey") as! Survey
                    
                    //Checking if the study allows peers - if not button is hidden
                    let isPeerStudy = self.studyConfig.value(forKey: "isPeerStudy") as! Bool
                    if !isPeerStudy {
                        DispatchQueue.main.async {
                            self.addPeerBtn.isHidden = true
                        }
                    }
                    
                    //Updating the survey button labels
                    DispatchQueue.main.async {
                        self.survey1.setTitle(self.studyConfig.value(forKey: "survey1_title") as? String, for: .normal)
                        self.survey2.setTitle(self.studyConfig.value(forKey: "survey2_title") as? String, for: .normal)
                        self.survey3.setTitle(self.studyConfig.value(forKey: "survey3_title") as? String, for: .normal)
                    }
                ParseController.getStudyUserByStudyId(self.study.objectId!).continueOnSuccessWith(block: { (task) -> Any? in
                    self.studyUser = task.result! as StudyUser
                    
                    
                    //check if any of the surveys has been done. If yes, hide that particular button
                    if self.studyUser.survey1Done {
                        DispatchQueue.main.async {
                            self.survey1.isHidden = true
                        }
                    }
                    
                    if self.studyUser.survey2Done {
                        DispatchQueue.main.async {
                            self.survey2.isHidden = true
                        }
                    }
                    
                    if self.studyUser.survey3Done {
                        DispatchQueue.main.async {
                            self.survey3.isHidden = true
                        }
                    }
                    
                    if self.studyUser.survey1Done && self.studyUser.survey2Done && self.studyUser.survey3Done {
                        DispatchQueue.main.async {
                            self.startBtn.isHidden = false
                        }
                    }
                    
                    return nil
                })
                    
                return nil
            }
        }
    }
    
    
    //Loads the elements that should be shown when a study has been started and is running.
    func loadStudyRunningScreen () {
        
        startBtn.isHidden = true
        survey1.isHidden = true
        survey2.isHidden = true
        survey3.isHidden = true
        externalSurveyBtn.isHidden = true
        startBtn.isHidden = true
        self.daysInStudy.isHidden = false
        
        let studyId = UserDefaults.standard.string(forKey: "studyId")
        
        ParseController.getStudy(studyId: studyId!).continueWith { (task) -> Any? in
            self.study = task.result! as Study
            
            DispatchQueue.main.async {
                self.studyTitle.text = self.study.object(forKey: "name") as? String
                self.studyDescribtion.text = self.study.object(forKey: "description") as? String
                self.studyTasks.text = self.study.object(forKey: "userTasks") as? String
                
            }
            
            return nil
            }.continueOnSuccessWith { (task) -> Any? in
                ParseController.getStudyConfigByStudy(self.study).continueOnSuccessWith { (task) -> Any? in
                    
                    self.studyConfig = task.result! as StudyConfig
                    
                    //Checking if the study allows peers - if not button is hidden
                    let isPeerStudy = self.studyConfig.value(forKey: "isPeerStudy") as! Bool
                    if !isPeerStudy {
                        DispatchQueue.main.async {
                            self.addPeerBtn.isHidden = true
                        }
                    }
                ParseController.getStudyUserByStudyId(self.study.objectId!).continueOnSuccessWith(block: { (task) -> Any? in
                        self.studyUser = task.result! as StudyUser
                    
                        let totalDays = self.studyConfig.value(forKey: "durationDays") as! Int
                        let endDate = self.studyUser.value(forKey: "endDate") as! Date
                        let today = Date()
                        let daysLeft = Calendar.current.dateComponents([.day], from: today, to: endDate).day! as Int
                        let daysPassed = totalDays - daysLeft
                    
                    
                        DispatchQueue.main.async {
                            self.daysInStudy.text = "Thank you for being in day \(daysPassed) of \(totalDays)"
                        }
                    
                        return nil
                    })
                    
                    return nil
                }
            }
    }
    
    //Function fired if the 'info' icon is pressed. This will show a collection of options.
    @IBAction func infoPressed(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Insert options here", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let contactUsAction = UIAlertAction(title: "Contact us", style: .default, handler: sendEmailToUs)
        
        optionMenu.addAction(cancelAction)
        optionMenu.addAction(contactUsAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func resetConsents(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "consentGiven")
        
    }
    
    //Function fired when survey2 button is pressed. The button is hidden after it has been pressed.
    @IBAction func survey1Pressed(_ sender: Any) {
        if let surveyId = survey1_survey.objectId {
            goToSurveyURL(surveyId: surveyId)
            
            //Hide button when it has been pressed.
            survey1.isHidden = true
            ParseController.setSurveyDone(studyUser: studyUser, surveyNumber: 1)
        }
    }
    
    //Function fired when survey2 button is pressed. The button is hidden after it has been pressed.
    @IBAction func survey2Pressed(_ sender: Any) {
        if let surveyId = survey2_survey.objectId {
            goToSurveyURL(surveyId: surveyId)
            
            //Hide button when it has been pressed.
            survey2.isHidden = true
            ParseController.setSurveyDone(studyUser: studyUser, surveyNumber: 2)
        }
    }
    
    //Function fired when survey3 button is pressed. The button is hidden after it has been pressed.
    @IBAction func survey3Pressed(_ sender: Any) {
        if let surveyId = survey3_survey.objectId {
            goToSurveyURL(surveyId: surveyId)
            
            //Hide button when it has been pressed.
            survey3.isHidden = true
            ParseController.setSurveyDone(studyUser: studyUser, surveyNumber: 3)
        }
    }
    
    @IBAction func invitePeers(_ sender: Any) {
        
        print ("invite peer is pressed!")
        
    }
    
    
    //Creates the URL used to call the web app and then switching view to the WebView.
    private func goToSurveyURL (surveyId : String) {
        ParseController.getMqolUser().continueOnSuccessWith { (task) -> Any? in
            let mqolUser = task.result as! MqolUser
            let mqolUserId = mqolUser.objectId! 
            //self.urlString = "https://mqolweb.com/user/\(mqolUserId)/survey/\(surveyId)"
            self.urlString = "localhost:3000/user/\(mqolUserId)/survey/\(surveyId)"
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "surveyDisplayer", sender: self)
            }
            print (self.urlString)
            return nil
        }
        
    }
    
    //This function is used to give pass the URL on to the WebView.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? SurveyDisplayer
        vc?.targetURL = urlString
    }
    
    
    // MARK: - Start/quit study buttons and helper functions
    
    
    //Function called when quit study is pressed.
    @IBAction func quitStudyPressed(_ sender: Any) {
        //Creating the alarm pop up when quit study is pressed
        let quitAlert = UIAlertController(title: EnStrings.quit_study_warning_title, message: EnStrings.quit_study_warning, preferredStyle: .alert)
        
        let quitAction = UIAlertAction(title: EnStrings.quit_continue, style: .default, handler: quitHandler)
        
        let cancelAction = UIAlertAction(title: "Go back", style: .default)
        
        quitAlert.addAction(quitAction)
        quitAlert.addAction(cancelAction)
        
        self.present(quitAlert, animated: true)
    }
    
    
    //Function called when start study is pressed.
    @IBAction func startStudyPressed(_ sender: Any) {
        
        //Creating the alarm that pops up when start study is pressed
        let startAlert = UIAlertController(title: "Attention", message: "Before you move on and start the study, all previous surveys need to be completed.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Go back", style: .default)
        
        let continueAction = UIAlertAction(title: "Start survey", style: .default, handler: continueHandler)
        
        //Adding actions to pop-up alerts
        startAlert.addAction(continueAction)
        startAlert.addAction(cancelAction)
        
        self.present(startAlert, animated: true)
        
    }
    
    
    //Handler function called if user press start study on pop up alert. It is called from startStudyPressed()
    func continueHandler (_ action : UIAlertAction) {

        //Hides buttons when study is started
        survey1.isHidden = true
        survey2.isHidden = true
        survey3.isHidden = true
        externalSurveyBtn.isHidden = true
        startBtn.isHidden = true
        self.daysInStudy.isHidden = false
        
        //Schedule notifications
        let scheduleInfo = self.studyConfig.value(forKey: "notificationScheduleInfo") as! [String : Any]
        let durationDays = self.studyConfig.value(forKey: "durationDays") as! Int
        
        let scheduler = NotificationScheduler()
        scheduler.scheduleAllNotifications(info: scheduleInfo, days: durationDays)
        
        
        ParseController.startStudyCountDown(studyId: self.study.objectId!)
        UserDefaults.standard.set(true, forKey: "studyLoaded")
        
        //Load new view
        self.loadStudyRunningScreen()
        
    }
    
    //Handler function called if user press quit study on pop up alert. It is called from quitStudyPressed()
    func quitHandler (_ action : UIAlertAction) {
        ParseController.disableUserFromStudy(studyId: self.study.objectId!, status: StudyUser.STATUS_QUITED)
        ParseController.setStudyUserFlowState(studyId: self.study.objectId!, statusFlow: StudyUser.STUDY_FLOW_STATE_3)
        
        //Setting local values
        UserDefaults.standard.set(false, forKey: "studyConsentGiven")
        UserDefaults.standard.set("", forKey: "studyId")
        UserDefaults.standard.set(false, forKey: "studyLoaded")
        
        //Delete all notifications
        let manager = LocalNotificationManager()
        manager.deleteAllNotifications()
        
        let exitSurvey = self.studyConfig.value(forKey: "exitSurvey") as! PFObject
        self.goToSurveyURL(surveyId: exitSurvey.objectId!)
        ParseController.setExitSurveyDone(studyUser: self.studyUser)
        
        self.exitSurveyFired = true
    }
    
    
    // MARK: - Functions responsible for mail
    
    //Function triggered when user wants to invite peers.
    func sendEmailToPeer() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            print ("Cannot send email")
        }
    }
    
    //Function triggered when the user presses the 'contact us' button.
    func sendEmailToUs(_ action : UIAlertAction) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["you@yoursite.com"])
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            print ("Cannot send email")
        }
    }
    
    //This function dismisses the email UI when the mail has been sent.
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}