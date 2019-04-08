//
//  AboutTheStudies.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 02/04/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class AboutTheStudies: UIViewController {

    let language = UserDefaults.standard.string(forKey: "language")
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var text: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if language == "fr" {
            navigationItem.backBarButtonItem?.title = FrStrings.back_button
            navigationItem.rightBarButtonItem?.title = FrStrings.next_button
            pageTitle.text = FrStrings.view_lab_studies_intro
            text.text = FrStrings.view_lab_studies_intro_p1
            
        }
        else {
            navigationItem.backBarButtonItem?.title = EnStrings.back_button
            navigationItem.rightBarButtonItem?.title = EnStrings.next_button
            pageTitle.text = EnStrings.view_lab_studies_intro
            text.text = EnStrings.view_lab_studies_intro_p1
        }
        
    }
    

}
