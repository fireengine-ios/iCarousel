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
    @IBOutlet weak var spiner: UIActivityIndicatorView!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.backgroundColor = UIColor.clear
        self.webView.isOpaque = false
        
        self.navigationItem.title = NSLocalizedString(TextConstants.termsAndUsesTitile, comment: "")
        
        let applyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        applyButton.titleLabel?.textColor = ColorConstants.whiteColor
        applyButton.titleLabel?.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 18)
        applyButton.setTitle(NSLocalizedString(TextConstants.termsAndUsesApplyButtonText, comment: ""), for: UIControlState.normal)
        applyButton.backgroundColor = UIColor.clear
        applyButton.addTarget(self, action: #selector(onApplyButton), for: UIControlEvents.touchUpInside)
        
        
        let barButton = UIBarButtonItem(customView: applyButton)
        self.navigationItem.rightBarButtonItem = barButton
        
        self.spiner.startAnimating()
        
        output.viewIsReady()
        
    }

    // MARK: Buttons action
    
    func onApplyButton(){
        self.output.termsApplied()
    }

    // MARK: TermsAndServicesViewInput
    func setupInitialState() {
        
    }
    
    func showLoadedTermsAndUses(eula: Eula){
        self.spiner.stopAnimating()
        self.webView.loadHTMLString(eula.content, baseURL: nil)
    }
    
    func failLoadTermsAndUses(errorString:String){
        self.spiner.stopAnimating()
    }
}
