//
//  StudyListVC.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 08/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD

private let reuseIdentifier = "Cell"


class StudyListVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    public var studiesArray = Array<Study>()
    var pressedCell = StudyCell()
    
    let language = UserDefaults.standard.string(forKey: "language")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        
        ParseController.getStudyList().continueWith { (task) -> Any? in
            self.studiesArray = task.result as! Array<Study>
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                hud.dismiss()
            }
            return nil
        }
        
        if language == "fr" {
            navigationItem.backBarButtonItem?.title = FrStrings.back_button
        }
        else {
            navigationItem.backBarButtonItem?.title = EnStrings.back_button
        }
        
    }
    
    

    // MARK: UICollectionViewDataSource

    //Sets the number of sections. In this case we only want 1.
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //Sets the total number of celss/studies
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return studiesArray.count
    }
    
    //Is responsible for setting up the cell content of every cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StudyCell
        
        cell.studyTitle.text = studiesArray[indexPath.row].value(forKey: "name") as? String
        cell.studyDescription.text = studiesArray[indexPath.row].value(forKey: "teaser") as? String
        
        cell.study = studiesArray[indexPath.row]
        
        // Configure the cell
        cell.contentView.layer.cornerRadius = 4.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
    
        return cell
    }
    
    //Captures the study from the pressed cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedCell = collectionView.cellForItem(at: indexPath) as? StudyCell
        
        self.pressedCell = selectedCell!
        self.performSegue(withIdentifier: "toInfo", sender: self)
    }
    
    //Sends the pressed study data to the next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? InfoDisplayerVC
        vc?.study = pressedCell.study
    }
    
    // Makes sure that the list of studies can be displayed in both portrait and landscape
    // mode.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let cellWidth : CGFloat = 336
        
        let numberOfCells = floor(self.view.frame.size.width / cellWidth)
        let edgeInsets = (self.view.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)
        
        return UIEdgeInsets(top: 15, left: edgeInsets, bottom: 0, right: edgeInsets)
        
    }
    
    //Recalculates the cell sizes on device rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout();
    }
    

}
