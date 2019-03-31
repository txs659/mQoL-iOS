//
//  StudyCell.swift
//  mQoL Lab 1
//
//  Created by Frederik Schmøde on 09/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class StudyCell: UICollectionViewCell {
    
    @IBOutlet weak var studyTitle: UILabel!
    @IBOutlet weak var studyDescription: UILabel!
    
    var study : Study = Study()
    
}
