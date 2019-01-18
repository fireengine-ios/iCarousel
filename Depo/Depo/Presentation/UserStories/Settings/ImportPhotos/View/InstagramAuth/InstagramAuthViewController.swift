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
        
        navigationBarWithGradientStyle()
        
        setTitle(withString: "Instagram login")
        webView.backgroundColor = UIColor.white
        webView.isOpaque = false

        let request = URLRequest(url: authPath!)
        webView.load(request)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        handleBackButton()
    }
    
    private func handleBackButton() {
        if isMovingFromParentViewController, !isLoginStarted, !isLoginCanceled {
            delegate?.instagramAuthCancel()
        }
    }
    
    private func instagramAuthCancel() {
        delegate?.instagramAuthCancel()
        navigationController?.popViewController(animated: true)
    }
    
    private func checkInstagramLogin() {
        showSpiner()
        if let instagramAccessToken = instagramAccessToken {
            instagramService.checkInstagramLogin(instagramAccessToken: instagramAccessToken) { [weak self] response in
                self?.hideSpiner()
                switch response {
                case .success(_):
                    self?.delegate?.instagramAuthSuccess()
                    self?.navigationController?.popViewController(animated: true)
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.localizedDescription)
                    self?.instagramAuthCancel()
                }
            }
        }
    }
    
    deinit {
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
}

extension InstagramAuthViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if isLoginStarted {
            checkInstagramLogin()
        } else if isLoginCanceled {
            instagramAuthCancel()
        }
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
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
        } else if currentUrl.contains("access_denied"), navigationAction.navigationType == .formSubmitted {
            isLoginCanceled = true
        }
        
        decisionHandler(.allow)
    }
}
