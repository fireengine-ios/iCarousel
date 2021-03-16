//
//  TermsAndServicesTermsAndServicesViewController.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import WebKit

final class TermsAndServicesViewController: ViewController {
    
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
    
    @IBOutlet private weak var acceptButton: UIButton! {
        willSet {
            newValue.layer.cornerRadius = 5
            newValue.setTitle(TextConstants.termsAndUseStartUsingText, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 14)
            newValue.backgroundColor = UIColor(named: "loginButtonBackground")
            newValue.isOpaque = true
        }
    }
    
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
            newValue.layer.cornerRadius = 5
            newValue.backgroundColor = ColorConstants.textViewBackground
        }
    }
    
    @IBOutlet weak var privacyPolicyTextView: IntrinsicTextView! {
        willSet {
            newValue.delegate = self
            newValue.backgroundColor = .clear
            newValue.linkTextAttributes = [
                NSAttributedStringKey.foregroundColor.rawValue: ColorConstants.Text.labelTitle,
                NSAttributedStringKey.font.rawValue: UIFont.GTAmericaStandardMediumFont(size: 12)
            ]
        }
    }
    
    private let generalTermsCheckboxView = TermsCheckboxTextView.initFromNib()
    private var etkTermsCheckboxView: TermsCheckboxTextView?
    private var globalDataPermissionTermsCheckboxView: TermsCheckboxTextView?
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideSpinnerIncludeNavigationBar()
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    //MARK: - Configuration and Input
    private func configureUI() {
        setupNavigationControler()
        
        contenViewHeightConstraint.constant = Device.winSize.height * 0.54
        setupIntroductionTextView()
        setupPrivacyPolicyTextView()
        output.viewIsReady()
    }
    
    private func setupNavigationControler() {
        whiteNavBarStyle()
        if !Device.isIpad {
            
            setNavigationTitle(title: TextConstants.termsAndUsesTitle)  // changed
        }
    }
    
    private func setupIntroductionTextView() {
        checkboxesStack.addArrangedSubview(generalTermsCheckboxView)
        
        let header = NSMutableAttributedString(string: TextConstants.termsAndUseIntroductionCheckbox,
                                               attributes: [.font: UIFont.GTAmericaStandardRegularFont(size: 14),
                                                            .foregroundColor: ColorConstants.darkText])
        generalTermsCheckboxView.setup(atributedTitleText: header, atributedText: nil, delegate: self, textViewDelegate: self)
    }
    
    private func setupPrivacyPolicyTextView() {
        
        let header = NSMutableAttributedString(string: TextConstants.privacyPolicy,
                                               attributes: [.font: UIFont.GTAmericaStandardRegularFont(size: 12),
                                                            .foregroundColor: ColorConstants.Text.labelTitle])
        
        let rangeLink = header.mutableString.range(of: TextConstants.privacyPolicyCondition)
        header.addAttributes([.link: TextConstants.NotLocalized.privacyPolicyConditions,
                              .font: UIFont.GTAmericaStandardMediumFont(size: 12)], range: rangeLink)
        
        privacyPolicyTextView.attributedText = header
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
        eulaTextView.attributedText = eula.attributedString
        eulaTextView.setupEulaStyle(cleaned: false)
    }
    
    func hideBackButton() {
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func noConfirmAgreements(errorString: String) {
        UIApplication.showErrorAlert(message: errorString)
    }
    
    func failLoadTermsAndUses(errorString: String) {
        UIApplication.showErrorAlert(message: errorString)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if #available(iOS 13, *) {
            (scrollView.subviews[(scrollView.subviews.count - 1)].subviews[0]).backgroundColor = UIColor(named: "loginButtonBackground")
        } else {
            if let verticalIndicator: UIImageView = (scrollView.subviews[(scrollView.subviews.count - 1)] as? UIImageView) {
                verticalIndicator.backgroundColor = UIColor(named: "loginButtonBackground")
            }
        }
    }
}

private extension UITextView {
    func setupEulaStyle(cleaned: Bool = true) {
        if cleaned {
            text = ""
        }
        
        backgroundColor = .white
        layer.borderColor = ColorConstants.profileGrayColor.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.cornerRadius = 5
        
        font = UIFont.GTAmericaStandardRegularFont(size: 11)
        textColor = ColorConstants.lightText
        
        linkTextAttributes = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.darkText,
            NSAttributedStringKey.font.rawValue: UIFont.GTAmericaStandardMediumFont(size: 12)
        ]
        
        dataDetectorTypes = [.link, .phoneNumber]
        isEditable = false
        
        textContainer.lineFragmentPadding = 0
        let defaultInset: CGFloat = 14
        textContainerInset = UIEdgeInsets(top: defaultInset, left: defaultInset, bottom: defaultInset, right: defaultInset)
    }
}
