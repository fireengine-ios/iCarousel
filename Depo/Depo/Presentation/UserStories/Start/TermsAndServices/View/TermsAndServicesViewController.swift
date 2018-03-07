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
    var applyTermsButton: UIBarButtonItem!

    
    // MARK: Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidenNavigationBarStyle()
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        if !Device.isIpad {
            setNavigationTitle(title:TextConstants.termsAndUsesTitile)
        }
        
        
        let applyButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 44.0))

        applyButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 17)
        
        applyButton.setTitle(TextConstants.termsAndUsesApplyButtonText, for: .normal)
        applyButton.backgroundColor = UIColor.clear
        applyButton.addTarget(self, action: #selector(onApplyButton), for:.touchUpInside)
        
        let barButton = UIBarButtonItem(customView: applyButton)
        navigationItem.rightBarButtonItem = barButton
        applyTermsButton = barButton
        output.viewIsReady()
        
    }

    // MARK: Buttons action
    
    @objc func onApplyButton(){
        output.termsApplied()
    }

    // MARK: TermsAndServicesViewInput
    func setupInitialState() {
        
    }
    
    func showLoadedTermsAndUses(eula: String) {
        let string = String(format: TextConstants.termsAndUseTextFormat, eula)
        webView.delegate = self
        webView.loadHTMLString(string, baseURL: nil)
    }
    
    func failLoadTermsAndUses(errorString:String) {
        //TO-DO show error
    }
    
    func popNavigationVC() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: UIWebViewDelegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        navigationItem.rightBarButtonItem = applyTermsButton
    }
}
