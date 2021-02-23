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
            newValue.text = TextConstants.PrivateShare.box_name
            newValue.font = .GTAmericaStandardMediumFont(size: 16)
            newValue.textColor = ColorConstants.Text.labelTitle
        }
    }
    
    @IBOutlet private weak var textField: UITextField! {
        willSet {
            newValue.borderStyle = .roundedRect
            newValue.placeholder = TextConstants.PrivateShare.box_inside
            newValue.font = .GTAmericaStandardRegularFont(size: 12)
            newValue.tintColor = ColorConstants.Text.textFieldTint
            newValue.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            newValue.delegate = self
            newValue.returnKeyType = .done
        }
    }
    
    @IBOutlet private weak var addButton: UIButton! {
        willSet {
            newValue.setImage(UIImage(named: "add-inactive"), for: .disabled)
            newValue.setImage(UIImage(named: "add-active"), for: .normal)
            newValue.isEnabled = false
        }
    }
    
    @IBOutlet private weak var userRoleButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.PrivateShare.role_viewer, for: .normal)
            newValue.setTitleColor(ColorConstants.Text.labelTitle, for: .normal)
            newValue.setImage(UIImage(named: "arrowDown"), for: .normal)
            newValue.titleLabel?.font = .GTAmericaStandardMediumFont(size: 14)
            newValue.tintColor = ColorConstants.Text.labelTitle
            newValue.forceImageToRightSide()
            newValue.imageEdgeInsets.left = -8
            newValue.isHidden = false
        }
    }
    
    private weak var delegate: PrivateShareSelectPeopleViewDelegate?
    
    private var displayName = ""
    private var identifier = ""
    private var type: PrivateShareSubjectType = .knownName
    
    private var role = PrivateShareUserRole.viewer {
        didSet {
            userRoleButton.setTitle(role.title, for: .normal)
        }
    }
    
    //MARK: - Public methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textField.layoutIfNeeded()
        textField.placeholderLabel?.adjustsFontSizeToFitWidth = true
        textField.placeholderLabel?.minimumScaleFactor = 0.5
    }
    
    func setContact(info: ContactInfo) {
        displayName = info.name
        textField.text = info.value
        identifier = info.identifier
        type = info.userType
//        changeButtonEnabledIfNeeded(text: info.value)
        
        //add contact to shared with section
        if !info.value.isEmpty {
            onAddTapped(addButton)
        }
    }
    
    func clear() {
        setContact(info: ContactInfo(name: "", value: "", identifier: "", userType: .knownName))
        role = .viewer
    }
    
    //MARK: - Private methods
    
    @IBAction private func onAddTapped(_ sender: UIButton) {
        let shareContact = PrivateShareContact(displayName: displayName, username: textField.text ?? "", type: type, role: role, identifier: identifier)
        delegate?.addShareContact(shareContact)
    }
    
    @IBAction private func onUserRoleTapped(_ sender: UIButton) {
        let shareContact = PrivateShareContact(displayName: displayName, username: textField.text ?? "", type: type, role: role, identifier: identifier)
        delegate?.onUserRoleTapped(contact: shareContact, sender: self)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        displayName = ""
        delegate?.searchTextDidChange(text: textField.text ?? "")
//        changeButtonEnabledIfNeeded(text: textField.text ?? "")
    }
    
//    private func changeButtonEnabledIfNeeded(text: String) {
//        let isValid = text.count > 0
//        //Can asked to disable it for now
////        addButton.isEnabled = isValid
//        userRoleButton.isHidden = !isValid
//    }
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
    
}

//MARK: - PrivateShareUserRoleViewControllerDelegate

extension PrivateShareSelectPeopleView: PrivateShareUserRoleViewControllerDelegate {
    
    func contactRoleDidChange(_ contact: PrivateShareContact) {
        role = contact.role
    }
}
