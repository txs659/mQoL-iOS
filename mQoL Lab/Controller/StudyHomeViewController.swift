//
//  StudyHomeViewController.swift
//  mQoL Lab 1
//
//  Created by Frederik Schmøde on 08/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class StudyHomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func resetConsents(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "consentGiven")
        UserDefaults.standard.set(false, forKey: "studyConsentGiven")
        Switcher.updateRootVC()
    }
    
}
