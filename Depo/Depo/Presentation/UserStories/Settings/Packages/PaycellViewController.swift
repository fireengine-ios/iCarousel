//
//  PaycellViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 18/09/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import WebKit


final class PaycellViewController: UIViewController {

    private let tokenStorage: TokenStorage = factory.resolve()
    private var offerId: Int?
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
    
        if #available(iOS 11, *) {
            //
        } else {
            let controller = WKUserContentController()
            let script = WKUserScript(source: "document.cookie = '_at=\(tokenStorage.accessToken ?? "")';", injectionTime: .atDocumentStart, forMainFrameOnly: false)
            controller.addUserScript(script)
            config.userContentController = controller
        }
        
        return WKWebView(frame: .zero, configuration: config)
    }()
    
    
    static func createController(with cpcmOfferId: Int) -> PaycellViewController {
        let controller = PaycellViewController()
        controller.offerId = cpcmOfferId
        
        return controller
    }
    
    
    override func loadView() {
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startPaycellProcess()
    }
    
    private func startPaycellProcess() {
        guard
            let offerId = offerId,
            let paycellUrl = URL(string: String(format: RouteRequests.paycellWebUrl, offerId))
        else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        syncCookies(url: paycellUrl) { [weak self] in
            let urlRequest = URLRequest(url: paycellUrl)
            
            DispatchQueue.main.async {
                self?.webView.load(urlRequest)
            }
        }
    }
    
    private func syncCookies(url: URL, completion: @escaping VoidHandler) {
        guard
            let domain = url.host,
            let token = tokenStorage.accessToken
        else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        let httpCookie = HTTPCookie(properties: [.name : "_at",
                                                 .value : token,
                                                 .domain : domain,
                                                 .discard : "FALSE",
                                                 .path : "/"])!
        if #available(iOS 11.0, *) {
            webView.configuration.websiteDataStore.httpCookieStore.setCookie(httpCookie) {
                debugLog("paycell web - ios >= 11")
                completion()
            }
        } else {
            debugLog("paycell web - ios < 11")
            completion()
        }
    }
}


extension PaycellViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let currentUrl = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        print(navigationAction.request)
        syncCookies(url: currentUrl, completion: {})
        decisionHandler(.allow)
    }
}
