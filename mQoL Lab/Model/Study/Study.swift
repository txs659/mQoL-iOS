//
//  Study.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 30/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import Foundation
import Parse

class Study : PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "Study"
    }
    
    static func getStudiesByStatusQuery () -> PFQuery<Study>? {
        return self.query()?.addAscendingOrder("displayOrder") as? PFQuery<Study>
    }
    
}
