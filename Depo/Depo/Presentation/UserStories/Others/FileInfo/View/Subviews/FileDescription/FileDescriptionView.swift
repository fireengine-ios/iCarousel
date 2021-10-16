//
//  FileDescriptionView.swift
//  Lifebox
//
//  Created by Burak Donat on 15.10.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol FileDescriptionViewDelegate: AnyObject {
    func onEditDescription(newDescription: String)
}

protocol FileDescriptionViewProtocol: UIView {
    static func with(delegate: FileDescriptionViewDelegate?) -> FileDescriptionViewProtocol
    func hideKeyboard()

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
            newValue.text = "File Description"
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

    private func changeEditButtonsVisibility(isHidden: Bool) {
        fileDescriptionTextView.isUserInteractionEnabled = !isHidden
        editDescriptionButton.isHidden = isHidden
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

        changeEditButtonsVisibility(isHidden: !isEditable)
    }
}

extension FileDescriptionView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 255
    }
}
