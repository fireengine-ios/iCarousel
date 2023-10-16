//
//  ProfileBirthdayFieldView.swift
//  Depo
//
//  Created by Raman Harhun on 4/24/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class ProfileBirthdayFieldView: ProfileFieldView {
    
    private let dayLayer: CALayer = {
        let newValue = CALayer()
        
        newValue.backgroundColor = AppColor.borderColor.color.cgColor
        
        return newValue
    }()
    
    private let monthLayer: CALayer = {
        let newValue = CALayer()
        
        newValue.backgroundColor = AppColor.borderColor.color.cgColor
        
        return newValue
    }()
    
    private let yearLayer: CALayer = {
        let newValue = CALayer()
        
        newValue.backgroundColor = AppColor.borderColor.color.cgColor
        
        return newValue
    }()
    
    private let monthTextField: UITextField = {
        let newValue = UITextField()
        
        newValue.textColor = AppColor.borderColor.color
        newValue.font = .appFont(.regular, size: 14.0)
        newValue.tintColor = UIColor.clear
        newValue.isUserInteractionEnabled = false
        
        return newValue
    }()
    
    private let yearTextField: UITextField = {
        let newValue = UITextField()
        
        newValue.textColor = AppColor.borderColor.color
        newValue.font = .appFont(.regular, size: 14.0)
        newValue.tintColor = UIColor.clear
        newValue.isUserInteractionEnabled = false

        return newValue
    }()
    
    
    private let monthSlashLabel : UILabel = {
        let newValue = UILabel()
        newValue.text = "/  "
        newValue.textColor = AppColor.borderColor.color
        newValue.font = .appFont(.regular, size: 14.0)
        newValue.tintColor = UIColor.clear
        return newValue
    }()
    
    private let yearSlashLabel : UILabel = {
        let newValue = UILabel()
        newValue.text = "/  "
        newValue.textColor = AppColor.borderColor.color
        newValue.font = .appFont(.regular, size: 14.0)
        newValue.tintColor = UIColor.clear
        return newValue
    }()
    
    private let fourDigitsUnderlineWidth: CGFloat = 60
    private let twoDigitsUnderlineWidth: CGFloat = 22
    private let underlineOffset: CGFloat = 2
    
    private lazy var dateFormatter: DateFormatter = {
        let newValue = DateFormatter()
        
        newValue.dateFormat = "dd / MM / yyyy"

        return newValue
    }()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        dayLayer.backgroundColor = AppColor.itemSeperator.color.cgColor
        monthLayer.backgroundColor = AppColor.itemSeperator.color.cgColor
        yearLayer.backgroundColor = AppColor.itemSeperator.color.cgColor
    }
    
    override var editableText: String? {
        get {
            return String(format: "%@ %@ %@",
                          textField.text ?? "",
                          monthTextField.text ?? "",
                          yearTextField.text ?? "")
        }
        
        set {
            guard let newValue = newValue else {
                return
            }
            
            let numbers = newValue.components(separatedBy: " ")
            if numbers.count == 5 {
                textField.text = numbers[0]
                monthTextField.text = numbers[2]
                yearTextField.text = numbers[4]
            } else if numbers.count == 3 {
                textField.text = numbers[0]
                monthTextField.text = numbers[1]
                yearTextField.text = numbers[2]
            }
        }
    }
    
    private let textFieldColor = AppColor.blackColor.color
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        
        datePicker.addTarget(self, action: #selector(dateDidChanged), for: .valueChanged)
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.isOpaque = true

        if let minDate = dateFormatter.date(from: "01 / 01 / 1900") {
            datePicker.minimumDate = minDate
        }
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        return datePicker
    }()
    
    
    //MARK: -
    
    override var isEditState: Bool {
        willSet {
            textField.isUserInteractionEnabled = newValue
            monthTextField.isUserInteractionEnabled = newValue
            yearTextField.isUserInteractionEnabled = newValue
            
            textField.textColor = newValue ? textFieldColor : ColorConstants.textDisabled
            monthTextField.textColor = newValue ? textFieldColor : ColorConstants.textDisabled
            yearTextField.textColor = newValue ? textFieldColor : ColorConstants.textDisabled
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dayLayer.frame = CGRect(x: 0,
                                y: 0,
                                width: twoDigitsUnderlineWidth,
                                height: underlineHeight)
        
        monthLayer.frame = CGRect(x: dayLayer.frame.maxX + underlineOffset,
                                  y: 0,
                                  width: twoDigitsUnderlineWidth,
                                  height: underlineHeight)
        
        yearLayer.frame = CGRect(x: monthLayer.frame.maxX + underlineOffset,
                                 y: 0,
                                 width: fourDigitsUnderlineWidth,
                                 height: underlineHeight)
    }
    
    override func setup() {
        super.setup()
        
        prepareTextFields()
        
        underlineLayer.backgroundColor = UIColor.clear.cgColor

        underlineLayer.addSublayer(dayLayer)
        underlineLayer.addSublayer(monthLayer)
        underlineLayer.addSublayer(yearLayer)
        
        textFieldStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        textFieldStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
        textFieldStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        
        let twoDigitsTextFieldWidth = twoDigitsUnderlineWidth + underlineOffset
        
        /// day
        textField.widthAnchor.constraint(equalToConstant: twoDigitsTextFieldWidth).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        /// month
        textFieldStackView.addArrangedSubview(monthSlashLabel)
        textFieldStackView.addArrangedSubview(monthTextField)
        monthTextField.translatesAutoresizingMaskIntoConstraints = false
        monthTextField.widthAnchor.constraint(equalToConstant: twoDigitsTextFieldWidth).isActive = true
        monthTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        /// year
        textFieldStackView.addArrangedSubview(yearSlashLabel)
        textFieldStackView.addArrangedSubview(yearTextField)
        yearTextField.translatesAutoresizingMaskIntoConstraints = false
        yearTextField.widthAnchor.constraint(equalToConstant: fourDigitsUnderlineWidth).isActive = true
        yearTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true

        ///need to fill stackView
        textFieldStackView.addArrangedSubview(UIView())
    }
    
    override func configure(with text: String?, delegate: UITextFieldDelegate) {
        editableText = text
        textField.delegate = delegate
        monthTextField.delegate = delegate
        yearTextField.delegate = delegate
        
        if let dateString = text, let date = dateFormatter.date(from: dateString) {
            datePicker.setDate(date, animated: false)
        }
    }
    
    @objc private func dateDidChanged(_ datePicker: UIDatePicker) {
        editableText = dateFormatter.string(from: datePicker.date)
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder() ||
            monthTextField.resignFirstResponder() ||
            yearTextField.resignFirstResponder()
    }
    
    @objc private func hideKeyboard() {
        resignFirstResponder()
    }
    
    private func prepareTextFields() {
        let toolbar = UIToolbar()
        toolbar.isOpaque = true
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        
        toolbar.frame = CGRect(x: 0,
                               y: 0,
                               width: self.bounds.width,
                               height: 50)
        toolbar.sizeToFit()
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                   target: nil,
                                   action: nil)
        
        ///for now it's last editable field
        let done = UIBarButtonItem(barButtonSystemItem: .done,
                                   target: self,
                                   action: #selector(hideKeyboard))
        done.tintColor = UIColor.lrTealish
        
        toolbar.setItems([flex, done], animated: false)
        
        textField.tintColor = UIColor.clear
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
        textField.placeholder = TextConstants.userProfileDayPlaceholder

        monthTextField.tintColor = UIColor.clear
        monthTextField.inputView = datePicker
        monthTextField.inputAccessoryView = toolbar
        monthTextField.placeholder = TextConstants.userProfileMonthPlaceholder

        yearTextField.tintColor = UIColor.clear
        yearTextField.inputView = datePicker
        yearTextField.inputAccessoryView = toolbar
        yearTextField.placeholder = TextConstants.userProfileYearPlaceholder
    }
}
