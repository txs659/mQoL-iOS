//
//  RiskAndBenefits.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 31/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class RiskAndBenefits: UIViewController {
    
    public var study = Study()
    
    let language = UserDefaults.standard.string(forKey: "language")

    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        infoTitle.text = study.object(forKey: "title_benefits") as? String
        infoText.text = study.object(forKey: "text_benefits") as? String
        
        if language == "fr" {
            navigationItem.backBarButtonItem?.title = FrStrings.back_button
            navigationItem.rightBarButtonItem?.title = FrStrings.next_button
        }
        else {
            navigationItem.backBarButtonItem?.title = EnStrings.back_button
            navigationItem.rightBarButtonItem?.title = EnStrings.next_button
        }
    }
    

    @IBAction func nextPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toConsent", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? StudyConsent
        vc?.study = study
    }
    
    
    
}
