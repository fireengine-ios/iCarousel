//
//  TermsAndServicesTermsAndServicesViewController.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import WebKit

class TermsAndServicesViewController: ViewController {

    var output: TermsAndServicesViewOutput!

    @IBOutlet private weak var welcomeLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var acceptButton: BlueButtonWithWhiteText!
    @IBOutlet private weak var checkboxesStack: UIStackView! {
        willSet {
            newValue.spacing = 10 //Design
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView! {
        willSet {
            newValue.bounces = false
        }
    }
    
    
    @IBOutlet private weak var topContraintIOS10: NSLayoutConstraint!
    @IBOutlet private weak var topContraintIOS11: NSLayoutConstraint!

    @IBOutlet private weak var contenViewHeightConstraint: NSLayoutConstraint!
    
    private let generalTermsCheckboxView = TermsCheckboxTextView.initFromNib()
    private var etkTermsCheckboxView: TermsCheckboxTextView?
    private var globalDataPermissionTermsCheckboxView: TermsCheckboxTextView?
    
    private let webView: WKWebView = {
        let contentController = WKUserContentController()
         let scriptSource = "document.body.style.webkitTextSizeAdjust = 'auto';"
    
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(script)
        
        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = contentController
        if #available(iOS 10.0, *) {
            webConfig.dataDetectorTypes = [.phoneNumber, .link]
        }
        
        let webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.isOpaque = false
        
        /// there is a bug for iOS 9
        /// https://stackoverflow.com/a/32843700/5893286
        webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        return webView
    }()
    
    //MARK: - Life cycle
    
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
        webView.navigationDelegate = self
        contentView.addSubview(webView)
        
        if !Device.isIpad {
            setNavigationTitle(title: TextConstants.termsAndUsesTitile)
        }

        contenViewHeightConstraint.constant = Device.winSize.height * 0.5
        if #available(iOS 11.0, *) {
            topContraintIOS10.isActive = false
        } else {
            topContraintIOS11.isActive = false
        }
        
        configureUI()
        setupIntroductionTextView()
        output.viewIsReady()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideSpinnerIncludeNavigationBar()
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    deinit {
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
    
    //MARK: - Configuration and Input
    private func configureUI() {
        welcomeLabel.text = TextConstants.termsAndUseWelcomeText
        welcomeLabel.font = UIFont.TurkcellSaturaDemFont(size: 25)
        welcomeLabel.textColor = ColorConstants.darkBlueColor
       
        view.layoutIfNeeded()
        
        acceptButton.setTitle(TextConstants.termsAndUseStartUsingText, for: .normal)
        
        webView.clearPage()
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    func showEtk() {
        setupEtkText()
        view.layoutIfNeeded()
    }
    
    func showGlobalPermissions() {
        setupGlobalPermissionTextView()
        view.layoutIfNeeded()
    }
    
    private func setupIntroductionTextView() {
        checkboxesStack.addArrangedSubview(generalTermsCheckboxView)
        
        let header = NSMutableAttributedString(string: TextConstants.termsAndUseIntroductionCheckbox,
                                               attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 15),
                                                            .foregroundColor: ColorConstants.darkText])
        
        let rangeLink = header.mutableString.range(of: TextConstants.privacyPolicyCondition)
        header.addAttributes([.link: TextConstants.NotLocalized.privacyPolicyConditions], range: rangeLink)
        
        generalTermsCheckboxView.setup(atributedTitleText: header, atributedText: nil, delegate: self)
    }
    
    private func setupEtkText() {
        let etkChecboxView = TermsCheckboxTextView.initFromNib()
        etkTermsCheckboxView = etkChecboxView
        checkboxesStack.addArrangedSubview(etkChecboxView)
        
        let header = NSMutableAttributedString(string: TextConstants.termsAndUseEtkCheckboxHeader,
                                               attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 15),
                                                            .foregroundColor: ColorConstants.darkText])
        
        let descriptionText = NSMutableAttributedString(string: TextConstants.termsAndUseEtkCheckbox,
                                                 attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 12),
                                                              .foregroundColor: UIColor.lightGray])
        
        let rangeLink1 = descriptionText.mutableString.range(of: TextConstants.termsAndUseEtkLinkTurkcellAndGroupCompanies)
        descriptionText.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkTurkcellAndGroupCompanies], range: rangeLink1)
        
        let rangeLink2 = descriptionText.mutableString.range(of: TextConstants.termsAndUseEtkLinkCommercialEmailMessages)
        descriptionText.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkCommercialEmailMessages], range: rangeLink2)

        etkChecboxView.setup(atributedTitleText: header, atributedText: descriptionText, delegate: self)
    }

    func setupGlobalPermissionTextView() {
        let globalPermissionsView = TermsCheckboxTextView.initFromNib()
        globalDataPermissionTermsCheckboxView = globalPermissionsView
        checkboxesStack.addArrangedSubview(globalPermissionsView)
        
        let header = NSMutableAttributedString(string: TextConstants.termsOfUseGlobalPermHeader,
                                               attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 15),
                                                            .foregroundColor: ColorConstants.darkText])
        
        let descriptionText = NSMutableAttributedString(string: TextConstants.termsOfUseGlobalDataPermCheckbox,
                                                 attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 12),
                                                              .foregroundColor: UIColor.lightGray])
        let rangeLink1 = descriptionText.mutableString.range(of: TextConstants.termsOfUseGlobalDataPermLinkSeeDetails)
        descriptionText.addAttributes([.link: TextConstants.NotLocalized.termsOfUseGlobalDataPermLink1], range: rangeLink1)
        
        globalPermissionsView.setup(atributedTitleText: header, atributedText: descriptionText, delegate: self)
    }
    
    // MARK: Buttons action
    
    @IBAction func onStartUsing(_ sender: Any) {
        output.startUsing()
    }
}

// MARK: - TermsAndServicesViewInput
extension TermsAndServicesViewController: TermsAndServicesViewInput {
    
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

// MARK: - TermsCheckboxTextViewDelegate
extension TermsAndServicesViewController: TermsCheckboxTextViewDelegate {
    
    ///sender here is not a button but the whole view
    func checkBoxPressed(isSelected: Bool, sender: TermsCheckboxTextView) {
        
        if sender == generalTermsCheckboxView {
            output.confirmAgreements(isSelected)
        } else if let etkTermsCheckboxView = etkTermsCheckboxView,
            sender == etkTermsCheckboxView {
            output.confirmEtk(isSelected)
        } else if let globalDataPermissionTermsCheckboxView = globalDataPermissionTermsCheckboxView,
            sender == globalDataPermissionTermsCheckboxView {
            output.confirmGlobalPerm(isSelected)
        }
    }
    
    func tappedOnURL(url: URL) -> Bool {
        switch url.absoluteString {
        case TextConstants.NotLocalized.termsAndUseEtkLinkTurkcellAndGroupCompanies:
            DispatchQueue.toMain {
                self.output.openTurkcellAndGroupCompanies()
            }
        case TextConstants.NotLocalized.termsAndUseEtkLinkCommercialEmailMessages:
            DispatchQueue.toMain {
                self.output.openCommercialEmailMessages()
            }
        case TextConstants.NotLocalized.privacyPolicyConditions:
            DispatchQueue.toMain {
                self.output.openPrivacyPolicyDescriptionController()
            }
        case TextConstants.NotLocalized.termsOfUseGlobalDataPermLink1:
            DispatchQueue.toMain {
                self.output.openGlobalDataPermissionDetails()
            }
        default:
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        return true
    }
}
