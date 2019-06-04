//
//  StudyThanksVC.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 16/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class StudyThanksVC: UIViewController {
    
    let language = UserDefaults.standard.string(forKey: "language")

    override func viewDidLoad() {
        super.viewDidLoad()

        //Setting the language for navigation buttons depending on device language
        if language == "fr" {
            navigationItem.backBarButtonItem?.title = FrStrings.back_button
            navigationItem.rightBarButtonItem?.title = FrStrings.next_button
        }
        else {
            navigationItem.backBarButtonItem?.title = EnStrings.back_button
            navigationItem.rightBarButtonItem?.title = EnStrings.next_button
        }
    }
    
    @IBAction func goToStudyHome(_ sender: Any) {
        Switcher.updateRootVC()
    }

}
