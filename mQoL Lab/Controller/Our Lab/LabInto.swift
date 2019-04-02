//
//  LabInto.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 02/04/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class LabInto: UIViewController {
    
    let language = UserDefaults.standard.string(forKey: "language")
    
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var text2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if language == "fr" {
            navigationItem.rightBarButtonItem?.title = FrStrings.next_button
            infoTitle.text = FrStrings.view_lab_intro
            text1.text = FrStrings.view_lab_intro_p1
            text2.text = FrStrings.view_lab_intro_p2
        }
        else {
            navigationItem.rightBarButtonItem?.title = EnStrings.next_button
            infoTitle.text = EnStrings.view_lab_intro
            text1.text = EnStrings.view_lab_intro_p1
            text2.text = EnStrings.view_lab_intro_p2
        }
    }
}
