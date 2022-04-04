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
    
    @IBOutlet private weak var contenViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var contenView: UIStackView! {
        willSet {
            newValue.spacing = 10
        }
    }
    
    @IBOutlet private weak var eulaTextView: UITextView! {
        willSet {
            newValue.setupEulaStyle()
            newValue.delegate = self
        }
    }
    
    @IBOutlet private weak var etkTextView: UITextView! {
        willSet {
            newValue.isHidden = true
            newValue.setupEulaStyle()
            newValue.delegate = self
        }
    }
    
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
    
    @IBOutlet private weak var privacyPolicyView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 6
            newValue.backgroundColor =  UIColor.lrTealishTwo.withAlphaComponent(0.05)
        }
    }
    
    @IBOutlet weak var privacyPolicyTextView: IntrinsicTextView! {
        willSet {
            newValue.delegate = self
            newValue.backgroundColor = .clear
            newValue.linkTextAttributes = [
                .foregroundColor: UIColor.lrTealishTwo,
                .underlineColor: UIColor.lrTealishTwo,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        }
    }
    
    private let generalTermsCheckboxView = TermsCheckboxTextView.initFromNib()
    private var etkTermsCheckboxView: TermsCheckboxTextView?
    private var globalDataPermissionTermsCheckboxView: TermsCheckboxTextView?
    
    //MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !Device.isIpad {
            setNavigationTitle(title: TextConstants.termsAndUsesTitle)
        }

        contenViewHeightConstraint.constant = Device.winSize.height * 0.5

        configureUI()
        setupIntroductionTextView()
        setupPrivacyPolicyTextView()
        output.viewIsReady()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideSpinnerIncludeNavigationBar()
    }
    
    //MARK: - Configuration and Input
    private func configureUI() {
        acceptButton.setTitle(TextConstants.termsAndUseStartUsingText, for: .normal)
    }
    
    func showEtk() {
        showEtkText()
        setupEtkCheckbox()
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
        
        generalTermsCheckboxView.setup(atributedTitleText: header, atributedText: nil, delegate: self, textViewDelegate: self)
    }
    
    private func setupPrivacyPolicyTextView() {
        
        let header = NSMutableAttributedString(string: TextConstants.privacyPolicy,
                                               attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 15),
                                                            .foregroundColor: ColorConstants.darkText])
        
        let rangeLink = header.mutableString.range(of: TextConstants.privacyPolicyCondition)
        header.addAttributes([.link: TextConstants.NotLocalized.privacyPolicyConditions], range: rangeLink)
        
        privacyPolicyTextView.attributedText = header
    }
    
    private func setupEtkCheckbox() {
        let etkChecboxView = TermsCheckboxTextView.initFromNib()
        etkTermsCheckboxView = etkChecboxView
        checkboxesStack.addArrangedSubview(etkChecboxView)
        
        let header = NSMutableAttributedString(string: TextConstants.termsAndUseEtkCheckboxHeader,
                                               attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 15),
                                                            .foregroundColor: ColorConstants.darkText])

        etkChecboxView.setup(atributedTitleText: header, atributedText: nil, delegate: self, textViewDelegate: self)
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
        
        globalPermissionsView.setup(atributedTitleText: header, atributedText: descriptionText, delegate: self, textViewDelegate: self)
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
        guard let htmlString = prepareHtml(from: eula) else {
            assertionFailure()
            return
        }
        
        // https://www.oipapio.com/question-726375
        eulaTextView.textStorage.append(htmlString)
        eulaTextView.dataDetectorTypes = [.phoneNumber, .address]
    }
    
    func showEtkText() {
        guard let htmlString = prepareHtml(from: TextConstants.etkHTMLText) else {
            assertionFailure()
            return
        }
        
        etkTextView.textStorage.append(htmlString)
        etkTextView.dataDetectorTypes = [.phoneNumber, .address]
        etkTextView.isHidden = false
    }
    
    private func prepareHtml(from text: String) -> NSAttributedString? {
        guard !text.isEmpty else {
            return nil
        }
        
        let font = UIFont.TurkcellSaturaRegFont(size: 14)
        /// https://stackoverflow.com/a/27422343
        //  body{font-family: '\(font.familyName)'; because turkcell fonts currently are not recognizable as family of fonts - all text from htm will be shown as regular, no bold and etc.
        let customFontString = "<style>font-size:\(font.pointSize);}</style>" + text
        
        guard let data = customFontString.data(using: .utf8) else {
            assertionFailure()
            return nil
        }
        
        /// https://stackoverflow.com/q/50969015/5893286
        /// fixed black screen
        /// and error "AttributedString called within transaction"
        do {
            let attributedString = try NSMutableAttributedString(data: data,
                                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                                          documentAttributes: nil)

            attributedString.addAttribute(.foregroundColor, value: AppColor.blackColor.color ?? .black, range: NSRange(location: 0, length: attributedString.length))
            return attributedString
        } catch {
            assertionFailure()
            return nil
        }
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
            return false
        }
        return true
    }
}

// MARK: - UITextViewDelegate
extension TermsAndServicesViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if tappedOnURL(url: URL) {
            return false
        }
        return defaultHandle(url: URL, interaction: interaction)
    }
}

private extension UITextView {
    func setupEulaStyle() {
        text = ""
        backgroundColor = AppColor.inactiveButtonColor.color
        layer.borderColor = ColorConstants.darkTintGray.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.cornerRadius = 10
        
        linkTextAttributes = [
            .foregroundColor: UIColor.lrTealishTwo,
            .underlineColor: UIColor.lrTealishTwo,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        dataDetectorTypes = [.link, .phoneNumber]
        isEditable = false
        
        /// to remove insets
        /// https://stackoverflow.com/a/42333832/5893286
        textContainer.lineFragmentPadding = 0
        let defaultInset: CGFloat = 14
        textContainerInset = UIEdgeInsets(top: defaultInset, left: defaultInset, bottom: defaultInset, right: defaultInset)
    }
}
