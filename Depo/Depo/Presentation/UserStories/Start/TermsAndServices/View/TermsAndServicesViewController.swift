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

    @IBOutlet private weak var welcomeLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var checkboxButton: UIButton!

    @IBOutlet private weak var acceptButton: BlueButtonWithWhiteText!
    
    @IBOutlet private weak var topContraintIOS10: NSLayoutConstraint!
    @IBOutlet private weak var topContraintIOS11: NSLayoutConstraint!
    
    @IBOutlet private weak var introdactionTextView: UITextView!
    
    @IBOutlet private weak var etkCheckboxButton: UIButton!
    @IBOutlet private weak var etkTextView: UITextView!
    @IBOutlet private weak var etkTopSpaceConstraint: NSLayoutConstraint!
    
    private let webView: WKWebView = {
        let contentController = WKUserContentController()
         let scriptSource = "document.body.style.color = 'white'; document.body.style.webkitTextSizeAdjust = 'auto';"
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(script)
        
        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = contentController
        if #available(iOS 10.0, *) {
            webConfig.dataDetectorTypes = [.phoneNumber, .link]
        }
        
        let webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.isOpaque = false
//        webView.backgroundColor = UIColor.white
        
        /// there is a bug for iOS 9
        /// https://stackoverflow.com/a/32843700/5893286
        webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        return webView
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
        setupIntroductionTextView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
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
        
        /// to remove insets
        /// https://stackoverflow.com/a/42333832/5893286
        etkTextView.textContainer.lineFragmentPadding = 0
        etkTextView.textContainerInset = .zero
        etkTextView.text = ""
        etkTextView.delegate = self
        
        introdactionTextView.textContainer.lineFragmentPadding = 0
        introdactionTextView.textContainerInset = .zero
        introdactionTextView.text = ""
        introdactionTextView.delegate = self
        
        // TODO: change this logic for StackView one
        etkTextView.isHidden = true
        etkCheckboxButton.isHidden = true
        etkTopSpaceConstraint.constant = -30 //magic number for design
        
        view.layoutIfNeeded()
        
        acceptButton.setTitle(TextConstants.termsAndUseStartUsingText, for: .normal)
        
        webView.clearPage()
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    func showEtk() {
        setupEtkText()
        etkTextView.isHidden = false
        etkCheckboxButton.isHidden = false
        etkTopSpaceConstraint.constant = 16 //magic number for design
        
        view.layoutIfNeeded()
        updateWebViewInsets()
    }
    
    /// fixing bug of WKWebView contentInset after relayout
    private func updateWebViewInsets() {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: etkTextView.bounds.height + etkTopSpaceConstraint.constant, right: 0)
        webView.scrollView.contentInset = insets
        webView.scrollView.scrollIndicatorInsets = insets
    }
    
    private func setupEtkText() {
        etkTextView.linkTextAttributes = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.lrTealishTwo,
            NSAttributedStringKey.underlineColor.rawValue: UIColor.lrTealishTwo,
            NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue
        ]
        
        let baseText = NSMutableAttributedString(string: TextConstants.termsAndUseEtkCheckbox,
                                                 attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 12),
                                                              .foregroundColor: ColorConstants.darkText])
        
        let rangeLink1 = baseText.mutableString.range(of: TextConstants.termsAndUseEtkLinkTurkcellAndGroupCompanies)
        baseText.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkTurkcellAndGroupCompanies], range: rangeLink1)
        
        let rangeLink2 = baseText.mutableString.range(of: TextConstants.termsAndUseEtkLinkCommercialEmailMessages)
        baseText.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkCommercialEmailMessages], range: rangeLink2)
        
        etkTextView.attributedText = baseText
    }
    
    private func setupIntroductionTextView() {
        introdactionTextView.linkTextAttributes = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.lrTealishTwo,
            NSAttributedStringKey.underlineColor.rawValue: UIColor.lrTealishTwo,
            NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue
        ]
        
        let baseText = NSMutableAttributedString(string: TextConstants.termsAndUseIntroductionCheckbox,
                                                 attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 15),
                                                              .foregroundColor: ColorConstants.darkText])
        
        let rangeLink = baseText.mutableString.range(of: TextConstants.privacyPolicyCondition)
        baseText.addAttributes([.link: TextConstants.NotLocalized.privacyPolicyConditions], range: rangeLink)
        
        introdactionTextView.attributedText = baseText
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
    
    @IBAction func onEtkCheckbox(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        button.isSelected = !button.isSelected
        
        output.confirmEtk(button.isSelected)
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

// MARK: - UITextViewDelegate
extension TermsAndServicesViewController: UITextViewDelegate {
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        switch URL.absoluteString {
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
           UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        }
        
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return UIApplication.shared.openURL(URL)
    }
}
