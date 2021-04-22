//
//  RegistrationTermsInfoViewController.swift
//  Depo
//
//  Created by Hady on 4/22/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

/*
 Terms details are displayed here with a confirm button.
 This view controller is presented from RegistrationViewController.
 */

class RegistrationTermsInfoViewController: UIViewController {
    private var text: String!
    private var confirmed: VoidHandler?

    convenience init(text: String, confirmed: @escaping VoidHandler) {
        self.init(nibName: nil, bundle: nil)
        self.text = text
        self.confirmed = confirmed
    }

    func present(over viewController: UIViewController) {
        modalPresentationStyle = .overFullScreen
        viewController.present(self, animated: false)
    }

    // MARK: - Views
    @IBOutlet private weak var popupHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var containerView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 10
        }
    }

    @IBOutlet private weak var closeButton: UIButton! {
        willSet {
            newValue.setImage(UIImage(named: "CloseCardIcon"), for: .normal)
            newValue.tintColor = .black
            newValue.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        }
    }

    @IBOutlet private weak var textView: UITextView! {
        willSet {
            newValue.setupInfoEulaStyle()
            newValue.delegate = self
        }
    }

    @IBOutlet private weak var bottomView: UIView! {
        willSet {
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOpacity = 0.1
            newValue.layer.shadowOffset = CGSize(width: 0, height: -4)
            newValue.layer.shadowRadius = 18
        }
    }

    @IBOutlet private weak var confirmButton: BlueButtonWithWhiteText! {
        willSet {
            newValue.setTitle("Onaylıyorum", for: .normal)
            newValue.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        }
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        setupTextView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        confirmButton.isEnabled = textView.contentSize.height <= containerView.frame.height
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

        popupHeightConstraint.constant = textView.contentSize.height + bottomView.frame.height
    }

    private func prepareHtml(from text: String) -> NSAttributedString? {
        guard !text.isEmpty else {
            return nil
        }

        let font = UIFont.TurkcellSaturaRegFont(size: 16)
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
            let attributedString = try NSAttributedString(data: data,
                                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                                          documentAttributes: nil)
            return attributedString
        } catch {
            assertionFailure()
            return nil
        }
    }
}

// MARK: - UITextViewDelegate
extension RegistrationTermsInfoViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == textView else { return }
        if textView.contentOffset.y + textView.frame.height >= textView.contentSize.height {
            confirmButton.isEnabled = true
        }
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return defaultHandle(url: URL, interaction: interaction)
    }
}

// MARK: - TextView Style
private extension UITextView {
    func setupInfoEulaStyle() {
        text = ""
        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 10

        linkTextAttributes = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.lrTealishTwo,
            NSAttributedStringKey.underlineColor.rawValue: UIColor.lrTealishTwo,
            NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue
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
