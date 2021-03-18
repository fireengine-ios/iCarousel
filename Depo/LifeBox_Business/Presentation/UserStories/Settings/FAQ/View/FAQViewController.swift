//
//  FAQViewController.swift
//  Depo
//
//  Created by Oleg on 12/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import WebKit

final class FAQViewController: BaseViewController {
    
    //MARK: - Private properties
    
    private let accountSerivce = AccountService()
    
    private lazy var webView: WKWebView = {
        let webConfig = WKWebViewConfiguration()
        
        let web = WKWebView(frame: .zero, configuration: webConfig)
        web.navigationDelegate = self
        
        return web
    }()
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setWebView()
        loadFAQ()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle(title: TextConstants.faqTitle, isLargeTitle: false)
        setNavigationBarStyle(.white)
        
        if !Device.isIpad {
            defaultNavBarStyle()
        }
    }
    
    deinit {
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
    
    //MARK: - Setup
    
    private func setWebView() {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15).activate()
        webView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).activate()
        webView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).activate()
        webView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).activate()
    }
    
    //MARK: - Private funcs
    
    private func loadFAQ() {
        accountSerivce.faqUrl { [weak self] faqUrl in
            if let url = URL(string: faqUrl) {
                let request = URLRequest(url: url)
                DispatchQueue.toMain {
                    self?.webView.load(request)
                    self?.showSpinner()
                }
            }
        }
    }
}

// MARK: - WKNavigationDelegate

extension FAQViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideSpinner()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideSpinner()
    }
}
