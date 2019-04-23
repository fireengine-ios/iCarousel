//
//  UserProfileDetailView.swift
//  Depo
//
//  Created by Raman Harhun on 4/19/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class ProfileFieldView: UIView {
    
    //MARK: Vars (private)
    private let descriptionLabel: UILabel = {
        let newValue = UILabel()
        
        newValue.textColor = UIColor.lrTealish
        newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        newValue.isOpaque = true

        return newValue
    }()
    
    private let textField: UITextField = {
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
    
    private let alertLabel: UILabel = {
        let newValue = UILabel()
        
        newValue.text = TextConstants.userProfileTurkcellGSMAlert
        newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
        newValue.textColor = ColorConstants.orangeGradient
        newValue.isHidden = true
        newValue.isOpaque = true

        return newValue
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(dateDidChanged), for: .valueChanged)
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.isOpaque = true

        return datePicker
    }()
    
    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.isOpaque = true
        
        toolbar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 50)
        toolbar.sizeToFit()
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                   target: nil,
                                   action: nil)
        
        ///for now it's last editable field
        let done = UIBarButtonItem(barButtonSystemItem: .done,
                                   target: self,
                                   action: #selector(resignFirstResponder))
        done.tintColor = UIColor.lrTealish
        
        toolbar.setItems([flex, done], animated: false)
        
        return toolbar
    }()
    
    private let underlineLayer = CALayer()
    private let underlineHeight: CGFloat = 0.5
    
    private let stackViewTopOffset: CGFloat = 4
    
    private var blockFieldIfNeeded: (() -> ())?
    private var stackViewTopConstraint: NSLayoutConstraint?
    
    //MARK: Vars (Public)
    var editableText: String? {
        return textField.text
    }
    
    var isEditState: Bool = false {
        didSet {
            blockFieldIfNeeded?()
            textField.isUserInteractionEnabled = isEditState
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
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
    private func setup() {
        setupViews()
        setupUnderline()
        textField.isUserInteractionEnabled = false
    }
    
    private func setupViews() {
        addSubview(descriptionLabel)
        addSubview(alertLabel)
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
        
        stackView.addArrangedSubview(alertLabel)
        stackView.addArrangedSubview(textField)
        
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
    
    @objc private func dateDidChanged(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM YYYY"
        
        let dateString = dateFormatter.string(from: datePicker.date)
        textField.text = dateString
    }
    
    //MARK: Utility Methods (public)
    func configure(with text: String?, delegate: UITextFieldDelegate) {
        textField.text = text
        textField.delegate = delegate
    }
    
    func setupAsPassword() {
        title = TextConstants.userProfilePassword
        textField.text = "* * * * * * * * *"
        textField.isUserInteractionEnabled = false
    }
    
    func setupAsBirthday() {
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
        textField.placeholder = TextConstants.userProfileBirthdayPlaceholder
    }
    
    func setupAsTurkcellGSMIfNeeded() {
        guard SingletonStorage.shared.isTurkcellUser else {
            return
        }
        
        blockFieldIfNeeded = { [weak self] in
            guard let `self` = self else {
                return
            }
            
            let alpha: CGFloat = self.isEditState ? 0.25 : 1
            self.textField.textColor = UIColor.black.withAlphaComponent(alpha)

            UIView.animate(withDuration: NumericConstants.animationDuration, animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.alertLabel.isHidden = !self.isEditState
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
}
