//
//  LabConsent.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 08/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import Parse

class LabConsent: UIViewController {
    
    // Labels that needs strings injected
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var downloadAgreement: UIButton!
    @IBOutlet weak var switchLabel1: UILabel!
    @IBOutlet weak var switchLabel2: UILabel!
    @IBOutlet weak var subtext1: UILabel!
    @IBOutlet weak var subtext2: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    
    // Switches
    @IBOutlet weak var over18Switch: UISwitch!
    @IBOutlet weak var readAndAcceptSwitch: UISwitch!
    
    var over18 : Bool = false
    var readAndAccepted : Bool = false
    
    let alert = UIAlertController(title: "Agreement missing", message: "You need to agree to all the terms in order to continue", preferredStyle: .alert)
    
    let language = UserDefaults.standard.string(forKey: "language")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Injecting strings into labels
        if language == "fr" { // If preffered language is French
            pageTitle.text = FrStrings.view_lab_consent
            text1.text = FrStrings.view_lab_consent_p1
            downloadAgreement.setTitle(FrStrings.view_lab_consent_download , for: .normal)
            switchLabel1.text = FrStrings.checkbox_age
            switchLabel2.text = FrStrings.view_lab_consent_chkbox_1
            subtext1.text = FrStrings.view_lab_consent_email_agree
            subtext2.text = FrStrings.view_lab_consent_not_agree
            acceptBtn.setTitle(FrStrings.view_lab_agreement, for: .normal)
            navigationItem.backBarButtonItem?.title = FrStrings.back_button
            navigationItem.leftBarButtonItem?.title = FrStrings.back_button
        }
        else { // Else it is set to English
            pageTitle.text = EnStrings.view_lab_consent
            text1.text = EnStrings.view_lab_consent_p1
            downloadAgreement.setTitle(EnStrings.view_lab_consent_download , for: .normal)
            switchLabel1.text = EnStrings.checkbox_age
            switchLabel2.text = EnStrings.view_lab_consent_chkbox_1
            subtext1.text = EnStrings.view_lab_consent_email_agree
            subtext2.text = EnStrings.view_lab_consent_not_agree
            acceptBtn.setTitle(EnStrings.view_lab_agreement, for: .normal)
            navigationItem.backBarButtonItem?.title = EnStrings.back_button
        }
        
        // Adding actions to switches
        if let switch1 = over18Switch {
            switch1.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        }
        
        if let switch2 = readAndAcceptSwitch {
            switch2.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        }
        
        // Adding action to alert
        alert.addAction(UIAlertAction(title: "Ok", style: .default))

    }
    
    //Changing the bool variables for the switches when turned on/off
    @objc func stateChanged(switchState: UISwitch) {
        if switchState.isOn && switchState == over18Switch {
            over18 = true
        } else if switchState.isOn && switchState == readAndAcceptSwitch{
            readAndAccepted = true
        } else if !switchState.isOn && switchState == over18Switch{
            over18 = false
        } else if !switchState.isOn && switchState == readAndAcceptSwitch{
            readAndAccepted = false
        }
    }
    
    
    @IBAction func giveConsent(_ sender: Any) {
        if over18 && readAndAccepted {
            ParseController.mqolUserAcceptLabAgreement()
            UserDefaults.standard.set(true, forKey: "consentGiven")
            performSegue(withIdentifier: "ourLabThankYou", sender: self)
        } else {
            self.present(alert, animated: true)
        }
        
    }
    

}
