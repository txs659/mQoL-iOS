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

    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        infoTitle.text = study.object(forKey: "title_benefits") as? String
        infoText.text = study.object(forKey: "text_benefits") as? String
    }
    

    @IBAction func nextPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toConsent", sender: self)
    }
    
    
    
}
