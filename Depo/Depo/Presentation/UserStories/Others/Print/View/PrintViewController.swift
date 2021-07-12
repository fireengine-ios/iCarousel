//
//  PrintViewController.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 17.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import WebKit

class PrintViewController: BaseViewController, ErrorPresenter {
    
    private lazy var webView = WKWebView(frame: .zero)

    var output: PrintViewOutput!
    
    override func loadView() {
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        output.viewIsReady()

        let backButton = UIBarButtonItem()
        backButton.title = TextConstants.backPrintTitle
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    deinit {
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
}

// MARK: - PrintInteractorOutput

extension PrintViewController: PrintViewInput {
    
    func loadUrl(_ urlRequest: URLRequest) {
        webView.load(urlRequest)
    }

}

// MARK: - PrintInteractorOutput

extension PrintViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard webView == self.webView else { return }
        output.didEndLoad()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard webView == self.webView else {
            // Facebook login is throwing an error upon completion.
            // So we'll just go back to the original webView on error.
            self.view = self.webView
            return
        }

        output.didEndLoad()
        showErrorAlert(message: error.description)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard webView == self.webView else { return }
        output.didStartLoad()
    }

    func webViewDidClose(_ webView: WKWebView) {
        if self.view != self.webView {
            self.view = self.webView
        }
    }
}

extension PrintViewController: WKUIDelegate {
    // This handles login with Facebook & Instagram.
    // Opens the page in a separate webview
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let popupWebView = WKWebView(frame: webView.frame, configuration: configuration)
        popupWebView.navigationDelegate = self
        popupWebView.load(navigationAction.request)
        self.view = popupWebView
        return popupWebView
    }
}
