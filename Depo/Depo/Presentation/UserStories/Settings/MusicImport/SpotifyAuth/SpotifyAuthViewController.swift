//
//  SpotifyAuthViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import WebKit

protocol SpotifyAuthViewControllerDelegate: class {
    func spotifyAuthSuccess()
    func spotifyAuthCancel()
}

final class SpotifyAuthViewController: ViewController, ControlTabBarProtocol {
    
    private let spotifyRoutingService = SpotifyRoutingService()
    
    private var webView = WKWebView(frame: .zero) {
        willSet {
            newValue.backgroundColor = UIColor.white
            newValue.isOpaque = false
        }
    }
    
    private var authPath: URL?    
    weak var delegate: SpotifyAuthViewControllerDelegate?
    
    override func loadView() {
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeCache()
        showSpinner()
        setupNavigation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        handleBackButton()
    }
    
    func configure(authpath: URL) {
        self.authPath = authpath
        loadWebView()
    }
    
    
    private func loadWebView() {
        guard let authPath = authPath else {
            assertionFailure()
            return
        }
        var request = URLRequest(url: authPath)
        request.httpShouldHandleCookies = false
        webView.load(request)
    }
    
    private func handleBackButton() {
        hideSpinner()
        if isMovingFromParentViewController {
            delegate?.spotifyAuthCancel()
        }
    }
    
    @objc private func spotifyAuthCancel() {
        delegate?.spotifyAuthCancel()
        navigationController?.popViewController(animated: true)
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
    
    private func setupNavigation() {
        
        hideTabBar()
        navigationBarWithGradientStyle()
        setTitle(withString: TextConstants.importFromSpotifyTitle)
        
        let cancelButton = UIBarButtonItem(title: TextConstants.cancel, target: self, selector: #selector(spotifyAuthCancel))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    private func terminateAuthProcess(code: String) {
        spotifyRoutingService.terminationAuthProcess(code: code) { [weak self] playLists in
            // TODO: Present play lists screen
            print(playLists?.count)
        }
    }
}


extension SpotifyAuthViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideSpinner()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideSpinner()
        delegate?.spotifyAuthCancel()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let currentUrl = navigationAction.request.url?.absoluteString else {
            decisionHandler(.cancel)
            return
        }
        
        
        if let index = currentUrl.range(of: "code=")?.upperBound {
            var spotifyCode = String(currentUrl.suffix(from: index))
            
            print(spotifyCode)
        
            if let faceBook = spotifyCode.index(of: "&") {
                 spotifyCode = String(spotifyCode.substring(to: faceBook))
            }
           
            print(spotifyCode)
            

            terminateAuthProcess(code: spotifyCode)
            removeCache()
        }
        
        decisionHandler(.allow)
    }
}
