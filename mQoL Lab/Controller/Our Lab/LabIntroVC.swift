//
//  LabIntroVC.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 02/04/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class LabIntroVC: UIViewController {
    
    let language = UserDefaults.standard.string(forKey: "language")
    
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var text2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if language == "fr" {
            navigationItem.backBarButtonItem?.title = FrStrings.back_button
            navigationItem.rightBarButtonItem?.title = FrStrings.next_button
            infoTitle.text = FrStrings.view_lab_intro
            text1.text = FrStrings.view_lab_intro_p1
            text2.text = FrStrings.view_lab_intro_p2
        }
        else {
            navigationItem.backBarButtonItem?.title = EnStrings.back_button
            navigationItem.rightBarButtonItem?.title = EnStrings.next_button
            infoTitle.text = EnStrings.view_lab_intro
            text1.text = EnStrings.view_lab_intro_p1
            text2.text = EnStrings.view_lab_intro_p2
        }
    }
    
    @IBAction func nextPressed (_ sender: Any) {
        let isPeer = UserDefaults.standard.bool(forKey: "isPeer")
        if isPeer {
            UserDefaults.standard.set(true, forKey: "peerLabScreenSeen")
            Switcher.updateRootVC()
        } else {
            performSegue(withIdentifier: "goToAbout", sender: self)
        }
        
    }
    
}
