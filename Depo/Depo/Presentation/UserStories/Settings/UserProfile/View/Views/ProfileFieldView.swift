//
//  UserProfileDetailView.swift
//  Depo
//
//  Created by Raman Harhun on 4/19/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class ProfileFieldView: UIView {
    
    //MARK: Vars (private)
    private let descriptionLabel: UILabel = {
        let newValue = UILabel()
        
        newValue.textColor = UIColor.lrTealish
        newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        newValue.isOpaque = true

        return newValue
    }()
    
    let textField: UITextField = {
        let newValue = UITextField()
        
        newValue.textColor = UIColor.black
        newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
        newValue.autocorrectionType = .yes
        newValue.autocapitalizationType = .words
        
        ///last field is datePicker. No need more logic for returnKeyType
        newValue.returnKeyType = .next
        newValue.isOpaque = true

        return newValue
    }()
    
    private let alertTextView: UITextView = {
        let newValue = UITextView()
        
        newValue.text = TextConstants.userProfileTurkcellGSMAlert
        newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
        newValue.textColor = ColorConstants.orangeGradient
        newValue.isHidden = true
        newValue.isOpaque = true
        newValue.isEditable = false
        newValue.isScrollEnabled = false
        newValue.linkTextAttributes = [:]
        newValue.translatesAutoresizingMaskIntoConstraints = true

        return newValue
    }()
    
    let textFieldStackView: UIStackView = {
        let newValue = UIStackView()
        
        newValue.spacing = 1
        newValue.axis = .horizontal
        newValue.alignment = .fill
        newValue.distribution = .fill
        
        return newValue
    }()
    
    let underlineLayer = CALayer()
    let underlineHeight: CGFloat = 0.5
    let stackViewTopOffset: CGFloat = 4
    
    private var blockFieldIfNeeded: (() -> ())?
    private var stackViewTopConstraint: NSLayoutConstraint?
    
    //MARK: Vars (Public)
    var editableText: String? {
        return textField.text
    }
    
    var isEditState: Bool = false {
        didSet {
            textField.isUserInteractionEnabled = isEditState
            blockFieldIfNeeded?()
        }
    }
    
    var title: String = "" {
        didSet {
            descriptionLabel.text = title
        }
    }
    
    var responderOnNext: ProfileFieldView?

    override var isFirstResponder: Bool {
        return textField.isFirstResponder
    }

    //MARK: init/deinit
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        underlineLayer.frame = CGRect(x: 0,
                                      y: frame.size.height - underlineHeight,
                                      width: frame.width,
                                      height: underlineHeight)
    }
    
    //MARK: Utility Methods (private)
    func setup() {
        setupViews()
        setupUnderline()
        textField.isUserInteractionEnabled = false
    }
    
    private func setupViews() {
        addSubview(textFieldStackView)
        addSubview(descriptionLabel)
        addSubview(alertTextView)
        addSubview(textField)

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.isOpaque = true
        addSubview(stackView)
        
        textFieldStackView.addArrangedSubview(textField)

        stackView.addArrangedSubview(alertTextView)
        stackView.addArrangedSubview(textFieldStackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4).isActive = true
        
        stackViewTopConstraint = stackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor)
        stackViewTopConstraint?.constant = stackViewTopOffset
        stackViewTopConstraint?.isActive = true
    }
    
    private func setupUnderline() {
        layer.addSublayer(underlineLayer)
        underlineLayer.backgroundColor = ColorConstants.lightGrayColor.cgColor
    }
    
    //MARK: Utility Methods (public)
    func configure(with text: String?, delegate: UITextFieldDelegate) {
        textField.text = text
        textField.delegate = delegate
    }
    
    func setupAsTurkcellGSMIfNeeded() {
        guard SingletonStorage.shared.isTurkcellUser else {
            return
        }
        
        let alertText = String(format: TextConstants.userProfileTurkcellGSMAlert,
                               TextConstants.myProfileFAQ)
        let attributedText = NSMutableAttributedString(string: alertText, attributes: [
            .font : UIFont.TurkcellSaturaDemFont(size: 16),
            .foregroundColor : ColorConstants.orangeGradient
        ])
        
        if let range = alertText.range(of: TextConstants.myProfileFAQ) {
            let nsRange = NSRange(range, in: alertText)
            
            let attributes: [NSAttributedStringKey : Any] = [
                .link : TextConstants.NotLocalized.FAQ,
                .underlineStyle : NSUnderlineStyle.styleSingle.rawValue,
                .foregroundColor : ColorConstants.orangeGradient
            ]
            
            attributedText.addAttributes(attributes, range: nsRange)
        }
        
        alertTextView.attributedText = attributedText
        alertTextView.delegate = self
        
        blockFieldIfNeeded = { [weak self] in
            guard let `self` = self else {
                return
            }
            
            let alpha: CGFloat = self.isEditState ? 0.25 : 1
            self.textField.textColor = UIColor.black.withAlphaComponent(alpha)
            self.textField.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: NumericConstants.animationDuration, animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.alertTextView.isHidden = !self.isEditState
                ///need to follow the design
                self.stackViewTopConstraint?.constant = self.isEditState ? 0 : self.stackViewTopOffset
                /// https://stackoverflow.com/a/46412621/5893286
                self.layoutIfNeeded()
            })
        }
    }
    
    func setupAsEmail() {
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
    }
    
    func getTextField() -> UITextField {
        return textField
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        guard blockFieldIfNeeded == nil else {
            responderOnNext?.becomeFirstResponder()
            return false
        }
        
        return textField.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    private func openFAQ() {
        let router = RouterVC()
        let controller = router.helpAndSupport
        router.pushViewController(viewController: controller)
    }
}

extension ProfileFieldView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        if URL.absoluteString == TextConstants.NotLocalized.FAQ {
            openFAQ()
        }
        
        return true
    }
    
}
