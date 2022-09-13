//
//  RegistrationTermsViewController.swift
//  Depo
//
//  Created by Hady on 4/22/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

/*
 Terms of use & ETK checkboxes and privacy policy contianer view controller.
 Used as a child view controller in RegistrationViewController
 */

protocol RegistrationTermsViewControllerDelegate: AnyObject {
    func confirmTermsOfUse(_ confirm: Bool)
    func confirmEtkTerms(_ confirm: Bool)
    func termsOfUseTapped()
    func etkTermsTapped()
    func privacyPolicyTapped()
}

final class RegistrationTermsViewController: UIViewController {
    // MARK: - Interface
    weak var delegate: RegistrationTermsViewControllerDelegate?
    
    func setupEtk(isShowEtk: Bool) {
        if isShowEtk {
            setupEtkCheckbox()
        } else {
            etkCheckboxView?.isHidden = true
        }
    }
    
    var isTermsOfUseChecked: Bool {
        get { termsCheckboxView.isChecked }
        set { termsCheckboxView.isChecked = newValue }
    }
    
    var isEtkChecked: Bool {
        get { etkCheckboxView?.isChecked ?? false }
        set { etkCheckboxView.isChecked = newValue }
    }
    
    // MARK: - Views
    @IBOutlet private weak var checkboxesStackView: UIStackView!
    @IBOutlet private weak var privacyPolicyView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 16
            newValue.backgroundColor =  AppColor.registerPrivacyPolicy.color
        }
    }
    @IBOutlet private weak var privacyPolicyTextView: IntrinsicTextView! {
        willSet {
            newValue.delegate = self
            newValue.backgroundColor = .clear
            newValue.linkTextAttributes = [
                .foregroundColor: AppColor.registerLabelTextColor.color
            ]
        }
    }
    private let termsCheckboxView = TermsCheckboxTextView.initFromNib()
    private var etkCheckboxView: TermsCheckboxTextView! {
        didSet {
            if let oldValue = oldValue {
                oldValue.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTermsCheckbox()
        setupPrivacyPolicyTextView()
    }
    
    private func setupTermsCheckbox() {
        let string = buildCheckboxString(from: TextConstants.signupRedesignEulaCheckbox,
                                         linkText: TextConstants.signupRedesignEulaLink,
                                         link: TextConstants.NotLocalized.termsOfUseLink)
        
        termsCheckboxView.setup(atributedTitleText: string, atributedText: nil, delegate: self, textViewDelegate: self)
        termsCheckboxView.titleView.delegate = self
        checkboxesStackView.addArrangedSubview(termsCheckboxView)
    }
    
    private func setupEtkCheckbox() {
        etkCheckboxView = TermsCheckboxTextView.initFromNib()
        
        let string = buildCheckboxString(from: TextConstants.signupRedesignEtkCheckbox,
                                         linkText: TextConstants.signupRedesignEtkLink,
                                         link: TextConstants.NotLocalized.termsAndUseEtkLinkCommercialEmailMessages)
        
        etkCheckboxView.setup(atributedTitleText: string, atributedText: nil, delegate: self, textViewDelegate: self)
        etkCheckboxView.titleView.delegate = self
        checkboxesStackView.addArrangedSubview(etkCheckboxView)
    }
    
    private func setupPrivacyPolicyTextView() {
        
        let header = NSMutableAttributedString(string: TextConstants.privacyPolicy, attributes: [.font: UIFont.appFont(.regular, size: 15),                                  .foregroundColor: AppColor.registerLabelTextColor.color])
        
        let rangeLink = header.mutableString.range(of: TextConstants.privacyPolicyCondition)
        header.addAttributes([.link:                                    TextConstants.NotLocalized.privacyPolicyConditions,
                              .font: UIFont.appFont(.medium, size: 15),
                              .foregroundColor: AppColor.registerLabelTextColor.color],
                             range: rangeLink)
        privacyPolicyTextView.attributedText = header
    }
    
    private func buildCheckboxString(from text: String, linkText: String, link: String) -> NSMutableAttributedString {
        let textFormat = text.replacingOccurrences(of: "%1$S", with: "%1$@")
        let textWithLink = String(format: textFormat, linkText)
        let result = NSMutableAttributedString(string: textWithLink,
                                               attributes: [.font: UIFont.appFont(.regular, size: 15),
                                                            .foregroundColor: AppColor.registerLabelTextColor.color])
        
        let linkRange = result.mutableString.range(of: linkText)
        result.addAttributes([.link: link,
                              .font: UIFont.appFont(.medium, size: 15),
                              .foregroundColor: AppColor.registerLabelTextColor.color],
                             range: linkRange)
        return result
    }
}

// MARK: - TermsCheckboxTextViewDelegate
extension RegistrationTermsViewController: TermsCheckboxTextViewDelegate {
    func checkBoxPressed(isSelected: Bool, sender: TermsCheckboxTextView) {
        if sender == termsCheckboxView {
            delegate?.confirmTermsOfUse(isSelected)
        } else if sender == etkCheckboxView {
            delegate?.confirmEtkTerms(isSelected)
        }
    }
}

// MARK: - UITextViewDelegate
extension RegistrationTermsViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if tappedOnURL(url: URL) {
            return false
        }
        return defaultHandle(url: URL, interaction: interaction)
    }

    private func tappedOnURL(url: URL) -> Bool {
        switch url.absoluteString {
        case TextConstants.NotLocalized.termsOfUseLink:
            delegate?.termsOfUseTapped()
            break
        case TextConstants.NotLocalized.termsAndUseEtkLinkCommercialEmailMessages:
            delegate?.etkTermsTapped()
            break
        case TextConstants.NotLocalized.privacyPolicyConditions:
            delegate?.privacyPolicyTapped()
        default:
            return false
        }
        return true
    }
}

