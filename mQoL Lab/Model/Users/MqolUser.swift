//
//  MqolUser.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 19/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import Parse

class MqolUser : PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "MqolUser"
    }
    
    func acceptLabAgreement () {
        setObject(true, forKey: "labAgreementAccepted")
    }
    
}

