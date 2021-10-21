//
//  FileDescriptionView.swift
//  Lifebox
//
//  Created by Burak Donat on 15.10.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol FileDescriptionViewDelegate: AnyObject {
    func onEditDescription(newDescription: String)
}

protocol FileDescriptionViewProtocol: UIView {
    static func with(delegate: FileDescriptionViewDelegate?) -> FileDescriptionViewProtocol
    func hideKeyboard()
    func showValidateDescriptionSuccess()

    var isEditing: Bool { get set }
    var isEditable: Bool { get set }
    var fileDescription: String? { get set }
}

final class FileDescriptionView: UIView, NibInit {

    //MARK: - Properties
    private weak var delegate: FileDescriptionViewDelegate?
    private var oldDescription: String?

    var isEditing: Bool = false {
        didSet {
            editDescriptionButton.isHidden = isEditing
            saveEditingButton.isHidden = !isEditing
            cancelEditingButton.isHidden = !isEditing
        }
    }

    var isEditable: Bool = false {
        didSet {
            isEditing = false
            changeEditButtonsVisibility(isHidden: !isEditable)
        }
    }

    var fileDescription: String? {
        get { fileDescriptionTextView.text }
        set { set(description: newValue) }
    }

    //MARK: - IBOutlets
    @IBOutlet private weak var editDescriptionButton: UIButton!
    @IBOutlet private weak var cancelEditingButton: UIButton!
    @IBOutlet private weak var saveEditingButton: UIButton!

    @IBOutlet weak var fileDescriptionTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.photosVideosFileDescriptionTitle
            newValue.font = .TurkcellSaturaBolFont(size: 14)
            newValue.textColor = AppColor.marineTwoAndTealish.color
        }
    }

    @IBOutlet weak var fileDescriptionTextView: UITextView! {
        willSet {
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.delegate = self
            newValue.textColor = .lrBrownishGrey
            newValue.isUserInteractionEnabled = false
        }
    }

    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }

    //MARK: - Helpers
    private func initialSetup() {
        isEditable = false
    }

    private func set(description: String?) {
        guard let description = description else {
            fileDescriptionTextView.text = nil
            return
        }
        fileDescriptionTextView.text = description
    }

    private func changeEditButtonsVisibility(isHidden: Bool) {
        fileDescriptionTextView.isUserInteractionEnabled = !isHidden
        editDescriptionButton.isHidden = isHidden
    }

    //MARK: - IBActions
    @IBAction private func onSaveDescriptionDidTap() {
        isEditing = false
        fileDescriptionTextView.isUserInteractionEnabled = false
        guard let text = fileDescriptionTextView.text?.nonEmptyString else { return }
        delegate?.onEditDescription(newDescription: text)
        oldDescription = nil
    }

    @IBAction private func onEditDescriptionDidTap() {
        isEditing = true
        fileDescriptionTextView.isUserInteractionEnabled = true
        fileDescriptionTextView.becomeFirstResponder()
        oldDescription = fileDescriptionTextView.text
    }

    @IBAction private func onCancelEditingDidTap() {
        isEditing = false
        fileDescriptionTextView.isUserInteractionEnabled = false
        fileDescriptionTextView.text = oldDescription
    }
}

extension FileDescriptionView: FileDescriptionViewProtocol {
    static func with(delegate: FileDescriptionViewDelegate?) -> FileDescriptionViewProtocol {
        let view = FileDescriptionView.initFromNib()
        view.delegate = delegate
        return view
    }

    func hideKeyboard() {
        isEditing = false
        fileDescriptionTextView.isUserInteractionEnabled = false

        if let description = oldDescription, !description.isEmpty {
            fileDescriptionTextView.text = oldDescription
            oldDescription = nil
        }

        showValidateDescriptionSuccess()
        changeEditButtonsVisibility(isHidden: !isEditable)
    }

    func showValidateDescriptionSuccess() {
        fileDescriptionTextView.resignFirstResponder()
        guard let text = fileDescriptionTextView.text?.nonEmptyString else { return }
        fileDescriptionTextView.text = text
    }
}

extension FileDescriptionView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if range.length >= 250 && text.isEmpty {
            return false
        }

        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if newText.count > 250 {
            textView.text = String(newText.prefix(250))
        }
        return newText.count <= 250
    }

    func textViewDidChange(_ textView: UITextView) {
        IQKeyboardManager.shared.reloadLayoutIfNeeded()
    }
}
