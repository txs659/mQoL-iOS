//
//  OurLabConsentVC.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 08/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import Parse

class OurLabConsentViewController: UIViewController {

    @IBOutlet weak var over18Switch: UISwitch!
    @IBOutlet weak var readAndAcceptSwitch: UISwitch!
    
    var over18 : Bool = false
    var readAndAccepted : Bool = false
    
    let alert = UIAlertController(title: "Agreement missing", message: "You need to agree to all the terms in order to continue", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
