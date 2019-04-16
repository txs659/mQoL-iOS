//
//  StudyHomeViewController.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 08/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import Parse
import SafariServices

class StudyHomeViewController: UIViewController {
    
    var study = Study()
    var studyConfig = StudyConfig()
    
    @IBOutlet weak var studyTitle : UILabel!
    @IBOutlet weak var studyDescribtion : UILabel!
    @IBOutlet weak var studyTasks : UILabel!
    
    @IBOutlet weak var survey1 : UIButton!
    @IBOutlet weak var survey2 : UIButton!
    @IBOutlet weak var survey3 : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                DispatchQueue.main.async {
                    self.survey1.setTitle(self.studyConfig.value(forKey: "survey1_title") as? String, for: .normal)
                    self.survey2.setTitle(self.studyConfig.value(forKey: "survey2_title") as? String, for: .normal)
                    self.survey3.setTitle(self.studyConfig.value(forKey: "survey3_title") as? String, for: .normal)
                }
                print (self.studyConfig)
                return nil
            }
        }
        
        
    }
        
    @IBAction func infoPressed(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Insert options here", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func resetConsents(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "consentGiven")
    }
    
    @IBAction func survey1Pressed(_ sender: Any) {
        print ("Survey1 pressed")
        let url : URL = URL(string: "https://www.google.com/")!
        let safariController = SFSafariViewController(url: url)
        self.present(safariController, animated: true, completion: nil)
    }
    
    @IBAction func survey2Pressed(_ sender: Any) {
        print ("Survey2 pressed")
    }
    
    @IBAction func survey3Pressed(_ sender: Any) {
        print ("Survey3 pressed")
    }
    
    @IBAction func quitStudyPressed(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "studyConsentGiven")
        UserDefaults.standard.set("", forKey: "studyId")
        
        //Insert cleaner functions for StudyUser table here
        
        
        Switcher.updateRootVC()
    }
    
}
