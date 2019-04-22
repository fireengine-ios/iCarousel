//
//  UserProfileDetailView.swift
//  Depo
//
//  Created by Raman Harhun on 4/19/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

enum ProfileFieldType: Int {
    case firstName
    case secondName
    case email
    case gsmNumber
    case birthday
    case password
    
    var description: String {
        switch self {
        case .firstName:
            return TextConstants.userProfileName
        case .secondName:
            return TextConstants.userProfileSurname
        case .email:
            return TextConstants.userProfileEmailSubTitle
        case .gsmNumber:
            return TextConstants.userProfileGSMNumberSubTitle
        case .birthday:
            return TextConstants.userProfileBirthday
        case .password:
            return TextConstants.userProfilePassword
        }
    }
}

final class ProfileFieldView: UIView {
    
    //MARK: IBInspectable
    @IBInspectable var line: Int = 0 {
        didSet {
            if let type = ProfileFieldType(rawValue: line) {
                self.type = type
            }
            
            textField.tag = line
        }
    }
    
    //MARK: Vars (private)
    private let descriptionLabel: UILabel = {
        let newValue = UILabel()
        
        newValue.textColor = UIColor.lrTealish
        newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        
        return newValue
    }()
    
    private let textField: UITextField = {
        let newValue = UITextField()
        
        newValue.textColor = ColorConstants.textGrayColor
        newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
        
        return newValue
    }()
    
    private let alertLabel: UILabel = {
        let newValue = UILabel()
        
        newValue.text = TextConstants.userProfileTurkcellGSMAlert
        newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
        newValue.textColor = ColorConstants.orangeGradient
        newValue.isHidden = true
        
        return newValue
    }()
    
    private let dividerLineView: UIView = {
        let newValue = UIView()
        
        newValue.backgroundColor = ColorConstants.profileGrayColor
        
        return newValue
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(dateDidChanged), for: .valueChanged)
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        
        return datePicker
    }()
    
    //MARK: Vars (Public)
    var type: ProfileFieldType = .firstName
    
    var editableText: String? {
        return textField.text
    }
    
    var isEditState: Bool = false {
        didSet {
            textField.isUserInteractionEnabled = (isEditState && type != .password)
            if type == .gsmNumber, SingletonStorage.shared.isTurkcellUser {
                alertLabel.isHidden = !isEditState
                let textColor = isEditState ? UIColor.black.withAlphaComponent(0.25) : ColorConstants.textGrayColor
                textField.textColor = textColor
                textField.isUserInteractionEnabled = false
            }
        }
    }
    
    override var isFirstResponder: Bool {
        return textField.isFirstResponder
    }
    
    //MARK: init/deinit
    init(line: ProfileFieldType) {
        super.init(frame: .zero)
        
        self.line = line.rawValue
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    //MARK: Utility Methods (private)
    private func setup() {
        setupViews()
        textField.isUserInteractionEnabled = false
        descriptionLabel.text = ProfileFieldType(rawValue: self.line)?.description
        
        guard let type = ProfileFieldType(rawValue: self.line) else {
            let error = CustomErrors.text("Enable to define field type.")
            UIApplication.showErrorAlert(message: error.localizedDescription)
            return
        }
        
        switch type {
        case .birthday:
            textField.inputView = datePicker
            textField.placeholder = TextConstants.userProfileBirthdayPlaceholder
        case .password:
            textField.text = String(repeating: "*", count: 10)
        case .firstName, .secondName, .email, .gsmNumber:
            break
        }
    }
    
    private func setupViews() {
        addSubview(descriptionLabel)
        addSubview(alertLabel)
        addSubview(textField)
        addSubview(dividerLineView)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        addSubview(stackView)
        
        stackView.addArrangedSubview(alertLabel)
        stackView.addArrangedSubview(textField)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: dividerLineView.topAnchor).isActive = true
        
        dividerLineView.translatesAutoresizingMaskIntoConstraints = false
        
        dividerLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        dividerLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        dividerLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        dividerLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    @objc private func dateDidChanged(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM YYYY"
        
        let dateString = dateFormatter.string(from: datePicker.date)
        textField.text = dateString
    }
    
    //MARK: Utility Methods (public)
    func configure(with fillString: String?, delegate: UITextFieldDelegate) {
        textField.text = fillString
        textField.delegate = delegate
    }
    
    func getTextField() -> UITextField {
        return textField
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        if type == .gsmNumber, SingletonStorage.shared.isTurkcellUser {
            return false
        } else {
            return textField.becomeFirstResponder()
        }
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
}
