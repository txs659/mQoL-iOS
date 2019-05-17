//
//  SplashScreenViewController.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 19/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import JGProgressHUD
import Parse

class SplashScreenViewController: UIViewController {
    
    let USER_STUDY_ID = "study_user_id"

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Creating a loading icon on the splash screen
        let hud = JGProgressHUD(style: .dark)
        //var uid = ""
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        var uid = ""
        // Creates a unique identifier for the device
        if let identifier = UIDevice.current.identifierForVendor?.uuidString {
            uid = identifier
        }
        
        UserDefaults.standard.set(true, forKey: "isPeer")
        
        // Calls the cloud code to either login or create a user with the UUID
        PFCloud.callFunction(inBackground: "registerOrLoginUser", withParameters: ["google_ad_id":"\(uid)"], block: { (object: Any?, error: Error?) in
            
            // If error is returned
            if error != nil {
                print (error!)
            }
            // If object is returned
            else {
                print ("Login Successful")
                let sessionToken = object as? String
                PFUser.become(inBackground: sessionToken!, block: { (user, error) in
                    if error == nil {
                        
                        var mqolUser = MqolUser()
                        
                        ParseController.getMqolUser().continueOnSuccessWith(block: { (task) -> Void in
                            mqolUser = task.result! as! MqolUser
                            let userStudyId = self.checkForDynamicLinks()
                            
                            //If dynamic link was found
                            if userStudyId != nil {
                                PFCloud.callFunction(inBackground: "registerPeer", withParameters: [self.USER_STUDY_ID: userStudyId!], block: { (object: Any?, error: Error?) in
                                    
                                    if error != nil {
                                        print (error!)
                                    }
                                    else {
                                        
                                    }
                                    
                                })
                            }
                            //If no dynamic link was found, do nothing more.
                            else {
                                //Dismiss the loading icon
                                hud.dismiss()
                                
                                // Decides what root view to show the user
                                Switcher.updateRootVC()
                            }
                        })
                    }
                    else {
                        print ("Could not log user in using session token")
                    }
                })
            }
        })
    }
    
    
    
    func checkForDynamicLinks() -> String? {
        // TODO: - Insert firebase dynamic link check here
        return nil
    }

}


