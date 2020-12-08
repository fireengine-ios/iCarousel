//
//  PrivateShareSelectPeopleView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareSelectPeopleViewDelegate: class {
    func startEditing(text: String)
    func searchTextDidChange(text: String)
    func hideKeyboard(text: String)
    func addShareContact(_ contact: PrivateShareContact)
    func onUserRoleTapped(contact: PrivateShareContact, sender: Any)
}

final class PrivateShareSelectPeopleView: UIView, NibInit {

    static func with(delegate: PrivateShareSelectPeopleViewDelegate?) -> PrivateShareSelectPeopleView {
        let view = PrivateShareSelectPeopleView.initFromNib()
        view.delegate = delegate
        return view
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.privateShareStartPagePeopleSelectionTitle
            newValue.font = .TurkcellSaturaBolFont(size: 16)
            newValue.textColor = ColorConstants.marineTwo
        }
    }
    
    @IBOutlet private weak var textField: UITextField! {
        willSet {
            newValue.borderStyle = .none
            newValue.placeholder = TextConstants.privateShareStartPageEnterUserPlaceholder
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            newValue.delegate = self
            newValue.returnKeyType = .done
        }
    }
    
    @IBOutlet private weak var addButton: UIButton! {
        willSet {
            newValue.isEnabled = false
        }
    }
    
    @IBOutlet private weak var userRoleButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.privateShareStartPageViewerButton, for: .normal)
            newValue.setTitleColor(.lrTealishFour, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 18)
            newValue.tintColor = .lrTealishFour
            newValue.forceImageToRightSide()
            newValue.imageEdgeInsets.left = -10
            newValue.isHidden = true
        }
    }
    
    private weak var delegate: PrivateShareSelectPeopleViewDelegate?
    private var displayName = ""
    private var role = PrivateShareUserRole.viewer {
        didSet {
            userRoleButton.setTitle(role.title, for: .normal)
        }
    }
    
    //MARK: - Public methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.layoutIfNeeded()
        textField.placeholderLabel?.adjustsFontSizeToFitWidth = true
        textField.placeholderLabel?.minimumScaleFactor = 0.5
    }
    
    func setContact(info: ContactInfo) {
        displayName = info.name
        textField.text = info.value
        changeButtonEnabledIfNeeded(text: info.value)
        
        //add contact to shared with section
        if !info.value.isEmpty {
            onAddTapped(addButton)
        }
    }
    
    func clear() {
        setContact(info: ContactInfo(name: "", value: ""))
        role = .viewer
    }
    
    //MARK: - Private methods
    
    @IBAction private func onAddTapped(_ sender: UIButton) {
        let shareContact = PrivateShareContact(displayName: displayName, username: textField.text ?? "", role: role)
        delegate?.addShareContact(shareContact)
    }
    
    @IBAction private func onUserRoleTapped(_ sender: UIButton) {
        let shareContact = PrivateShareContact(displayName: displayName, username: textField.text ?? "", role: role)
        delegate?.onUserRoleTapped(contact: shareContact, sender: self)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        displayName = ""
        delegate?.searchTextDidChange(text: textField.text ?? "")
        changeButtonEnabledIfNeeded(text: textField.text ?? "")
    }
    
    private func changeButtonEnabledIfNeeded(text: String) {
        let isValid = text.count > 0
        addButton.isEnabled = isValid
        userRoleButton.isHidden = !isValid
    }
}

//MARK: - UITextFieldDelegate

extension PrivateShareSelectPeopleView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.startEditing(text: textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.hideKeyboard(text: textField.text ?? "")
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text, text.count == 0,
           (string == "+" || string == "0" || string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil)
        {
            let code = CoreTelephonyService().getCountryCode()
            let countryCode = code.isEmpty ? "+" : code
            let isReplacableString = string == "+" || string == "0"
            textField.text = countryCode
            return !isReplacableString
        }
        
        return true
    }
}

//MARK: - PrivateShareUserRoleViewControllerDelegate

extension PrivateShareSelectPeopleView: PrivateShareUserRoleViewControllerDelegate {
    
    func contactRoleDidChange(_ contact: PrivateShareContact) {
        role = contact.role
    }
}
