//
//  readPDFVC.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 12/04/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import PDFKit

class readPDFVC: UIViewController {
    
    public var pdfFile : PDFDocument = PDFDocument()
    
    @IBOutlet weak var pdfView : PDFView!
    @IBOutlet weak var btn : UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pdfView.displayMode = .singlePageContinuous
        self.pdfView.autoScales = true
        self.pdfView.document = pdfFile        
    }
    
    @IBAction func closePressed(sender: UIButton){
        dismiss(animated: true)
    }

}
