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

    // MARK: - Views
    @IBOutlet private weak var checkboxesStackView: UIStackView!
    @IBOutlet private weak var privacyPolicyView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 6
            newValue.backgroundColor =  UIColor.lrTealishTwo.withAlphaComponent(0.05)
        }
    }
    @IBOutlet private weak var privacyPolicyTextView: IntrinsicTextView! {
        willSet {
            newValue.delegate = self
            newValue.backgroundColor = .clear
            newValue.linkTextAttributes = [
                NSAttributedStringKey.foregroundColor.rawValue: UIColor.lrTealishTwo,
                NSAttributedStringKey.underlineColor.rawValue: UIColor.lrTealishTwo,
                NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue
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
        let header = NSMutableAttributedString(string: TextConstants.termsAndUseIntroductionCheckbox,
                                               attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 15),
                                                            .foregroundColor: ColorConstants.darkText])

        let rangeLink1 = header.mutableString.range(of: TextConstants.termsOfUseCell)
        header.addAttributes([.link: TextConstants.NotLocalized.termsOfUseLink], range: rangeLink1)

        termsCheckboxView.setup(atributedTitleText: header, atributedText: nil, delegate: self, textViewDelegate: self)
        termsCheckboxView.titleView.delegate = self
        checkboxesStackView.addArrangedSubview(termsCheckboxView)
    }

    private func setupEtkCheckbox() {
        etkCheckboxView = TermsCheckboxTextView.initFromNib()

        let header = NSMutableAttributedString(string: TextConstants.termsAndUseEtkCheckboxHeader,
                                               attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 15),
                                                            .foregroundColor: ColorConstants.darkText])

        let rangeLink1 = header.mutableString.range(of: TextConstants.termsAndUseEtkLinkCommercialEmailMessages)
        header.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkCommercialEmailMessages], range: rangeLink1)

        etkCheckboxView.setup(atributedTitleText: header, atributedText: nil, delegate: self, textViewDelegate: self)
        etkCheckboxView.titleView.delegate = self
        checkboxesStackView.addArrangedSubview(etkCheckboxView)
    }

    private func setupPrivacyPolicyTextView() {

        let header = NSMutableAttributedString(string: TextConstants.privacyPolicy,
                                               attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 15),
                                                            .foregroundColor: ColorConstants.darkText])

        let rangeLink = header.mutableString.range(of: TextConstants.privacyPolicyCondition)
        header.addAttributes([.link: TextConstants.NotLocalized.privacyPolicyConditions], range: rangeLink)

        privacyPolicyTextView.attributedText = header
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

