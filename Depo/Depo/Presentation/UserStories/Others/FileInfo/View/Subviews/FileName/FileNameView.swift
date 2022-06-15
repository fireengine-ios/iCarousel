//
//  FileNameView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/11/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol FileNameViewDelegate: AnyObject {
    func onRename(newName: String)
}

protocol FileNameViewProtocol: UIView {
    static func with(delegate: FileNameViewDelegate?) -> FileNameViewProtocol
    func hideKeyboard()
    func showValidateNameSuccess()
    
    var title: String? { get set }
    var name: String? { get set }
    var isEditable: Bool { get set }
    var isEditing: Bool { get set }
}

final class FileNameView: UIView, NibInit, FileNameViewProtocol {
    
    static func with(delegate: FileNameViewDelegate?) -> FileNameViewProtocol {
        let view = FileNameView.initFromNib()
        view.delegate = delegate
        return view
    }

    @IBOutlet private weak var fileNameTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoFileNameTitle
            newValue.font = .appFont(.regular, size: 14)
            newValue.textColor = AppColor.filesLabel.color
        }
    }
    
    @IBOutlet private weak var fileNameTextField: UITextField! {
        willSet {
            newValue.font = .appFont(.light, size: 14)
            newValue.textColor = AppColor.filesLabel.color
            newValue.delegate = self
            newValue.isUserInteractionEnabled = false
        }
    }
    
    @IBOutlet private weak var editNameButton: UIButton!
    @IBOutlet private weak var saveNameButton: UIButton!
    @IBOutlet private weak var cancelRenamingButton: UIButton!
    
    private weak var delegate: FileNameViewDelegate?
    
    private var fileExtension: String?
    private var oldName: String?
    
    //MARK: - FileNameViewProtocol
    
    var title: String? {
        get { fileNameTitleLabel.text }
        set { fileNameTitleLabel.text = newValue }
    }
    
    var name: String? {
        get { fileNameTextField.text }
        set { set(name: newValue) }
    }
    
    var isEditable: Bool = false {
        didSet {
            isEditing = false
            changeEditButtonsVisibility(isHidden: !isEditable)
        }
    }
    
    var isEditing: Bool = false {
        didSet {
            editNameButton.isHidden = isEditing
            saveNameButton.isHidden = !isEditing
            cancelRenamingButton.isHidden = !isEditing
        }
    }
    
    func hideKeyboard() {
        isEditing = false
        fileNameTextField.isUserInteractionEnabled = false
        
        if let name = oldName, !name.isEmpty {
            fileNameTextField.text = oldName
            oldName = nil
        }
        
        showValidateNameSuccess()
        changeEditButtonsVisibility(isHidden: !isEditable)
    }
    
    func showValidateNameSuccess() {
        fileNameTextField.resignFirstResponder()
        guard
            let text = fileNameTextField.text?.nonEmptyString,
            let fileExtension = fileExtension?.nonEmptyString
        else {
            return
        }
        fileNameTextField.text = text.makeFileName(with: fileExtension)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialSetup()
    }
    
    //MARK: - Private
    
    private func initialSetup() {
        isEditable = false
    }
    
    private func set(name: String?) {
        guard let name = name else {
            fileNameTextField.text = nil
            return
        }
        
        fileExtension = (name as NSString).pathExtension
        if fileNameTextField.isFirstResponder {
            fileNameTextField.text = (name as NSString).deletingPathExtension
        } else {
            fileNameTextField.text = name
        }
    }
    
    private func changeEditButtonsVisibility(isHidden: Bool) {
        fileNameTextField.isEnabled = !isHidden
        editNameButton.isHidden = isHidden
    }
    
    //MARK: - Actions
    
    @IBAction private func onSaveNameDidTap() {
        isEditing = false
        fileNameTextField.isUserInteractionEnabled = false
        guard
            let text = fileNameTextField.text?.nonEmptyString,
            let fileExtension = fileExtension?.nonEmptyString
        else { return }
        delegate?.onRename(newName: text.makeFileName(with: fileExtension))
        oldName = nil
    }
    
    @IBAction private func onEditNameDidTap() {
        isEditing = true
        fileNameTextField.isUserInteractionEnabled = true
        fileNameTextField.becomeFirstResponder()
        oldName = fileNameTextField.text
    }
    
    @IBAction private func onCancelRenamingDidTap() {
        isEditing = false
        fileNameTextField.isUserInteractionEnabled = false
        fileNameTextField.text = oldName
        showValidateNameSuccess()
    }
}

//MARK: - UITextFieldDelegate

extension FileNameView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let text = textField.text {
            delegate?.onRename(newName: text)
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            textField.text = (text as NSString).deletingPathExtension
            if fileExtension == nil {
                fileExtension = (text as NSString).pathExtension
            }
        }
        
        return true
    }
}
