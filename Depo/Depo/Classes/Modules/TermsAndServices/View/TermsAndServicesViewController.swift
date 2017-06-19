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
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var spiner: UIActivityIndicatorView!
    var applyTermsButton: UIBarButtonItem!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        
        navigationItem.title = NSLocalizedString(TextConstants.termsAndUsesTitile, comment: "")
        
        let applyButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 44.0))
        applyButton.titleLabel?.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 17)

        applyButton.setTitle(NSLocalizedString(TextConstants.termsAndUsesApplyButtonText, comment: ""), for: UIControlState.normal)
        applyButton.backgroundColor = UIColor.clear
        applyButton.addTarget(self, action: #selector(onApplyButton), for: UIControlEvents.touchUpInside)
        
        //let retryB
        
        let barButton = UIBarButtonItem(customView: applyButton)
        applyTermsButton = barButton
        spiner.startAnimating()
        
        output.viewIsReady()
        
    }

    // MARK: Buttons action
    
    func onApplyButton(){
        output.termsApplied()
    }

    // MARK: TermsAndServicesViewInput
    func setupInitialState() {
        
    }
    
    func showLoadedTermsAndUses(eula: Eula){
        spiner.stopAnimating()
        
        let string = String(format: TextConstants.termsAndUseTextFormat, eula.content)
        webView.delegate = self
        webView.loadHTMLString(string, baseURL: nil)
    }
    
    func failLoadTermsAndUses(errorString:String){
        spiner.stopAnimating()
        //TO-DO show error
    }
    
    // MARK: UIWebViewDelegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        navigationItem.rightBarButtonItem = applyTermsButton
    }
}
