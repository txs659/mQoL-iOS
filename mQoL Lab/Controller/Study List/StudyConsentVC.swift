//
//  StudyConsentVC.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 09/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import PDFKit
import Parse

class StudyConsentVC: UIViewController, UITextFieldDelegate {
    
    public var study = Study()
    
    var pdf = PDFDocument()
    
    let language = UserDefaults.standard.string(forKey: "language")

    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var switch1: UISwitch!
    @IBOutlet weak var switch1Label: UILabel!
    @IBOutlet weak var switch2: UISwitch!
    @IBOutlet weak var switch2Label: UILabel!
    @IBOutlet weak var switch3: UISwitch!
    @IBOutlet weak var switch3Label: UILabel!
    @IBOutlet weak var switch4: UISwitch!
    @IBOutlet weak var switch4Label: UILabel!
    @IBOutlet weak var switch5: UISwitch!
    @IBOutlet weak var switch5Label: UILabel!
    @IBOutlet weak var switch6: UISwitch!
    @IBOutlet weak var switch6Label: UILabel!
    @IBOutlet weak var subtext1: UILabel!
    @IBOutlet weak var subtext2: UILabel!
    @IBOutlet weak var AcceptBtn: UIButton!
    
    @IBOutlet weak var pdfView: PDFView!
    
    // Bools checking if switches has been set to on/true
    var switch1Accepted : Bool = false
    var switch2Accepted : Bool = false
    var switch3Accepted : Bool = false
    var switch4Accepted : Bool = false
    var switch5Accepted : Bool = false
    var switch6Accepted : Bool = false
    
    //Creating the alarm that pops up, if not all switches has been pressed
    let alert = UIAlertController(title: "Agreement missing", message: "You need to write your full name and agree to all the terms in order to continue", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameField.delegate = self
        
        if language == "fr" {
            navigationItem.backBarButtonItem?.title = FrStrings.back_button
            navigationItem.rightBarButtonItem?.title = FrStrings.next_button
            pageTitle.text = FrStrings.view_study_consent
            text.text = FrStrings.view_study_consent_p1
            downloadBtn.setTitle(FrStrings.view_study_agreement_download, for: .normal)
            nameField.attributedPlaceholder = NSAttributedString(string: FrStrings.view_study_name_surname)
            switch1Label.text = FrStrings.checkbox_age
            switch2Label.text = FrStrings.view_study_consent_ethics_1
            switch3Label.text = FrStrings.view_study_consent_ethics_2
            switch4Label.text = FrStrings.view_study_consent_ethics_3
            switch5Label.text = FrStrings.view_study_consent_ethics_4
            switch6Label.text = FrStrings.view_study_consent_ethics_5
            subtext1.text = FrStrings.view_study_consent_email_agree
            subtext2.text = FrStrings.view_study_consent_not_agree
            AcceptBtn.setTitle(FrStrings.view_study_agreement, for: .normal)
            
            
        }
        else {
            navigationItem.backBarButtonItem?.title = EnStrings.back_button
            navigationItem.rightBarButtonItem?.title = EnStrings.next_button
            pageTitle.text = EnStrings.view_study_consent
            text.text = EnStrings.view_study_consent_p1
            downloadBtn.setTitle(EnStrings.view_study_agreement_download, for: .normal)
            nameField.attributedPlaceholder = NSAttributedString(string: EnStrings.view_study_name_surname)
            switch1Label.text = EnStrings.checkbox_age
            switch2Label.text = EnStrings.view_study_consent_ethics_1
            switch3Label.text = EnStrings.view_study_consent_ethics_2
            switch4Label.text = EnStrings.view_study_consent_ethics_3
            switch5Label.text = EnStrings.view_study_consent_ethics_4
            switch6Label.text = EnStrings.view_study_consent_ethics_5
            subtext1.text = EnStrings.view_study_consent_email_agree
            subtext2.text = EnStrings.view_study_consent_not_agree
            AcceptBtn.setTitle(EnStrings.view_study_agreement, for: .normal)
        }
        
        // Adding actions to switches
        if let switch1 = switch1 {
            switch1.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        }
        if let switch2 = switch2 {
            switch2.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        }
        if let switch3 = switch3 {
            switch3.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        }
        if let switch4 = switch4 {
            switch4.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        }
        if let switch5 = switch5 {
            switch5.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        }
        if let switch6 = switch6 {
            switch6.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        }
        
        // Adding action to alert
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
    }
    
    //Changing the bool variables for the switches when turned on/off
    @objc func stateChanged(switchState: UISwitch) {
        if switchState.isOn && switchState == switch1 {
            switch1Accepted = true
        } else if switchState.isOn && switchState == switch2 {
            switch2Accepted = true
        } else if switchState.isOn && switchState == switch3 {
            switch3Accepted = true
        } else if switchState.isOn && switchState == switch4 {
            switch4Accepted = true
        } else if switchState.isOn && switchState == switch5 {
            switch5Accepted = true
        } else if switchState.isOn && switchState == switch6 {
            switch6Accepted = true
        } else if !switchState.isOn && switchState == switch1{
            switch1Accepted = false
        } else if !switchState.isOn && switchState == switch2{
            switch2Accepted = false
        } else if !switchState.isOn && switchState == switch3{
            switch3Accepted = false
        } else if !switchState.isOn && switchState == switch4{
            switch4Accepted = false
        } else if !switchState.isOn && switchState == switch5{
            switch5Accepted = false
        } else if !switchState.isOn && switchState == switch6{
            switch6Accepted = false
        }
    }
   
    
    @IBAction func giveConsent(_ sender: Any) {
        let nameFieldText : String = nameField.text!
        if switch1Accepted && switch2Accepted && switch3Accepted && switch4Accepted && switch5Accepted && switch6Accepted && !nameFieldText.isEmpty {
            UserDefaults.standard.set(true, forKey: "studyConsentGiven")
            
            
            /*
            //Creating a 'StudyUser' object for the user. This means that the user now has
            //fully joined a specific study
            */
            ParseController.createStudyUser(studyId: study.objectId!, name : nameFieldText)
            
            //Save studyId in local storage, so it is easy to access
            UserDefaults.standard.set(study.objectId!, forKey: "studyId")
            
            
            //Moving on to the 'thank you' screen
            performSegue(withIdentifier: "studyThankYou", sender: self)
        }
        // If all switches has not been clicked or if the name field is empty display alert.
        else {
            self.present(alert, animated: true)
        }
    }
    
    //Function that makes keyboard dismiss when 'return' is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Downloads PDF file from Parse and displays it on PDFView
    @IBAction func downloadPressed(_ sender: Any) {
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
    
    // Sends the PDF file to the PDFView for display
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "readPDF" {
            let vc = segue.destination as? readPDFVC
            vc?.pdfFile = self.pdf
        }
    }
    
}
