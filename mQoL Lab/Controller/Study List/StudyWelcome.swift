//
//  StudyWelcome.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 31/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class StudyWelcome: UIViewController {
    
    public var study = Study()
    
    @IBOutlet weak var welcomeTitle: UILabel!
    @IBOutlet weak var quickFacts: UILabel!
    @IBOutlet weak var welcomeText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeTitle.text = study.object(forKey: "title_welcome") as? String
        quickFacts.text = study.object(forKey: "quickFacts") as? String
        welcomeText.text = study.object(forKey: "text_welcome") as? String
        
    }

    @IBAction func nextPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "answeringSurveys", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? AnsweringSurveys
        vc?.study = study
    }
    
}
