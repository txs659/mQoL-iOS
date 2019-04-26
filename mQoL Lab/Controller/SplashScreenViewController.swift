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

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Creating a loading icon on the splash screen
        let hud = JGProgressHUD(style: .dark)
        //var uid = ""
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        
        // Creates a unique identifier for the device
        if let identifier = UIDevice.current.identifierForVendor?.uuidString {
            print (identifier)
            //uid = identifier
        }
        
        // Calls the cloud code to either login or create a user with the UUID
        PFCloud.callFunction(inBackground: "registerOrLoginUser", withParameters: ["google_ad_id":"testFromiOS"], block: { (object: Any?, error: Error?) in
            
            // If error is returned
            if error != nil {
                print ("An error orrcured!")
                print (error!)
            }
            // If object is returned
            else {
                print ("Login Successful")
                let sessionToken = object as? String
                PFUser.become(inBackground: sessionToken!, block: { (user, error) in
                    
                    if error == nil {
                        //Dismiss the loading icon
                        hud.dismiss()
                        
                        // Decides what root view to show the user
                        Switcher.updateRootVC()
                    }
                    else {
                        print ("Could not log user in using session token")
                    }
                })
            }
        })
    }

}
