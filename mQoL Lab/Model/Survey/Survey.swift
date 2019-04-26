//
//  Survey.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 22/04/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import Foundation
import Parse

class Survey : PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "Survey"
    }
    
    static func basicQuery() -> PFQuery<Survey> {
        return self.query() as! PFQuery<Survey>
    }
    
    
}
