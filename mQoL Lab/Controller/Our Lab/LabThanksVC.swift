//
//  LabThanksVC.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 31/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class LabThanksVC: UIViewController {
    
    let language = UserDefaults.standard.string(forKey: "language")

    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var seeStudiesBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if language == "fr" {
            pageTitle.text = FrStrings.view_lab_consent_thanks
            text.text = FrStrings.view_lab_consent_thanks_p1
            seeStudiesBtn.setTitle(FrStrings.view_lab_see_studies, for: .normal)
        }
        else {
            pageTitle.text = EnStrings.view_lab_consent_thanks
            text.text = EnStrings.view_lab_consent_thanks_p1
            seeStudiesBtn.setTitle(EnStrings.view_lab_see_studies, for: .normal)
        }
    }
    
    @IBAction func seeStudiesPressed(_ sender: Any) {
        Switcher.updateRootVC()
    }
    
    

}
