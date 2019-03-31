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
        
        // Do any additional setup after loading the view.
        
        welcomeTitle.text = study.object(forKey: "title_welcome") as? String
        quickFacts.text = study.object(forKey: "quickFacts") as? String
        welcomeText.text = study.object(forKey: "text_welcome") as? String
        
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
