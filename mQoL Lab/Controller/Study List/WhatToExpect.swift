//
//  WhatToExpect.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 31/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class WhatToExpect: UIViewController {

    public var study = Study()
    
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        infoTitle.text = study.object(forKey: "title_whatToExpect") as? String
        infoText.text = study.object(forKey: "text_whatToExpect") as? String
    }
    

    @IBAction func nextPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "participantsRights", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? ParticipantsRights
        vc?.study = study
    }
    
}
