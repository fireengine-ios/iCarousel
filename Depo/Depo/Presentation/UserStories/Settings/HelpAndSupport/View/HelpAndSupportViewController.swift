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
        
        if let url = URL(string: RouteRequests.faqContentUrl) {
            let request = URLRequest.init(url: url)
            webView.load(request)
            showSpiner()
        }
        
    }
    
    //MARK: WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideSpiner()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideSpiner()
    }
}
