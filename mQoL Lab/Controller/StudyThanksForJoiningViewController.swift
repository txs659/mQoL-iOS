//
//  StudyThanksForJoiningViewController.swift
//  mQoL Lab 1
//
//  Created by Frederik Schmøde on 16/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class StudyThanksForJoiningViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goToStudyHome(_ sender: Any) {
        Switcher.updateRootVC()
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
