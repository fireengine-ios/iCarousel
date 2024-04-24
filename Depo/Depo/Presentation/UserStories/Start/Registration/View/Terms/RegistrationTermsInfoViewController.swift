//
//  RegistrationTermsInfoViewController.swift
//  Depo
//
//  Created by Hady on 4/22/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

/*
 Terms details are displayed here with a confirm button.
 This view controller is presented from RegistrationViewController.
 */

class RegistrationTermsInfoViewController: UIViewController {
    private var text: String!
    private var confirmed: VoidHandler?

    convenience init(text: String, confirmed: VoidHandler? = nil) {
        self.init(nibName: nil, bundle: nil)
        self.text = text
        self.confirmed = confirmed
    }

    func present(over viewController: UIViewController) {
        modalPresentationStyle = .overFullScreen
        viewController.present(self, animated: false)
    }
    
    // MARK: - Views
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var popupHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var containerView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 16
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.appFont(.medium, size: 14)
            newValue.textColor = AppColor.registerLabelTextColor.color
        }
    }

    @IBOutlet private weak var closeButton: UIButton! {
        willSet {
            newValue.setImage(UIImage(named: "CloseCardIcon"), for: .normal)
            newValue.tintColor = AppColor.registerLabelTextColor.color
            newValue.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        }
    }

    @IBOutlet private weak var textView: UITextView! {
        willSet {
            newValue.setupInfoEulaStyle()
            newValue.delegate = self
        }
    }

    @IBOutlet weak var confirmButton: RoundedInsetsButton! {
        willSet {
            newValue.setBackgroundColor(AppColor.registerNextButtonNormal.color, for: .normal)
            newValue.setBackgroundColor(.white, for: .disabled)
            newValue.setTitleColor(.white, for: .normal)
            newValue.setTitleColor(AppColor.registerNextButtonNormalTextColor.color, for: .disabled)
            newValue.titleLabel?.font = UIFont.appFont(.medium, size: 16)
            newValue.isOpaque = true
            newValue.setTitle(TextConstants.signupRedesignEulaAcceptButton, for: .normal)
            newValue.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

            newValue.layer.cornerRadius = 23
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = AppColor.registerNextButtonNormal.cgColor
        }
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        confirmButton.isHidden = confirmed == nil
        setupTextView()
        
        scrollView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.flashScrollIndicators()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        popupHeightConstraint.constant = scrollView.contentSize.height
    }

    // MARK: - Actions
    @objc private func confirmTapped() {
        confirmed?()
        dismiss()
    }

    @objc private func closeTapped() {
        dismiss()
    }

    private func dismiss() {
        dismiss(animated: false)
    }

    // MARK: - TextView Setup
    private func setupTextView() {
        guard let text = self.text else {
            assertionFailure()
            return
        }
        
        guard let htmlString = prepareHtml(from: text) else {
            assertionFailure()
            return
        }

        textView.textStorage.append(htmlString)
        textView.dataDetectorTypes = [.phoneNumber, .address]
        
        titleLabel.text = htmlString.string.firstLine
    }

    private func prepareHtml(from text: String) -> NSAttributedString? {
        guard !text.isEmpty else {
            return nil
        }

        let font = UIFont.appFont(.regular, size: 16)
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

            attributedString.addAttribute(.foregroundColor, value: AppColor.registerLabelTextColor.color,
                                          range: NSRange(location: 0, length: attributedString.length))
            return attributedString
        } catch {
            assertionFailure()
            return nil
        }
    }
}

// MARK: - UITextViewDelegate
extension RegistrationTermsInfoViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return defaultHandle(url: URL, interaction: interaction)
    }
}

// MARK: - TextView Style
private extension UITextView {
    func setupInfoEulaStyle() {
        text = ""
        backgroundColor = AppColor.secondaryBackground.color
        layer.masksToBounds = true
        layer.cornerRadius = 10

        linkTextAttributes = [
            .foregroundColor: UIColor.lrTealishTwo,
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

extension RegistrationTermsInfoViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
           let offsetY = scrollView.contentOffset.y
           let contentHeight = scrollView.contentSize.height
           let frameHeight = scrollView.bounds.size.height

           if offsetY + frameHeight >= contentHeight {
               confirmButton.isEnabled = true
           } else {
               confirmButton.isEnabled = false
           }
       }

}
