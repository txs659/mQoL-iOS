//
//  StudyHomeVC.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 08/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import Parse
import UserNotifications
import MessageUI
import PDFKit
import Firebase

class StudyHomeVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    //
    //
    //
    // MARK:- Declaration of variables
    //
    //
    //
    
    //Objects are fetched when view is loaded and stored in these variables.
    var study = Study()
    var studyConfig = StudyConfig()
    var studyUser = StudyUser()
    
    //Peer specific variables
    var peer = Peer()
    var participantStudyUser = StudyUser()
    
    //Surveys are fecthed when view is loaded and stored in these variables.
    var survey1_survey = Survey()
    var survey2_survey = Survey()
    var survey3_survey = Survey()
    
    //Used in call to mqol web application
    var urlString = ""
    
    var exitSurveyFired = false
    
    var pdf = PDFDocument()
    
    let language = UserDefaults.standard.string(forKey: "language")
    let isPeer = UserDefaults.standard.bool(forKey: "isPeer")
    
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
    
    //This button is multi purpose depending on if user is peer or participant
    @IBOutlet weak var addPeerOrAssessSubjectBtn : UIButton!
    
    //
    //
    //
    // MARK:- Standard Swift load functions
    //
    //
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let isStudyStarted = UserDefaults.standard.bool(forKey: "studyLoaded")
        
        if language == "fr" {
            self.startBtn.setTitle(FrStrings.button_start_study, for: .normal)
            self.quitBtn.setTitle(FrStrings.button_quit_study, for: .normal)
            self.addPeerOrAssessSubjectBtn.setTitle(FrStrings.button_send_invitation, for: .normal)
        }
        else {
            self.startBtn.setTitle(EnStrings.button_start_study, for: .normal)
            self.quitBtn.setTitle(EnStrings.button_quit_study, for: .normal)
            self.addPeerOrAssessSubjectBtn.setTitle(EnStrings.button_send_invitation, for: .normal)
        }
        
        // Checking whether the user is a peer, a participant where the study is started, or
        // a participant where the study is not started yet. These three scenrious require
        // different UI loads.
        if isStudyStarted {
            loadStudyRunningScreen()
        } else if isPeer{
            loadPeerScreen()
        }else {
            loadBeginStudyScreen()
        }
    }
    
    
    // Check everytime survyes is done, to see if the start study button should be displyed.
    // Only relevant for participants
    override func viewWillAppear(_ animated: Bool) {
        if !isPeer {
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
    
    //
    //
    //
    // MARK: - Functions for participant screen load
    //
    //
    //
    
    //This function is called if the study has not been started. It loads all the text, buttons etc.
    func loadBeginStudyScreen () {
        startBtn.isHidden = true
        let studyId = UserDefaults.standard.string(forKey: "studyId")
        ParseController.getStudy(studyId: studyId!).continueWith { (task) -> Void in
            self.study = task.result! as Study
            DispatchQueue.main.async {
                self.studyTitle.text = self.study.object(forKey: "name") as? String
                self.studyDescribtion.text = self.study.object(forKey: "description") as? String
                self.studyTasks.text = self.study.object(forKey: "userTasks") as? String
                
            }

            }.continueOnSuccessWith { (task) -> Void in
                ParseController.getStudyConfigByStudy(self.study).continueOnSuccessWith { (task) -> Void in
                    
                    self.studyConfig = task.result! as StudyConfig
                    
                    //Sets the surveys into accessible variables
                    self.survey1_survey = self.studyConfig.value(forKey: "survey1_survey") as! Survey
                    self.survey2_survey = self.studyConfig.value(forKey: "survey2_survey") as! Survey
                    self.survey3_survey = self.studyConfig.value(forKey: "survey3_survey") as! Survey
                    
                    //Checking if the study allows peers - if not button is hidden
                    let isPeerStudy = self.studyConfig.value(forKey: "isPeerStudy") as! Bool
                    if !isPeerStudy {
                        DispatchQueue.main.async {
                            self.addPeerOrAssessSubjectBtn.isHidden = true
                        }
                    }
                    
                    //Updating the survey button labels
                    DispatchQueue.main.async {
                        self.survey1.setTitle(self.studyConfig.value(forKey: "survey1_title") as? String, for: .normal)
                        self.survey2.setTitle(self.studyConfig.value(forKey: "survey2_title") as? String, for: .normal)
                        self.survey3.setTitle(self.studyConfig.value(forKey: "survey3_title") as? String, for: .normal)
                    }
                ParseController.getStudyUserByStudyId(self.study.objectId!).continueOnSuccessWith(block: { (task) -> Void in
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
                    
                    //load external survey button
                    self.loadExternalSurveyBtn()
                })
            }
        }
    }
    
    
    //Loads the elements that should be shown when a study has been started and is running.
    func loadStudyRunningScreen () {
        
        self.startBtn.isHidden = true
        self.survey1.isHidden = true
        self.survey2.isHidden = true
        self.survey3.isHidden = true
        self.externalSurveyBtn.isHidden = true
        self.startBtn.isHidden = true
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
                ParseController.getStudyConfigByStudy(self.study).continueOnSuccessWith { (task) -> Void in
                    
                    self.studyConfig = task.result! as StudyConfig
                    

                    //Checking if the study allows peers - if not button is hidden
                    let isPeerStudy = self.studyConfig.value(forKey: "isPeerStudy") as! Bool
                    if !isPeerStudy {
                        DispatchQueue.main.async {
                            self.addPeerOrAssessSubjectBtn.isHidden = true
                        }
                    }
 
                ParseController.getStudyUserByStudyId(self.study.objectId!).continueOnSuccessWith(block: { (task) -> Void in
                        self.studyUser = task.result! as StudyUser
                    
                        let totalDays = self.studyConfig.value(forKey: "durationDays") as! Int
                        let endDate = self.studyUser.value(forKey: "endDate") as! Date
                        let today = Date()
                        let daysLeft = Calendar.current.dateComponents([.day], from: today, to: endDate).day! as Int
                        let daysPassed = totalDays - daysLeft
                    
                    
                        DispatchQueue.main.async {
                            if self.language == "fr" {
                                self.daysInStudy.text = "\(FrStrings.view_study_home_progress_1) \(daysPassed) \(FrStrings.view_study_home_progress_2) \(totalDays)"
                            }
                            else {
                                self.daysInStudy.text = "\(EnStrings.view_study_home_progress_1) \(daysPassed) \(EnStrings.view_study_home_progress_2) \(totalDays)"
                            }
                        }
                    
                        //load external survey button
                        self.loadExternalSurveyBtn()
                    })
                }
            }
    }
    
    // This function is used to load the external survey button for both participants and
    // peers
    func loadExternalSurveyBtn () {
        let externalSurveys = self.studyConfig.value(forKey: "externalSurveys") as! [[String]]
        
        if externalSurveys[0].isEmpty {
            DispatchQueue.main.async {
                self.externalSurveyBtn.isHidden = true
            }
        }
        else {
            DispatchQueue.main.async {
                let btnText = externalSurveys[0][0]
                self.externalSurveyBtn.setTitle(btnText, for: .normal)
            }
        }
    }
    
    
    //
    //
    //
    // MARK:- Functions for pressed buttons
    //
    //
    //
    
    //Function fired if the 'info' icon is pressed. This will show a collection of options.
    @IBAction func infoPressed(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
        
        //Add French strings to buttons
        if language == "fr" {
            let seeLabConsentAction = UIAlertAction(title: FrStrings.menu_item_1, style: .default, handler: seeLabAgreementHandler)
            let contactUsAction = UIAlertAction(title: FrStrings.menu_item_2, style: .default, handler: sendEmailToUs)
            let seeStudyConsentAction = UIAlertAction(title: FrStrings.menu_item_3, style: .default, handler: seeStudyAgreementHandler)
            let cancelAction = UIAlertAction(title: FrStrings.cancel_button, style: .cancel, handler: nil)
            optionMenu.addAction(seeLabConsentAction)
            optionMenu.addAction(contactUsAction)
            optionMenu.addAction(seeStudyConsentAction)
            optionMenu.addAction(cancelAction)
        }
        //Add English strings to buttons
        else {
            let seeLabConsentAction = UIAlertAction(title: EnStrings.menu_item_1, style: .default, handler: seeLabAgreementHandler)
            let contactUsAction = UIAlertAction(title: EnStrings.menu_item_2, style: .default, handler: sendEmailToUs)
            let seeStudyConsentAction = UIAlertAction(title: EnStrings.menu_item_3, style: .default, handler: seeStudyAgreementHandler)
            let cancelAction = UIAlertAction(title: EnStrings.cancel_button, style: .cancel, handler: nil)
            optionMenu.addAction(seeLabConsentAction)
            optionMenu.addAction(contactUsAction)
            optionMenu.addAction(seeStudyConsentAction)
            optionMenu.addAction(cancelAction)
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    //Function fired when survey2 button is pressed. The button is hidden after it has been pressed.
    @IBAction func survey1Pressed(_ sender: Any) {
        if let surveyId = survey1_survey.objectId {
            goToSurveyURL(surveyId: surveyId)
            
            //Hide button when it has been pressed.
            survey1.isHidden = true
            
            if !isPeer {
                ParseController.setSurveyDone(studyUser: studyUser, surveyNumber: 1)
            }
            else {
                ParseController.peerSetSurveyDone(peer: self.peer, surveyNumber: 1)
            }
        }
    }
    
    //Function fired when survey2 button is pressed. The button is hidden after it has been pressed.
    @IBAction func survey2Pressed(_ sender: Any) {
        if let surveyId = survey2_survey.objectId {
            goToSurveyURL(surveyId: surveyId)
            
            //Hide button when it has been pressed.
            survey2.isHidden = true
            
            if !isPeer {
                ParseController.setSurveyDone(studyUser: studyUser, surveyNumber: 2)
            }
            else {
                ParseController.peerSetSurveyDone(peer: self.peer, surveyNumber: 2)
            }
        }
    }
    
    //Function fired when survey3 button is pressed. The button is hidden after it has been pressed.
    @IBAction func survey3Pressed(_ sender: Any) {
        if let surveyId = survey3_survey.objectId {
            goToSurveyURL(surveyId: surveyId)
            
            //Hide button when it has been pressed.
            survey3.isHidden = true
            
            if !isPeer {
                ParseController.setSurveyDone(studyUser: studyUser, surveyNumber: 3)
            }
            else {
                ParseController.peerSetSurveyDone(peer: self.peer, surveyNumber: 3)
            }
        }
    }
    
    
    // This function has a multi purpose:
    //
    // Peer: makes the user able to assess their subject whenever they want.
    //
    // Participant: makes the user able to invite peers. The user will get asked what
    // language the mail should be in. If the device is not set up for sending mails,
    // then an alert will be displayed.
    @IBAction func invitePeerOrAssessSubject(_ sender: Any) {
        
        if isPeer {
            //If user is a peer
            
            // TODO:- Add peer survey
            
        }
        else {
            //If user is participant
            
            if self.language == "fr" {
                let alert = UIAlertController(title: FrStrings.invitation_alert_title, message: FrStrings.invitation_alert_text, preferredStyle: .alert)
                
                let englishMail = UIAlertAction(title: FrStrings.invitation_alert_option1, style: .default, handler: self.sendEmailToPeerEn)
                
                let frenchMail = UIAlertAction(title: FrStrings.invitation_alert_option2, style: .default, handler: self.sendEmailToPeerFr)
                
                let cancelAction = UIAlertAction(title: FrStrings.cancel_button, style: .default)
                
                alert.addAction(englishMail)
                alert.addAction(frenchMail)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true)
                
            }
            else {
                let alert = UIAlertController(title: EnStrings.invitation_alert_title, message: EnStrings.invitation_alert_text, preferredStyle: .alert)
                
                let englishMail = UIAlertAction(title: EnStrings.invitation_alert_option1, style: .default, handler: self.sendEmailToPeerEn)
                
                let frenchMail = UIAlertAction(title: EnStrings.invitation_alert_option2, style: .default, handler: self.sendEmailToPeerFr)
                
                let cancelAction = UIAlertAction(title: EnStrings.cancel_button, style: .default)
                
                alert.addAction(englishMail)
                alert.addAction(frenchMail)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true)
            }
            
        }
    }
    
    @IBAction func externalSurveyPressed(_ sender: Any) {
        performSegue(withIdentifier: "externalSurvey", sender: self)
    }
    
    //Handler function for displaying the lab agreement
    func seeLabAgreementHandler (_ action : UIAlertAction) {
        PFConfig.getInBackground { (config, error) in
            if error != nil {
                print (error!)
            } else {
                let file = config!["lab_agreement"] as! PFFileObject
                let pdfURL = URL(string: file.url!)
                if let pdf = PDFDocument(url: pdfURL!) {
                    self.pdf = pdf
                    self.performSegue(withIdentifier: "readPDF", sender: self)
                }
            }
        }
    }
    
    //Handler function for displaying the study agreement
    func seeStudyAgreementHandler (_ action : UIAlertAction) {
        let query = PFQuery(className: study.parseClassName)
        query.getObjectInBackground(withId: study.objectId!) { (object, error) in
            if (error == nil && object != nil) {
                let file = object!["informedConsent"] as! PFFileObject
                let pdfURL = URL(string: file.url!)
                if let pdf = PDFDocument(url: pdfURL!) {
                    self.pdf = pdf
                    self.performSegue(withIdentifier: "readPDF", sender: self)
                }
                else {
                    print ("PDF file not found")
                }
                
            }
            else {
                print (error!)
            }
        }
    }
    
    
    
    //
    //
    //
    // MARK:- Segue specific functions
    //
    //
    //
    
    
    //Creates the URL used to call the web app and then switching view to the WebView.
    private func goToSurveyURL (surveyId : String) {
        ParseController.getMqolUser().continueOnSuccessWith { (task) -> Void in
            let mqolUser = task.result as! MqolUser
            let mqolUserId = mqolUser.objectId! 
            self.urlString = "https://qol1.unige.ch/mqol-web/user/\(mqolUserId)/survey/\(surveyId)"
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "surveyDisplayer", sender: self)
            }
            print (self.urlString)
        }
        
    }
    
    //This function is used to pass data onto the UIWebView or the external survey view.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "surveyDisplayer" {
            let vc = segue.destination as? SurveyDisplayerVC
            vc?.targetURL = urlString
        }
        else if segue.identifier == "externalSurvey" {
            let vc = segue.destination as? ExternalSurveyVC
            vc?.externalSurveyInfo = self.studyConfig.value(forKey: "externalSurveys") as! [[String]]
        }
        else if segue.identifier == "readPDF" {
            let vc = segue.destination as? readPDFVC
            vc?.pdfFile = self.pdf
        }
        
    }
    
    //
    //
    //
    // MARK: - Start/quit study buttons and helper functions
    //
    //
    //
    
    
    //Function called when quit study is pressed.
    @IBAction func quitStudyPressed(_ sender: Any) {
        //Creating the alarm pop up when quit study is pressed
        
        if self.language == "fr" {
            let quitAlert = UIAlertController(title: FrStrings.quit_study_warning_title, message: FrStrings.quit_study_warning, preferredStyle: .alert)
            
            let quitAction = UIAlertAction(title: FrStrings.quit_continue, style: .default, handler: quitHandler)
            
            let cancelAction = UIAlertAction(title: FrStrings.quit_abort, style: .default)
            
            quitAlert.addAction(quitAction)
            quitAlert.addAction(cancelAction)
            self.present(quitAlert, animated: true)
        }
        else {
            let quitAlert = UIAlertController(title: EnStrings.quit_study_warning_title, message: EnStrings.quit_study_warning, preferredStyle: .alert)
            
            let quitAction = UIAlertAction(title: EnStrings.quit_continue, style: .default, handler: quitHandler)
            
            let cancelAction = UIAlertAction(title: EnStrings.quit_abort, style: .default)
            
            quitAlert.addAction(quitAction)
            quitAlert.addAction(cancelAction)
            self.present(quitAlert, animated: true)
        }
    }
    
    
    //Function called when start study is pressed.
    @IBAction func startStudyPressed(_ sender: Any) {
        
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
    
    // Handler function called if user press quit study on pop up alert. It is called from
    // quitStudyPressed()
    func quitHandler (_ action : UIAlertAction) {
        
        if isPeer {
            //Do peer specific quit actions
            
            //Change local 'is peer' flag to false
            UserDefaults.standard.set(false, forKey: "isPeer")
            
            //Fire exit survey
            let exitSurvey = self.studyConfig.value(forKey: "exitSurveyPeer") as! PFObject
            self.goToSurveyURL(surveyId: exitSurvey.objectId!)
            ParseController.peerSetExitSurveyDone(peer: self.peer)
            self.exitSurveyFired = true
        }
        else {
            //Do participant specific quit actions
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
    }
    
    //
    //
    //
    // MARK: - Functions responsible for mail
    //
    //
    //
    
    //Function that creates Firebase Dynamic Link
    func createDynamicLink() {
        let studyUserId = self.studyUser.objectId! as String
        
        var components = URLComponents()
        components.scheme = "http"
        components.host = "www.qol.unige.ch"
        components.path = "/studyUser"
        
        let studyUserIdQueryItem = URLQueryItem(name: "studyUser", value: studyUserId)
        components.queryItems = [studyUserIdQueryItem]
        
        guard let linkParameter = components.url else { return }
        
        let shareLink = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://h62ek.app.goo.gl")
        
        if let bundleId = Bundle.main.bundleIdentifier {
            shareLink?.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleId)
        }
        
        shareLink?.iOSParameters?.appStoreID = "1466061031"
        
        shareLink?.androidParameters = DynamicLinkAndroidParameters(packageName: "ch.unige.mqol.studymanager")
        
        guard let longURL = shareLink?.url else { return }
        
        print("longURL: \(longURL)")
        
        shareLink?.shorten(completion: { (url, warnings, error) in
            if let error = error {
                print ("FDL errror: \(error)")
            }
            if let warnings = warnings {
                for warning in warnings {
                    print ("FDL warning: \(warning)")
                }
            }
            guard let url = url else { return }
            print("Short link: \(url)")
        })
        
        
    }
    
    //Function triggered when user wants to invite peers - English version.
    func sendEmailToPeerEn(_ action : UIAlertAction) {
        if MFMailComposeViewController.canSendMail() {
            
            //Create deeplink for Firebase
            let deeplink = "https://google.com"
            self.createDynamicLink()
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject(EnStrings.invitation_message)
            mail.setMessageBody("<![CDATA[<p><em>Hello</em></p><p>Your friend, the sender of this message is inviting you to participate in a research study for a new data collection method to explore the role of peers in the assessment of human stress.</p><p>Your contributions as a peer will help us to enhance the accuracy of computer algorithms that are being designed to improve stress awareness. As a peer in this study, you will receive notifications to answer short surveys regarding the person who invited you to this study.&nbsp;</p><p>Please <a href=\"\(deeplink)\">install this application</a> to get started.</p><p>Please do not hesitate to contact the person who sent you this invitation so that you can receive more details about the study. You can also contact the researchers and request further clarifications at any moment.&nbsp;</p><p>CONTACT INFORMATION: &nbsp;If you have any questions, concerns or complaints about this research, its procedures, risks,&nbsp;and benefits, contact the Protocol Director, <a href=\"mailto:Katarzyna.Wac@unige.ch\">Katarzyna Wac</a></p><p>You can also contact the second investigator <a href=\"mailto:allan.berrocal@unige.ch\">Allan Berrocal</a> ISS, Center for Informatics, University of Geneva. Battelle B&acirc;timent A. Office 230. 7, route de Drize, 1227 Carouge, Switzerland Ph. +41 022 379 02 42</p><p>Thank you in advance for your invaluable collaboration.</p><p>&nbsp;</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            //If device is not setup for sending emails, display a warning to user
            
            //Check if language is French or English and create the alert accordingly
            if self.language == "fr" {
                let alert = UIAlertController(title: FrStrings.email_failed_title, message: FrStrings.email_failed_text, preferredStyle: .alert)
                let okAction = UIAlertAction(title: FrStrings.back_button, style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: EnStrings.email_failed_title, message: EnStrings.email_failed_text, preferredStyle: .alert)
                let okAction = UIAlertAction(title: EnStrings.back_button, style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            }
        }
    }
    
    //Function triggered when user wants to invite peers - French version.
    func sendEmailToPeerFr(_ action : UIAlertAction) {
        if MFMailComposeViewController.canSendMail() {
            
            //Create deeplink for Firebase
            let deeplink = "https://google.com"
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject(FrStrings.invitation_message)
            mail.setMessageBody("<![CDATA[<p>Vous avez reçu cette invitation de votre ami-e pour participer à une étude sur le stress humain.</p><p>Avec votre participation, nous espérons améliorer la précision des algorithmes informatiques que nous créons pour aider les personnes qui souffrent de stress. En tant qu\'ami d\'un participant à l\'étude vous rapportez, dans ces courts sondages, ce que vous percevez de votre ami en ce qui concerne le stress.</p><p>Veuillez <a href=\"\(deeplink)\">installer cette application</a> pour commencer.</p><p>N\'hésitez pas à contacter la personne qui vous a envoyé cette invitation afin de recevoir plus de détails sur l\'étude. Vous pouvez également contacter les chercheurs.&nbsp;</p><p>CONTACT: &nbsp;Si vous avez des questions, des préoccupations ou des plaintes concernant cette recherche, ses procédures, ses risques et ses avantages, contactez la directrice du protocole, la <a href=\"mailto:Katarzyna.Wac@unige.ch\">Prof. Katarzyna Wac</a>. Il vous est également possible de contacter le deuxième chercheur, M. <a href=\"mailto:allan.berrocal@unige.ch\">Allan Berrocal</a> Institut de Science de Service Informationnel (ISS), Centre Universitaire d\'informatique (CUI), Université de Genève, Battelle, B&acirc;timent A. Bureau 230. 7, route de Drize, 1227 Carouge, Suisse Tél. +41 022 379 02 42</p><p>Merci d\'avance pour votre précieuse collaboration.</p><p>&nbsp;</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            //If device is not setup for sending emails, display a warning to user
            
            //Check if language is French or English and create the alert accordingly
            if self.language == "fr" {
                let alert = UIAlertController(title: FrStrings.email_failed_title, message: FrStrings.email_failed_text, preferredStyle: .alert)
                let okAction = UIAlertAction(title: FrStrings.back_button, style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: EnStrings.email_failed_title, message: EnStrings.email_failed_text, preferredStyle: .alert)
                let okAction = UIAlertAction(title: EnStrings.back_button, style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            }
        }
    }
    
    //Function triggered when the user presses the 'contact us' button.
    func sendEmailToUs(_ action : UIAlertAction) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["qol.unige@gmail.com"])
            
            let mqolUser = self.studyUser.value(forKey: "mqolUser") as! PFObject
            let mqolUserId = mqolUser.objectId
            
            if language == "fr" {
                mail.setSubject(FrStrings.contactUsEmail_subject)
                mail.setMessageBody(FrStrings.contactUsEmail_text + " \(mqolUserId!)", isHTML: true)
            }
            else {
                mail.setSubject(EnStrings.contactUsEmail_subject)
                mail.setMessageBody(EnStrings.contactUsEmail_text + " \(mqolUserId!)", isHTML: true)
            }
            present(mail, animated: true)
        } else {
            //If device is not setup for sending emails, display a warning to user
            
            //Check if language is French or English and create the alert accordingly
            if self.language == "fr" {
                let alert = UIAlertController(title: FrStrings.email_failed_title, message: FrStrings.email_failed_text, preferredStyle: .alert)
                let okAction = UIAlertAction(title: FrStrings.back_button, style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: EnStrings.email_failed_title, message: EnStrings.email_failed_text, preferredStyle: .alert)
                let okAction = UIAlertAction(title: EnStrings.back_button, style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            }
        }
    }
    
    //This function dismisses the email UI when the mail has been sent.
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
    //
    //
    //
    // MARK: - Peer specific functions
    //
    //
    //
    
    func loadPeerScreen() {
        //Hiding a label not relevant for peer
        daysInStudy.isHidden = true
        startBtn.isHidden = true
        
        if self.language == "fr" {
            self.addPeerOrAssessSubjectBtn.setTitle(FrStrings.button_assess_paritcipant, for: .normal)
        }
        else {
            self.addPeerOrAssessSubjectBtn.setTitle(EnStrings.button_assess_paritcipant, for: .normal)
        }
        
        ParseController.getPeer().continueOnSuccessWith { (task) -> Void in
            self.peer = task.result!
            self.participantStudyUser = self.peer.getParticipant()
            self.participantStudyUser.fetchInBackground().continueOnSuccessWith(block: { (task) -> Void in
                self.participantStudyUser = task.result! as! StudyUser
                self.study = self.participantStudyUser.getStudy()
                self.study.fetchInBackground().continueOnSuccessWith(block: { (task) -> Void in
                    self.study = task.result! as! Study
                    DispatchQueue.main.async {
                        self.studyTitle.text = self.study.value(forKey: "name") as? String
                        self.studyDescribtion.text = self.study.value(forKey: "observersDescription") as? String
                        self.studyTasks.text = self.study.value(forKey: "observerTasks") as? String
                    }
                    ParseController.getStudyConfigByStudy(self.study).continueOnSuccessWith(block: { (task) -> Void in
                        self.studyConfig = task.result!
                        
                        self.survey1_survey = self.studyConfig.value(forKey: "survey1_survey_peer") as! Survey
                        self.survey2_survey = self.studyConfig.value(forKey: "survey2_survey_peer") as! Survey
                        self.survey3_survey = self.studyConfig.value(forKey: "survey3_survey_peer") as! Survey
                        
                        //Hide survey buttons if they are already done
                        if (self.peer.value(forKey: "survey1Done") as! Bool) {
                            DispatchQueue.main.async {
                                self.survey1.isHidden = true
                            }
                        }
                        if (self.peer.value(forKey: "survey2Done") as! Bool) {
                            DispatchQueue.main.async {
                                self.survey2.isHidden = true
                            }
                        }
                        if (self.peer.value(forKey: "survey3Done") as! Bool) {
                            DispatchQueue.main.async {
                                self.survey3.isHidden = true
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.survey1.setTitle(self.studyConfig.value(forKey: "survey1_title_peer") as? String, for: .normal)
                            self.survey2.setTitle(self.studyConfig.value(forKey: "survey2_title_peer") as? String, for: .normal)
                            self.survey3.setTitle(self.studyConfig.value(forKey: "survey3_title_peer") as? String, for: .normal)
                        }
                        
                        //load external survey button
                        self.loadExternalSurveyBtn()
                        
                    })
                    
                })
            })
        }
        
    }
    
}
