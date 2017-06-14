//
//  TermsAndServicesTermsAndServicesViewController.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class TermsAndServicesViewController: UIViewController, TermsAndServicesViewInput {

    var output: TermsAndServicesViewOutput!
    var eula = EULA()
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var 

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
        
        self.webView.backgroundColor = UIColor.clear
        self.webView.isOpaque = false
        
        weak var weakSelf = self
        eula.requestEulaForLocale(success: { (eula) in
            DispatchQueue.main.async {
                weakSelf?.webView.loadHTMLString(eula.content, baseURL: nil)
            }
        }) { (failString) in
            
        }
    }


    // MARK: TermsAndServicesViewInput
    func setupInitialState() {
    }
}
