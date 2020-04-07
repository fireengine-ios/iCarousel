//
//  TermsOfUseViewController.swift
//  Depo
//
//  Created by Konstantin on 8/14/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import WebKit


final class TermsOfUseViewController: BaseViewController {
    
    var output: TermsOfUseViewOutput!
    
    
    private lazy var webView: WKWebView = {
        let contentController = WKUserContentController()
        let scriptSource = "document.body.style.webkitTextSizeAdjust = 'auto';"
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(script)
        
        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = contentController
        webConfig.dataDetectorTypes = [.phoneNumber, .link]
        
        let web = WKWebView(frame: .zero, configuration: webConfig)
        
        web.navigationDelegate = self
        return web
    }()
    
    
    // MARK: Life cycle
    
    override func loadView() {
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.clearPage()
        
        output.viewIsReady()
    }

}


extension TermsOfUseViewController: TermsOfUseViewInput {
    func showLoaded(eulaHTML: String) {
        guard !eulaHTML.isEmpty else {
            return
        }
        
        webView.loadHTMLString(eulaHTML, baseURL: nil)
    }
    
    func showAlert(with errorString: String) {
        UIApplication.showErrorAlert(message: errorString)
    }
}


extension TermsOfUseViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch navigationAction.navigationType {
        case .linkActivated:
            UIApplication.shared.openSafely(navigationAction.request.url)
            decisionHandler(.cancel)
        default:
            decisionHandler(.allow)
        }
    }
}
