//
//  HelpAndSupportHelpAndSupportViewController.swift
//  Depo
//
//  Created by Oleg on 12/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import WebKit

class HelpAndSupportViewController: BaseViewController, WKNavigationDelegate {
    
    private var webView: WKWebView!
    
    // MARK: Life cycle
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = TextConstants.faqViewTitle
        
        if let url = URL(string: String(format: RouteRequests.faqContentUrl, Device.supportedLocale)) {
            let request = URLRequest(url: url)
            webView.load(request)
            showSpinner()
        }
        
    }
    
    // MARK: WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideSpinner()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideSpinner()
    }
}
