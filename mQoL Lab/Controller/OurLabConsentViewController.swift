//
//  OurLabConsentVC.swift
//  mQoL Lab 1
//
//  Created by Frederik Schmøde on 08/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class OurLabConsentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func giveConsent(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "consentGiven")
    }
    
    @IBAction func seeStudies(_ sender: Any) {
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
