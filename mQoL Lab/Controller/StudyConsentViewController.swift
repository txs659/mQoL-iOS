//
//  StudyConsentViewController.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 09/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class StudyConsentViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.nameField.delegate = self
    }
   
    
    @IBAction func giveConsent(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "studyConsentGiven")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
