//
//  SurveyDisplayerVC.swift
//  mQoL Lab
//
//  Created by Frederik Schmøde on 22/04/2019.
//  Copyright © 2019 FBS. All rights reserved.
//

import UIKit
import WebKit

class SurveyDisplayerVC: UIViewController, WKUIDelegate {
    
    public var targetURL : String = ""
    
    @IBOutlet var webView : WKWebView!
    
    @IBOutlet var naviTitle : UINavigationItem!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        
        if let url = URL(string: targetURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    @IBAction func closePressed(sender: UIButton){
        dismiss(animated: true)
    }
    
    //Changes the navigation title to the title of the web page
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            if let webTitle = webView.title {
                self.naviTitle.title = webTitle
            }
        }
    }

}
