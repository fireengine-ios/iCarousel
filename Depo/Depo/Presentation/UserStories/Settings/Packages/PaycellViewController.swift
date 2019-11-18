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
    
    static func create(with cpcmOfferId: Int, completion: @escaping ResponseVoid) -> PaycellViewController {
        let controller = PaycellViewController()
        controller.offerId = cpcmOfferId
        controller.completionHandler = completion
        return controller
    }
    

    private let tokenStorage: TokenStorage = factory.resolve()
    private var offerId: Int?
    private var completionHandler: ResponseVoid?
    private let redirectHost = "google.com"
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        
        /// to handle window.open and window.close calls
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        if #available(iOS 13, *) {
            //stay with default config
        } else {
            let controller = WKUserContentController()
            let script = WKUserScript(source: "document.cookie = '_at=\(tokenStorage.accessToken ?? "")';", injectionTime: .atDocumentStart, forMainFrameOnly: false)
            controller.addUserScript(script)
            config.userContentController = controller
        }
        
        return WKWebView(frame: .zero, configuration: config)
    }()
    
    private var popupWebView: WKWebView?
    
    
    override func loadView() {
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showSpinner()
        startPaycellProcess()
    }
    
    private func startPaycellProcess() {
        guard
            let offerId = offerId,
            let paycellUrl = URL(string: String(format: RouteRequests.paycellWebUrl, offerId))
        else {
            closeScreen(error: ErrorResponse.string("can't start paycell process"))
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
            let token = tokenStorage.accessToken,
            let domain = url.host
        else {
            closeScreen(error: ErrorResponse.string("can't sync cookies"))
            return
        }
        
        let httpCookie = HTTPCookie(properties: [.name : "_at",
                                                 .value : token,
                                                 .domain : domain,
                                                 .path : "/"])!
        if #available(iOS 13.0, *) {
            webView.configuration.websiteDataStore.httpCookieStore.setCookie(httpCookie) {
                debugLog("paycell web - ios >= 13")
                completion()
            }
        } else {
            debugLog("paycell web - ios < 13")
            completion()
        }
    }
    
    private func closeScreen(error: Error?) {
        if let error = error {
            completionHandler?(.failed(error))
        } else {
            completionHandler?(.success(()))
        }
        
        RouterVC().popViewController()
    }
    
    deinit {
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
}

extension PaycellViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let newWindowView = createWindowWebView(with: configuration)
        popupWebView = newWindowView
        view.addSubview(newWindowView)
        
        return popupWebView
    }

    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupWebView {
            webView.removeFromSuperview()
            popupWebView = nil
        } else {
            closeScreen(error: nil)
        }
    }
    
    private func createWindowWebView(with configuration: WKWebViewConfiguration) -> WKWebView {
        let newWindowView = WKWebView(frame: view.bounds, configuration: configuration)
        newWindowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newWindowView.navigationDelegate = self
        newWindowView.uiDelegate = self
        return newWindowView
    }
}


extension PaycellViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideSpinner()
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url, url.host == redirectHost {
            decisionHandler(.cancel)
            closeScreen(error: nil)
            return
        }
        
        decisionHandler(.allow)
    }
    
}
