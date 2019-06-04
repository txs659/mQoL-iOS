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
        
        //Checking if participant has given consent for the lab and study
        let consentGiven = UserDefaults.standard.bool(forKey: "consentGiven")
        let studyConsentGiven = UserDefaults.standard.bool(forKey: "studyConsentGiven")
        
        //Checking if user is a peer and if the they have seen the intro lab screen
        let isPeer = UserDefaults.standard.bool(forKey: "isPeer")
        let peerLabScreenSeen = UserDefaults.standard.bool(forKey: "peerLabScreenSeen")
        
        var rootVC : UIViewController?
        
        if isPeer {
            //Loading peer screens
            if !peerLabScreenSeen {
                rootVC = UIStoryboard(name: "OurLab", bundle: nil).instantiateViewController(withIdentifier: "ourLab") as! UINavigationController
            }
            else {
                rootVC = UIStoryboard(name: "StudyHome", bundle: nil).instantiateViewController(withIdentifier: "studies") as! UINavigationController
            }
        }
        else {
            //Loading participant screens
            if (consentGiven && !studyConsentGiven) {
                rootVC = UIStoryboard(name: "ListOfStudies", bundle: nil).instantiateViewController(withIdentifier: "studyList") as! UINavigationController
            }
            else if (consentGiven && studyConsentGiven) {
                rootVC = UIStoryboard(name: "StudyHome", bundle: nil).instantiateViewController(withIdentifier: "studies") as! UINavigationController
            }
            else {
                rootVC = UIStoryboard(name: "OurLab", bundle: nil).instantiateViewController(withIdentifier: "ourLab") as! UINavigationController
            }
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = rootVC
    }

}
