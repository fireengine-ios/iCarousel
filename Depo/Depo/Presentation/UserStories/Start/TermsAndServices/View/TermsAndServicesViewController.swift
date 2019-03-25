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
    @IBOutlet private weak var checkboxLabel: UILabel!
    @IBOutlet private weak var acceptButton: BlueButtonWithWhiteText!
    
    @IBOutlet private weak var topContraintIOS10: NSLayoutConstraint!
    @IBOutlet private weak var topContraintIOS11: NSLayoutConstraint!
    
    @IBOutlet private weak var etkCheckboxButton: UIButton!
    @IBOutlet private weak var etkTextView: UITextView!
    
    private let eulaService = EulaService()
    
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
        checkEtk()
        output.viewIsReady()
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }

    private func configureUI() {
        welcomeLabel.text = TextConstants.termsAndUseWelcomeText
        welcomeLabel.font = UIFont.TurkcellSaturaDemFont(size: 25)
        welcomeLabel.textColor = ColorConstants.darkBlueColor
        
        checkboxLabel.text = TextConstants.termsAndUseCheckboxText
        checkboxLabel.font = UIFont.TurkcellSaturaRegFont(size: 12)
        checkboxLabel.textColor = ColorConstants.darkText
        
        /// to remove insets
        /// https://stackoverflow.com/a/42333832/5893286
        etkTextView.textContainer.lineFragmentPadding = 0
        etkTextView.textContainerInset = .zero
        
        etkTextView.text = " "
        etkTextView.delegate = self
        
        //hideEtk()
        setupEtkText()
        
        acceptButton.setTitle(TextConstants.termsAndUseStartUsingText, for: .normal)
        
        webView.clearPage()
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    private func checkEtk() {
        eulaService.getEtkAuth(for: "+380962868642") { result in
            switch result {
            case .success(let isShowEtk):
                print(isShowEtk)
                print()
                //showEtk()
                //setupEtkText()
            case .failed(let error):
                /// nothing to show user
                print(error.localizedDescription)
            }
        }
    }
    
    private func showEtk() {
        etkTextView.isHidden = false
        etkCheckboxButton.isHidden = false
    }
    
    private func hideEtk() {
        etkTextView.isHidden = true
        etkCheckboxButton.isHidden = true
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
        
        let rangeLink1 = baseText.mutableString.range(of: TextConstants.termsAndUseEtkLink1)
        baseText.addAttributes([.link: TextConstants.NotLocalized.termsOfUseEtkLink1], range: rangeLink1)
        
        let rangeLink2 = baseText.mutableString.range(of: TextConstants.termsAndUseEtkLink2)
        baseText.addAttributes([.link: TextConstants.NotLocalized.termsOfUseEtkLink2], range: rangeLink2)
        
        etkTextView.attributedText = baseText
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

// MARK: - UITextViewDelegate
extension TermsAndServicesViewController: UITextViewDelegate {
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        switch URL.absoluteString {
        case TextConstants.NotLocalized.termsOfUseEtkLink1:
            DispatchQueue.toMain {
                //self.output.openTermsOfUseScreen
            }
        case TextConstants.NotLocalized.termsOfUseEtkLink2:
            DispatchQueue.toMain {
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
