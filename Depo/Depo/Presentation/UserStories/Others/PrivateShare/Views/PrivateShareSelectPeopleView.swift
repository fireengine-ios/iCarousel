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
        }
    }
    
    @IBOutlet private weak var addButton: UIButton! {
        willSet {
            newValue.isEnabled = false
        }
    }
    
    @IBOutlet private weak var userRoleButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.privateShareStartPageEditorButton, for: .normal)
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
    private var role = PrivateShareUserRole.editor {
        didSet {
            userRoleButton.setTitle(role.title, for: .normal)
        }
    }
    
    //MARK: - Public methods
    
    func setContact(displayName: String, username: String) {
        self.displayName = displayName
        textField.text = username
        validate(text: username)
    }
    
    //MARK: - Private methods
    
    @IBAction private func onAddTapped(_ sender: UIButton) {
        let shareContact = PrivateShareContact(displayName: displayName, username: textField.text ?? "", role: role)
        delegate?.addShareContact(shareContact)
        setContact(displayName: "", username: "")
    }
    
    @IBAction private func onUserRoleTapped(_ sender: UIButton) {
        let shareContact = PrivateShareContact(displayName: displayName, username: textField.text ?? "", role: role)
        delegate?.onUserRoleTapped(contact: shareContact, sender: self)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        validate(text: textField.text ?? "")
    }
    
    private func validate(text: String) {
        let isValid = true //TODO: need implement logic
        addButton.isEnabled = isValid
        userRoleButton.isHidden = !isValid
    }
}

//MARK: - UITextFieldDelegate

extension PrivateShareSelectPeopleView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.startEditing(text: textField.text ?? "")
    }
}

//MARK: - PrivateShareUserRoleViewControllerDelegate

extension PrivateShareSelectPeopleView: PrivateShareUserRoleViewControllerDelegate {
    
    func contactRoleDidChange(_ contact: PrivateShareContact) {
        role = contact.role
    }
}
