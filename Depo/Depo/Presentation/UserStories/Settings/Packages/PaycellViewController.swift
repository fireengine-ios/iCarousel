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
    
    typealias ResultVoidCompletion = (Result<Void, Error>)->()

    private let tokenStorage: TokenStorage = factory.resolve()
    private var offerId: Int?
    private var completionHandler: ResultVoidCompletion?
    private let redirectURLString = "google.com"
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        if #available(iOS 11, *) {
            //stay with default config
        } else {
            let controller = WKUserContentController()
            let script = WKUserScript(source: "document.cookie = '_at=\(tokenStorage.accessToken ?? "")';", injectionTime: .atDocumentStart, forMainFrameOnly: false)
            controller.addUserScript(script)
            config.userContentController = controller
        }
        
        return WKWebView(frame: .zero, configuration: config)
    }()
    
    
    static func create(with cpcmOfferId: Int, completion: @escaping ResultVoidCompletion) -> PaycellViewController {
        let controller = PaycellViewController()
        controller.offerId = cpcmOfferId
        controller.completionHandler = completion
        return controller
    }
    
    
    override func loadView() {
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
    
    private func closeScreen(error: Error?) {
        if let error = error {
            completionHandler?(.failure(error))
        } else {
            completionHandler?(.success(()))
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
}


extension PaycellViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        closeScreen(error: error)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideSpinner()
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        //TODO: check if it's enough to use just the fact of redirection without url
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other {
            if let url = navigationAction.request.url, url.absoluteString == redirectURLString {
                decisionHandler(.cancel)
                closeScreen(error: nil)
                return
            }
        }
        decisionHandler(.allow)
    }
}
