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
    
    private let buttonTiteles = [TextConstants.termsOfUseAgreement, TextConstants.privacyPolicyAgreement]
    private var webView: WKWebView!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: TextConstants.agreements)
        setSegmentedControl()
        setWebView()
        loadTermsOfUse()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !Device.isIpad {
            defaultNavBarStyle()
        }
    }
    
    //MARK: - Setup
    
    private func setSegmentedControl() {
        let segmentedControl = AgreementsSegmentedControl(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 43),
                                                          buttonTitles: buttonTiteles)
        segmentedControl.backgroundColor = .clear
        segmentedControl.delegate = self
        view.addSubview(segmentedControl)
    }
    
    private func setWebView() {
        webView = WKWebView()
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 62).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
    }
    
    //MARK: - Private funcs
    
    private func loadTermsOfUse() {
        let url = URL(string: "https://www.apple.com")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    private func loadPrivacyPolicy() {
        let url = URL(string: "https://www.google.com")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}

//MARK: - AgreementsSegmentedControlDelegate

extension AgreementsViewController: AgreementsSegmentedControlDelegate {
    func segmentedControlButton(didChangeIndexTo index: Int) {
        webView.clearPage()
        
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
}
