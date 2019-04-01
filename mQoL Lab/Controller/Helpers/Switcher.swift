//
//  Switcher.swift
//  mQoL Lab 1
//
//  Created by Frederik Schmøde on 08/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class Switcher {

    static func updateRootVC() {
        
        print ("I got to here")
        
        let consentGiven = UserDefaults.standard.bool(forKey: "consentGiven")
        let studyConsentGiven = UserDefaults.standard.bool(forKey: "studyConsentGiven")
        
        var rootVC : UIViewController?
        
        
        if (consentGiven && !studyConsentGiven) {
            rootVC = UIStoryboard(name: "ListOfStudies", bundle: nil).instantiateViewController(withIdentifier: "studyList") as! UINavigationController
        }
        else if (consentGiven && studyConsentGiven) {
            rootVC = UIStoryboard(name: "StudyHome", bundle: nil).instantiateViewController(withIdentifier: "studies") as! StudyViewController
        }
        else {
            rootVC = UIStoryboard(name: "OurLab", bundle: nil).instantiateViewController(withIdentifier: "ourLab") as! UINavigationController
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = rootVC
        
    }

}
