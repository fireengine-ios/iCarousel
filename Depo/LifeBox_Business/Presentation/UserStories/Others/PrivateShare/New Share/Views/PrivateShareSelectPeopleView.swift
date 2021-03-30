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
    func addShareContact(_ contact: PrivateShareContact, fromSuggestions: Bool)
    func onUserRoleTapped(contact: PrivateShareContact, sender: Any, completion: @escaping ValueHandler<PrivateShareUserRole>)
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
            newValue.tintColor = ColorConstants.Text.textFieldPlaceholder
            newValue.textColor = ColorConstants.Text.textFieldText
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
            UIView.performWithoutAnimation {
                self.userRoleButton.setTitle(role.title, for: .normal)
                self.userRoleButton.layoutIfNeeded()
            }
            
        }
    }
    
    var dropdownListAnchors: (top: NSLayoutYAxisAnchor, leading: NSLayoutXAxisAnchor, trailing: NSLayoutXAxisAnchor) {
        return (textField.bottomAnchor, textField.leadingAnchor, textField.trailingAnchor)
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
        
        //add contact to shared with section
        if !info.identifier.isEmpty {
            addContact(fromSuggestions: false)
        }
        
        setupUserRoleMenu()
    }

    func clear() {
        setContact(info: ContactInfo(name: "", value: "", identifier: "", userType: .knownName))
        role = .viewer
    }
    
    func addManually(isAllowed: Bool) {
        addButton.isEnabled = isAllowed
    }
    
    //MARK: - Private methods
    
    @IBAction private func onAddTapped(_ sender: UIButton) {
        addContact(fromSuggestions: true)
    }
    
    @objc private func onUserRoleTapped(_ sender: UIButton) {
        let shareContact = PrivateShareContact(displayName: displayName, username: textField.text ?? "", type: type, role: role, identifier: identifier)
        delegate?.onUserRoleTapped(contact: shareContact, sender: self, completion: { [weak self] newRole in
            self?.role = newRole
        })
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        displayName = ""
        addManually(isAllowed: false)
        delegate?.searchTextDidChange(text: textField.text ?? "")
    }
    
    private func addContact(fromSuggestions: Bool) {
        let shareContact = PrivateShareContact(displayName: displayName, username: textField.text ?? "", type: type, role: role, identifier: identifier)
        addButton.isEnabled = false
        delegate?.addShareContact(shareContact, fromSuggestions: fromSuggestions)
    }
    
    private func setupUserRoleMenu() {
        if #available(iOS 14, *) {
            let completion: ValueHandler<PrivateShareUserRole> = { [weak self] updatedRole in
                if updatedRole != self?.role {
                    self?.role = updatedRole
                    self?.userRoleButton.setTitle(updatedRole.title, for: .normal)
                    self?.setupUserRoleMenu()
                }
            }
            
            let roles: [PrivateShareUserRole] = [.viewer, .editor]
            let menu = MenuItemsFabric.privateShareUserRoleMenu(roles: roles, currentRole: role, completion: completion)
            userRoleButton.showsMenuAsPrimaryAction = true
            userRoleButton.menu = menu
            
        } else {
            userRoleButton.addTarget(self, action: #selector(onUserRoleTapped), for: .touchUpInside)
        }
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
    
}
