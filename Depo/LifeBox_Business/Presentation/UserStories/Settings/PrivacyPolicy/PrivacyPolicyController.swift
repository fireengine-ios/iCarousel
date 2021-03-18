//
//  PrivacyPolicyWebView.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 6/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import WebKit

final class PrivacyPolicyController: BaseViewController, NibInit {
    
    //MARK: - Private properties
    
    private let privacyPolicyService: PrivacyPolicyService = factory.resolve()
    
    private lazy var webView: WKWebView = {
        let contentController = WKUserContentController()
      
        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = contentController
        webConfig.dataDetectorTypes = [.phoneNumber, .link]
        
        let webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = UIColor.white
        
        /// there is a bug for iOS 9
        /// https://stackoverflow.com/a/32843700/5893286
        webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        return webView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = view.bounds
        activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        activityIndicator.color = UIColor.lightGray
        return activityIndicator
    }()
    
    //MARK: - @IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    //MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    //MARK: - Lifecycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupWebView()
        setActivityIndicator()
        startActivity()
        loadPrivacyPolicy()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        whiteNavBarStyle()//TODO: change to set style
    }
    
    deinit {
        webView.navigationDelegate = nil
        webView.stopLoading()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    //MARK: - Setup
    
    private func setupView() {
        setTitle(withString: TextConstants.privacyPolicyCondition)
        
        titleLabel.text = TextConstants.privacyPolicyCondition
        titleLabel.font = UIFont.GTAmericaStandardMediumFont(size: 18)
        titleLabel.textColor = ColorConstants.Text.labelTitle
    }
    
    private func setupWebView() {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).activate()
        webView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).activate()
        webView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).activate()
        webView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).activate()
    }
    
    private func setActivityIndicator() {
        view.addSubview(activityIndicator)
    }
    
    //MARK: - Private funcs
    
    private func loadPrivacyPolicy() {
        privacyPolicyService.getPrivacyPolicy { [weak self] response in
            switch response {
            case .success(let privacyPolicy):
                self?.webView.loadHTMLString(privacyPolicy.content, baseURL: nil)
            case .failed(_):
                self?.stopActivity()
            }
        }
    }
    
    private func startActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
    }
    
    private func stopActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        activityIndicator.stopAnimating()
    }
}

// MARK: - WKNavigationDelegate
extension PrivacyPolicyController: WKNavigationDelegate {
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
