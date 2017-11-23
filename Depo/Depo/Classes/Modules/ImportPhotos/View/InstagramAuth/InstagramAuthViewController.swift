//
//  InstagramAuthViewController.swift
//  Depo
//
//  Created by Ryhor on 04.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol InstagramAuthViewControllerDelegate: class {
    func instagramAuthSuccess()
    func instagramAuthCancel()
}
    
class InstagramAuthViewController: UIViewController{
    
    @IBOutlet weak private var webView: UIWebView!
    
    private var clientID: String?
    private var authPath: URL?
    
    private var isLoginStarted = false
    private var isLoginCanceled = false
    
    weak var delegate: InstagramAuthViewControllerDelegate?
    
    func configure(clientId: String, authpath: URL){
        self.clientID = clientId
        self.authPath = authpath
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self

        let request = URLRequest(url: self.authPath!)
        webView.loadRequest(request)
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        handleBackButton()
    }
    
    private func handleBackButton() {
        if isMovingFromParentViewController, !isLoginStarted, !isLoginCanceled {
            delegate?.instagramAuthCancel()
        }
    }
}

extension InstagramAuthViewController: UIWebViewDelegate{

    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if isLoginStarted {
            delegate?.instagramAuthSuccess()
            navigationController?.popViewController(animated: true)
        } else if isLoginCanceled {
            delegate?.instagramAuthCancel()
            navigationController?.popViewController(animated: true)
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        guard let currentUrl = request.url?.absoluteString else {
            return false
        }
        
        if currentUrl.contains("#access_token"), navigationType == .formSubmitted {
            isLoginStarted = true
        } else if currentUrl.contains("access_denied"), navigationType == .formSubmitted {
            isLoginCanceled = true
        }
        
        return true
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        delegate?.instagramAuthCancel()
    }
}
