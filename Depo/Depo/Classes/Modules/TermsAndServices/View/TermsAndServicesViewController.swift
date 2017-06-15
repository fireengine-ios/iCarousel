//
//  TermsAndServicesTermsAndServicesViewController.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class TermsAndServicesViewController: UIViewController, TermsAndServicesViewInput, UIWebViewDelegate {

    var output: TermsAndServicesViewOutput!
    var eula = EULA()
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var spiner: UIActivityIndicatorView!
    var applyTermsButton: UIBarButtonItem!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.backgroundColor = UIColor.clear
        self.webView.isOpaque = false
        
        self.navigationItem.title = NSLocalizedString(TextConstants.termsAndUsesTitile, comment: "")
        
        let applyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        applyButton.titleLabel?.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 17)
        applyButton.setTitle(NSLocalizedString(TextConstants.termsAndUsesApplyButtonText, comment: ""), for: UIControlState.normal)
        applyButton.backgroundColor = UIColor.clear
        applyButton.addTarget(self, action: #selector(onApplyButton), for: UIControlEvents.touchUpInside)
        
        let barButton = UIBarButtonItem(customView: applyButton)
        self.applyTermsButton = barButton
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
        
        let string = String(format: TextConstants.termsAndUseTextFormat, eula.content)
        self.webView.delegate = self
        self.webView.loadHTMLString(string, baseURL: nil)
    }
    
    func failLoadTermsAndUses(errorString:String){
        self.spiner.stopAnimating()
        //TO-DO show error
    }
    
    // MARK: UIWebViewDelegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.navigationItem.rightBarButtonItem = self.applyTermsButton
    }
}
