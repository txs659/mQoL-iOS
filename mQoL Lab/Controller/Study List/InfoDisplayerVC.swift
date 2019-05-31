//
//  InfoDisplayerVC.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 31/03/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit

class InfoDisplayerVC: UIViewController {
    
    public var study = Study()
    
    let language = UserDefaults.standard.string(forKey: "language")
    
    //Defining UI elements
    let scrollView = UIScrollView()
    let pageTitle = UILabel()
    let quickFacts = UILabel()
    let pageInfo = UILabel()
    let iconLeft = UIImageView()
    let iconMiddle = UIImageView()
    let iconRight = UIImageView()
    
    //Counts what screen text to display
    var counter = 0
    
    //Array containing Parse objects containing the needed text strings
    let infoArray = [["title_welcome", "quickFacts", "text_welcome"],
                     ["title_surveys", "text_surveys"],
                     ["title_sensors", "text_sensors"],
                     ["title_dataProtection", "text_dataProtection"],
                     ["title_whatToExpect", "text_whatToExpect"],
                     ["title_withdrawing", "text_withdrawing"],
                     ["title_benefits", "text_benefits"]]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //The UI for this page had to be made programmatically, since the size of the text varies to much for the Interface Builder to handle
        
        
        //Creating images/icons
        iconLeft.image = UIImage(named: "chart")
        iconLeft.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        iconLeft.contentMode = .scaleAspectFit
        
        iconMiddle.image = UIImage(named: "clock")
        iconMiddle.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        iconMiddle.contentMode = .scaleAspectFit
        
        iconRight.image = UIImage(named: "calendar")
        iconRight.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        iconRight.contentMode = .scaleAspectFit
        
        //Disables auto resizing, since we take care of the autolayout
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        pageTitle.translatesAutoresizingMaskIntoConstraints = false
        quickFacts.translatesAutoresizingMaskIntoConstraints = false
        pageInfo.translatesAutoresizingMaskIntoConstraints = false
        iconLeft.translatesAutoresizingMaskIntoConstraints = false
        iconMiddle.translatesAutoresizingMaskIntoConstraints = false
        iconRight.translatesAutoresizingMaskIntoConstraints = false
        
        //Adding subviews to the scrollview
        scrollView.addSubview(pageTitle)
        scrollView.addSubview(quickFacts)
        scrollView.addSubview(pageInfo)
        scrollView.addSubview(iconLeft)
        scrollView.addSubview(iconMiddle)
        scrollView.addSubview(iconRight)
        self.view.addSubview(scrollView)
        
        //Setting the margins of the device
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
            ])
        
        // Setting the safe area depending on device and iOS version
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                    scrollView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                    guide.bottomAnchor.constraint(equalToSystemSpacingBelow: scrollView.bottomAnchor, multiplier: 1.0)
                    
                ])
            
        } else {
            let standardSpacing: CGFloat = 8.0
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
                ])
            bottomLayoutGuide.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: standardSpacing)
        }
        
        
        //Setting layout constraints for all the UI elements
        pageTitle.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16.0).isActive = true
        pageTitle.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        pageTitle.textAlignment = .center
        pageTitle.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8.0).isActive = true
        pageTitle.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 8.0).isActive = true
        
        iconLeft.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 16).isActive = true
        iconLeft.trailingAnchor.constraint(equalTo: iconMiddle.leadingAnchor, constant: -8).isActive = true
        iconLeft.widthAnchor.constraint(equalToConstant: 64).isActive = true
        iconLeft.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        iconMiddle.widthAnchor.constraint(equalToConstant: 64).isActive = true
        iconMiddle.heightAnchor.constraint(equalToConstant: 64).isActive = true
        iconMiddle.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        iconMiddle.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 16).isActive = true
        
        iconRight.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 16).isActive = true
        iconRight.leadingAnchor.constraint(equalTo: iconMiddle.trailingAnchor, constant: 8).isActive = true
        iconRight.widthAnchor.constraint(equalToConstant: 64).isActive = true
        iconRight.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        
        quickFacts.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.95, constant: 0).isActive = true
        quickFacts.topAnchor.constraint(equalTo: iconMiddle.bottomAnchor, constant: 16.0).isActive = true
        quickFacts.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8.0).isActive = true
        quickFacts.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 8.0).isActive = true
        
        
        pageInfo.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.95, constant: 0).isActive = true
        pageInfo.topAnchor.constraint(equalTo: quickFacts.bottomAnchor, constant: 16.0).isActive = true
        pageInfo.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8.0).isActive = true
        pageInfo.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 8.0).isActive = true
        pageInfo.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0.0).isActive = true
        
        
        
        // configure label: Zero lines + Word Wrapping
        pageTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        pageTitle.font = UIFont.systemFont(ofSize: 36.0)
        pageTitle.adjustsFontSizeToFitWidth = true
        pageTitle.minimumScaleFactor = 0.1
        
        // configure label: Zero lines + Word Wrapping
        quickFacts.numberOfLines = 0
        quickFacts.lineBreakMode = NSLineBreakMode.byWordWrapping
        quickFacts.font = UIFont.systemFont(ofSize: 17.0)
        
        
        // configure label: Zero lines + Word Wrapping
        pageInfo.numberOfLines = 0
        pageInfo.lineBreakMode = NSLineBreakMode.byWordWrapping
        pageInfo.font = UIFont.systemFont(ofSize: 17.0)
        
        //Setting the language for navigation buttons depending on device language
        if language == "fr" {
            navigationItem.backBarButtonItem?.title = FrStrings.back_button
            navigationItem.rightBarButtonItem?.title = FrStrings.next_button
        }
        else {
            navigationItem.backBarButtonItem?.title = EnStrings.back_button
            navigationItem.rightBarButtonItem?.title = EnStrings.next_button
        }
        
        updateText()
        
    }
    
    //Function that updates text
    func updateText() {
        
        let newTitle = study.object(forKey: infoArray[self.counter][0]) as? String
        let newInfo = study.object(forKey: infoArray[self.counter][1]) as? String
        
        //If we move away from the first screen, the quickFacts label has to be removed
        if self.counter == 0 {
            pageTitle.text = study.object(forKey: infoArray[0][0]) as? String
            quickFacts.text = study.object(forKey: infoArray[0][1]) as? String
            pageInfo.text = study.object(forKey: infoArray[0][2]) as? String
        }
        //If the text for next view is empty, skip it
        else if (newTitle == "" || newTitle == nil) && (newInfo == "" || newInfo == nil) {
            self.counter += 1
            updateText()
        }
        else {
            pageTitle.text = newTitle
            pageInfo.text = newInfo
        }
    }
    
    //Function that removes quickFacts label
    func removeQuickFactsLabel() {

        //Delete quickFacts label
        quickFacts.removeFromSuperview()
        
        //Update UI constraints for pageInfo label
        pageInfo.topAnchor.constraint(equalTo: iconMiddle.bottomAnchor, constant: 16.0).isActive = true
        
        //Remove all contraints for quickFactsLabel
        quickFacts.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.95, constant: 0).isActive = false
        quickFacts.topAnchor.constraint(equalTo: iconMiddle.bottomAnchor, constant: 16.0).isActive = false
        quickFacts.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8.0).isActive = false
        quickFacts.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 8.0).isActive = false
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        if self.counter == 6 {
            performSegue(withIdentifier: "toConsent", sender: self)
        }
        else if self.counter == 0 {
            self.counter += 1
            removeQuickFactsLabel()
            updateText()
        }
        else {
            self.counter += 1
            updateText()
            //self.performSegue(withIdentifier: "dataProtection", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? StudyConsentVC
        vc?.study = study
    }

}
