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
        //remove me
            setupEtkText()
            setupGlobalPermissionTextView()
        //remove me
        output.viewIsReady()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideSpinnerIncludeNavigationBar()
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
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
//        updateWebViewInsets()
    }
    
    /// fixing bug of WKWebView contentInset after relayout
    private func updateWebViewInsets() {
        /*
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: etkTextView.bounds.height + etkTopSpaceConstraint.constant, right: 0)
        webView.scrollView.contentInset = insets
        webView.scrollView.scrollIndicatorInsets = insets
 */
    }
    
    private func setupEtkText() {
        let baseText = NSMutableAttributedString(string: TextConstants.termsAndUseEtkCheckbox,
                                                 attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 12),
                                                              .foregroundColor: ColorConstants.darkText])
        
        let rangeLink1 = baseText.mutableString.range(of: TextConstants.termsAndUseEtkLinkTurkcellAndGroupCompanies)
        baseText.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkTurkcellAndGroupCompanies], range: rangeLink1)
        
        let rangeLink2 = baseText.mutableString.range(of: TextConstants.termsAndUseEtkLinkCommercialEmailMessages)
        baseText.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkCommercialEmailMessages], range: rangeLink2)
        let etkChecboxView = TermsCheckboxTextView.initFromNib()
        etkTermsCheckboxView = etkChecboxView
        checkboxesStack.addArrangedSubview(etkChecboxView)
        etkChecboxView.setup(atributedTitleText: NSMutableAttributedString(string: "!TEST!"), atributedText: baseText, delegate: self)
    }
    
    private func setupIntroductionTextView() {

        let baseText = NSMutableAttributedString(string: TextConstants.termsAndUseIntroductionCheckbox,
                                                 attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 15),
                                                              .foregroundColor: ColorConstants.darkText])
        
        let rangeLink = baseText.mutableString.range(of: TextConstants.privacyPolicyCondition)
        baseText.addAttributes([.link: TextConstants.NotLocalized.privacyPolicyConditions], range: rangeLink)
        checkboxesStack.addArrangedSubview(generalTermsCheckboxView)
        generalTermsCheckboxView.setup(atributedTitleText: baseText, atributedText: NSMutableAttributedString(string: ""), delegate: self)
        
    }

    func setupGlobalPermissionTextView() {
        let baseText = NSMutableAttributedString(string: TextConstants.termsAndUseEtkCheckbox,
                                                 attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 12),
                                                              .foregroundColor: ColorConstants.darkText])
        
        let rangeLink1 = baseText.mutableString.range(of: TextConstants.termsAndUseEtkLinkTurkcellAndGroupCompanies)
        baseText.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkTurkcellAndGroupCompanies], range: rangeLink1)
        
        let rangeLink2 = baseText.mutableString.range(of: TextConstants.termsAndUseEtkLinkCommercialEmailMessages)
        baseText.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkCommercialEmailMessages], range: rangeLink2)
        
        let globalPermissionsView = TermsCheckboxTextView.initFromNib()
        globalDataPermissionTermsCheckboxView = globalPermissionsView
        checkboxesStack.addArrangedSubview(globalPermissionsView)
        globalPermissionsView.setup(atributedTitleText: NSMutableAttributedString(string: "!TEST!"), atributedText: baseText, delegate: self)
    }
    
    // MARK: Buttons action
    
    @IBAction func onStartUsing(_ sender: Any) {
        output.startUsing()
    }

    deinit {
        webView.navigationDelegate = nil
        webView.stopLoading()
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
            //TODO: ADD OUTPUT HERE
            //output.confirmGlobalPermission
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
