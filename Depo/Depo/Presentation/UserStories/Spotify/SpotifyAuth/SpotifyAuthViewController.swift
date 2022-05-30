//
//  SpotifyAuthViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import WebKit

protocol SpotifyAuthViewControllerDelegate: AnyObject {
    func spotifyAuthSuccess(with code: String)
    func spotifyAuthCancel()
}

final class SpotifyAuthViewController: BaseViewController {
    
    private let webView = WKWebView()
    
    weak var delegate: SpotifyAuthViewControllerDelegate?
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    // MARK: -
    
    deinit {
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
    
    override func loadView() {
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSpinner()
        removeCache()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigation()
        analyticsService.logScreen(screen: .spotifyAuthentification)
    }
    
    func loadWebView(with url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func handleBackButton() {
        hideSpinner()
        if isMovingFromParent {
            delegate?.spotifyAuthCancel()
        }
    }
    
    @objc private func spotifyAuthCancel() {
        delegate?.spotifyAuthCancel()
        navigationController?.popViewController(animated: true)
    }
    
    private func setupNavigation() {
        setTitle(withString: TextConstants.importFromSpotifyTitle)
        
        let cancelButton = UIBarButtonItem(title: TextConstants.cancel, target: self, selector: #selector(spotifyAuthCancel))
        navigationItem.leftBarButtonItem = cancelButton
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
        if let startIndex = currentUrl.range(of: "code=")?.upperBound {
            var spotifyCode = String(currentUrl.suffix(from: startIndex))
            if let facebookCode = spotifyCode.firstIndex(of: "&") {
                spotifyCode = String(spotifyCode[..<facebookCode])
            }
            delegate?.spotifyAuthSuccess(with: spotifyCode)
            removeCache()
            
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
