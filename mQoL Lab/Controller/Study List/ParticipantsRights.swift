//
//  ParticipantsRights.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 31/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class ParticipantsRights: UIViewController {

    public var study = Study()
    
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        infoTitle.text = study.object(forKey: "title_withdrawing") as? String
        infoText.text = study.object(forKey: "text_withdrawing") as? String
    }
    

    @IBAction func nextPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "risksAndBenefits", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? RiskAndBenefits
        vc?.study = study
    }
}
