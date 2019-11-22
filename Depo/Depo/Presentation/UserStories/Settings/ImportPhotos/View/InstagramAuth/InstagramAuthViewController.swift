//
//  InstagramAuthViewController.swift
//  Depo
//
//  Created by Ryhor on 04.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import WebKit

protocol InstagramAuthViewControllerDelegate: class {
    func instagramAuthSuccess()
    func instagramAuthCancel()
}
    
class InstagramAuthViewController: ViewController {
    
    private lazy var webView = WKWebView(frame: .zero)
    
    private var clientID: String?
    private var authPath: URL?
    
    private var isLoginStarted = false
    private var isLoginCanceled = false
    private var instagramAccessToken: String?
    
    private lazy var instagramService = InstagramService()
    private lazy var accountService = AccountService()
    
    weak var delegate: InstagramAuthViewControllerDelegate?
    
    func configure(clientId: String, authpath: URL) {
        self.clientID = clientId
        self.authPath = authpath
    }
    
    override func loadView() {
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeCache()
        
        navigationBarWithGradientStyle()
        
        setTitle(withString: "Instagram login")
        webView.backgroundColor = UIColor.white
        webView.isOpaque = false

        var request = URLRequest(url: authPath!)
        request.httpShouldHandleCookies = false
        webView.load(request)
        showSpinner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        handleBackButton()
    }
    
    private func handleBackButton() {
        hideSpinner()
        if isMovingFromParentViewController, !isLoginStarted, !isLoginCanceled {
            delegate?.instagramAuthCancel()
        }
    }
    
    private func instagramAuthCancel() {
        delegate?.instagramAuthCancel()
        navigationController?.popViewController(animated: true)
    }
    
    private func checkInstagramLogin() {
        showSpinner()
        if let instagramAccessToken = instagramAccessToken {
            instagramService.checkInstagramLogin(instagramAccessToken: instagramAccessToken) { [weak self] response in
                switch response {
                case .success(_):
                    DispatchQueue.toMain {
                        self?.delegate?.instagramAuthSuccess()
                    }
                case .failed(let error):
                    self?.hideSpinner()
                    UIApplication.showErrorAlert(message: error.description)
                    self?.instagramAuthCancel()
                }
            }
        }
    }
    
    private func removeCache() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            records.forEach({ record in
                dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                     for: [record],
                                     completionHandler: {})
            })
        }
        
    }
    
    deinit {
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
}

extension InstagramAuthViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideSpinner()
        if isLoginStarted {
            ///server returns 500 if checkInstagramLogin immediately
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                self.checkInstagramLogin()
            }
        } else if isLoginCanceled {
            instagramAuthCancel()
        }
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideSpinner()
        delegate?.instagramAuthCancel()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let currentUrl = navigationAction.request.url?.absoluteString else {
            decisionHandler(.cancel)
            return
        }
        
        if let index = currentUrl.range(of: "#access_token=")?.upperBound {
            instagramAccessToken = String(currentUrl.suffix(from: index))
            isLoginStarted = true
            removeCache()
        }
        
        decisionHandler(.allow)
    }
}
