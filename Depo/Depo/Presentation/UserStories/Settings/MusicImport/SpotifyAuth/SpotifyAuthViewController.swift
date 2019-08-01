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
    
    private let webView = WKWebView()
    
    weak var delegate: SpotifyAuthViewControllerDelegate?
    
    override func loadView() {
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSpinner()
        setupNavigation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        handleBackButton()
    }
    
    func loadWebView(with url: URL) {
        let request = URLRequest(url: url)
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
        spotifyRoutingService.terminationAuthProcess(code: code) { [weak self] playListsRequestResult in
            switch playListsRequestResult {
            case .success(let playLists):
                //Logic for present tableView with playLists
                print(playLists.count)
            case .failed(let error):
                //Logic for error handling
                print(error.localizedDescription)
            }
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
            if let facebookCode = spotifyCode.index(of: "&") {
                 spotifyCode = String(spotifyCode[..<faceBookCode])
            }
            terminateAuthProcess(code: spotifyCode)
        }
        decisionHandler(.allow)
    }
}
