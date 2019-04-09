//
//  StudyConsent.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 09/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class StudyConsent: UIViewController, UITextFieldDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        
    }
   
    
    @IBAction func giveConsent(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "studyConsentGiven")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func downloadConsentPressed(_ sender: Any) {
    }
    
}
