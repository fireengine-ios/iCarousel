//
//  AgreementsViewController.swift
//  Depo_LifeTech
//
//  Created by Vyacheslav Bakinskiy on 10.03.21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit
import WebKit

final class AgreementsViewController: BaseViewController, NibInit {
    
    //MARK: - Private properties
    
    private let eulaService = EulaService()
    
    private lazy var webView: WKWebView = {
        let contentController = WKUserContentController()
        
        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = contentController
        webConfig.dataDetectorTypes = [.phoneNumber, .link]
        
        let web = WKWebView(frame: .zero, configuration: webConfig)
        web.isOpaque = false
        web.navigationDelegate = self
        
        return web
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = view.bounds
        activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        activityIndicator.color = UIColor.lightGray
        return activityIndicator
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        changeLargeTitle(prefersLargeTitles: false, barStyle: .white)
        setView()
        setSegmentedControl()
        setWebView()
        setActivityIndicator()
        startActivity()
        loadTermsOfUse()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle(title: TextConstants.agreements, style: .white)
        setNavigationBarStyle(.white)
        
        if !Device.isIpad {
            setNavigationBarStyle(.byDefault)
        }
    }
    
    deinit {
        webView.navigationDelegate = nil
        webView.stopLoading()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    //MARK: - Setup
    
    private func setView() {
        view.backgroundColor = ColorConstants.tableBackground.color
    }
    
    private func setSegmentedControl() {
        let segmentedControl = AgreementsSegmentedControl.initFromNib()
        segmentedControl.backgroundColor = .clear
        segmentedControl.delegate = self
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.topAnchor.constraint(equalTo: view.topAnchor).activate()
        segmentedControl.leftAnchor.constraint(equalTo: view.leftAnchor).activate()
        segmentedControl.rightAnchor.constraint(equalTo: view.rightAnchor).activate()
    }
    
    private func setActivityIndicator() {
        view.addSubview(activityIndicator)
    }
    
    private func setWebView() {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 62).activate()
        webView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).activate()
        webView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).activate()
        webView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).activate()
    }
    
    //MARK: - Private funcs
    
    private func startActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
    }
    
    private func stopActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        activityIndicator.stopAnimating()
    }
    
    private func loadTermsOfUse() {
        eulaService.eulaGet { [weak self] response in
            guard let self = self else {
                return
            }
            switch response {
            case .success(let termsOfUse):
                guard let content = termsOfUse.content else {
                    assertionFailure()
                    return
                }
                
                let prepearedContent = content.setHTMLStringFont(UIFont.GTAmericaStandardRegularFont(size: 16),
                                                                 fontSizeInPixels: 16)
                self.webView.loadHTMLString(prepearedContent, baseURL: nil)
            case .failed(_):
                self.stopActivity()
            }
        }
    }
    
    private func loadPrivacyPolicy() {
        startActivity()
        
        if let url = URL(string: String(format: RouteRequests.privacyPolicy, Device.supportedLocale)) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

//MARK: - AgreementsSegmentedControlDelegate

extension AgreementsViewController: AgreementsSegmentedControlDelegate {
    func segmentedControlButton(didChangeIndexTo index: Int) {
        webView.clearPage()
        startActivity()
        
        switch index {
        case 0:
            loadTermsOfUse()
        case 1:
            loadPrivacyPolicy()
        default:
            break
        }
    }
}

//MARK: - WKNavigationDelegate

extension AgreementsViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch navigationAction.navigationType {
        case .linkActivated:
            UIApplication.shared.openSafely(navigationAction.request.url)
            decisionHandler(.cancel)
        default:
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        stopActivity()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        stopActivity()
    }
}
