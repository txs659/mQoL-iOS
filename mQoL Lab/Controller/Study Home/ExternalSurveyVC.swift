//
//  ExternalSurveyVC.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 18/05/2019.
//  Copyright © 2019 mQoL. All rights reserved.
//

import UIKit

class ExternalSurveyVC: UIViewController {
    
    public var externalSurveyInfo = [[]]
    
    let language = UserDefaults.standard.string(forKey: "language")
    
    @IBOutlet var pageTitle : UILabel!
    @IBOutlet var text1 : UILabel!
    @IBOutlet var text2 : UILabel!
    @IBOutlet var inEnglish : UILabel!
    @IBOutlet var link1 : UILabel!
    @IBOutlet var inFrench : UILabel!
    @IBOutlet var link2 : UILabel!
    @IBOutlet var uniqueCode : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fullUserName = ParseController.getCurrentParseUser().value(forKey: "username")! as! String
        let username = fullUserName.prefix(8)
            
        if self.language == "fr" {
            self.pageTitle.text = FrStrings.external_survey_title
            self.text1.text = FrStrings.external_survey_1
            
            self.inEnglish.text = FrStrings.external_survey_2a
            self.inFrench.text = FrStrings.external_survey_2b
            
            self.uniqueCode.text = FrStrings.external_survey_3 + " " + username
        }
        else {
            self.pageTitle.text = EnStrings.external_survey_title
            self.text1.text = EnStrings.external_survey_1
            
            self.inEnglish.text = EnStrings.external_survey_2a
            self.inFrench.text = EnStrings.external_survey_2b
            
            self.uniqueCode.text = EnStrings.external_survey_3 + " " + username
        }
        
        self.text2.text = self.externalSurveyInfo[0][1] as? String
        self.link1.text = self.externalSurveyInfo[0][2] as? String
        self.link2.text = self.externalSurveyInfo[0][3] as? String
        
        
    }
    

    
    @IBAction func backBtnPressed (_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
