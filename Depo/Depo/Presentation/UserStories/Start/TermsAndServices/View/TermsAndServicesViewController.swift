//
//  TermsAndServicesTermsAndServicesViewController.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import WebKit

class TermsAndServicesViewController: ViewController, TermsAndServicesViewInput {

    var output: TermsAndServicesViewOutput!

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var checkboxLabel: UILabel!
    @IBOutlet weak var acceptButton: BlueButtonWithWhiteText!
    
    @IBOutlet weak var topContraintIOS10: NSLayoutConstraint!
    @IBOutlet weak var topContraintIOS11: NSLayoutConstraint!
    
    private var userWebContentController: WKUserContentController {
        let contentController = WKUserContentController()
        let scriptSource = "document.body.style.color = 'white'; document.body.style.webkitTextSizeAdjust = 'auto';"
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(script)
        
        return contentController
    }
    
    private var webViewConfiguration: WKWebViewConfiguration {
        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = self.userWebContentController
        if #available(iOS 10.0, *) {
            webConfig.dataDetectorTypes = [.phoneNumber, .link]
        }
        
        return webConfig
    }
    
    private lazy var webView: WKWebView = {
        let web = WKWebView(frame: .zero, configuration: self.webViewConfiguration)
        web.isOpaque = false
        web.backgroundColor = .clear
        web.scrollView.backgroundColor = .clear

        web.navigationDelegate = self
        return web
    }()
    
    
    // MARK: Life cycle
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        webView.frame = contentView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hidenNavigationBarStyle()        
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.addSubview(webView)
        
        if !Device.isIpad {
            setNavigationTitle(title: TextConstants.termsAndUsesTitile)
        }

        if #available(iOS 11.0, *) {
            topContraintIOS10.isActive = false
        } else {
            topContraintIOS11.isActive = false
        }
        
        configureUI()
        
        output.viewIsReady()
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }

    private func configureUI() {
        welcomeLabel.text = TextConstants.termsAndUseWelcomeText
        welcomeLabel.font = UIFont.TurkcellSaturaDemFont(size: 25)
        welcomeLabel.textColor = ColorConstants.darcBlueColor
        
        checkboxLabel.text = TextConstants.termsAndUseCheckboxText
        checkboxLabel.font = UIFont.TurkcellSaturaRegFont(size: 12)
        checkboxLabel.textColor = ColorConstants.darkText
        
        acceptButton.setTitle(TextConstants.termsAndUseStartUsingText, for: .normal)
        
        webView.clearPage()
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
    }

    // MARK: Buttons action
    
    @IBAction func onStartUsing(_ sender: Any) {
        output.startUsing()
    }
    
    @IBAction func onCheckbox(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        button.isSelected = !button.isSelected
        
        output.confirmAgreements(button.isSelected)
    }

    // MARK: TermsAndServicesViewInput
    func setupInitialState() {
        
    }
    
    func showLoadedTermsAndUses(eula: String) {
        guard !eula.isEmpty else {
            return
        }
        
        webView.loadHTMLString(eula, baseURL: nil)
    }
    
    func hideBackButton() {
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func noConfirmAgreements(errorString: String) {
        UIApplication.showErrorAlert(message: errorString)
    }
    
    func failLoadTermsAndUses(errorString: String) {
        //TO-DO show error
    }
    
    func popNavigationVC() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
}


extension TermsAndServicesViewController: WKNavigationDelegate {
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
