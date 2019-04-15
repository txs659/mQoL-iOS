//
//  StudyUser.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 15/04/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import Parse

class StudyUser : PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "StudyUser"
    }
    
}
