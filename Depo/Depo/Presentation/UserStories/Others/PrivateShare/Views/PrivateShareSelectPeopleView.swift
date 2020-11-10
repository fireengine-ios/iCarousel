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
    func addShareContact(string: String)
    func onUserRoleTapped()
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
    
    //MARK: - Public methods
    
    func setText(_ text: String) {
        textField.text = text
        changeButtonEnebledIfNeeded(text: text)
    }
    
    //MARK: - Private methods
    
    @IBAction private func onAddTapped(_ sender: UIButton) {
        delegate?.addShareContact(string: textField.text ?? "")
        setText("")
    }
    
    @IBAction private func onUserRoleTapped(_ sender: UIButton) {
        delegate?.onUserRoleTapped()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        delegate?.startEditing(text: textField.text ?? "")
        changeButtonEnebledIfNeeded(text: textField.text ?? "")
    }
    
    private func changeButtonEnebledIfNeeded(text: String) {
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard string != " " else {
            return false
        }
        
        if string == "0" {
            return false
        }
        
        if let text = textField.text, text.count == 0,
           (string == "+" || string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil)
        {
            let code = CoreTelephonyService().getCountryCode()
            let countryCode = code.isEmpty ? "+" : code
            textField.text = countryCode
            return string == "+" ? false : true
        }
        
        return true
    }
    
}
