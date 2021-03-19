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
        setNavigationBarStyle(.byDefault)
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
        output.didEndLoad()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        output.didEndLoad()
        showErrorAlert(message: error.description)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        output.didStartLoad()
    }
    
}
