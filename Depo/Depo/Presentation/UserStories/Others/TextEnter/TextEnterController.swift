//
//  TextEnterController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/9/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

typealias TextEnterHandler = (_ text: String, _ vc: TextEnterController) -> Void

final class TextEnterController: ViewController {
    
    // MARK: - Static
    
    static func with(title: String, textPlaceholder: String? = nil, buttonTitle: String, buttonAction: TextEnterHandler? = nil) -> TextEnterController {
        
        let vc = TextEnterController(nibName: "TextEnterController", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        
        vc.alertTitle = title
        vc.doneButtonTitle = buttonTitle
        vc.textPlaceholder = textPlaceholder
        
        if let action = buttonAction {
            vc.doneAction = action
        }
        
        return vc
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var shadowView: UIView! {
        didSet {
            shadowView.layer.cornerRadius = 5
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowRadius = 10
            shadowView.layer.shadowOpacity = 0.5
            shadowView.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var containerView: UIView! {
        didSet {
            containerView.layer.masksToBounds = true
            containerView.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = ColorConstants.darcBlueColor
            titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 20)
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel! {
        didSet {
            messageLabel.textColor = ColorConstants.lightText
            messageLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        }
    }
    
    @IBOutlet private weak var doneButton: UIButton! {
        didSet {
            doneButton.isExclusiveTouch = true
            doneButton.isEnabled = false
            
            doneButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            
            doneButton.setTitleColor(ColorConstants.blueColor, for: .normal)
            doneButton.setTitleColor(ColorConstants.blueColor.darker(), for: .highlighted)
            
            doneButton.setBackgroundColor(ColorConstants.blueColor, for: .highlighted)
            
            doneButton.layer.borderColor = ColorConstants.blueColor.cgColor
            doneButton.layer.borderWidth = 1
        }
    }
    
    @IBOutlet private weak var enterTextField: UITextField! {
        didSet {
            enterTextField.font = UIFont.TurkcellSaturaRegFont(size: 20)
        }
    }
    
    // MARK: - Setup
    
    private var alertTitle = ""
    private var doneButtonTitle = ""
    private var textPlaceholder: String?
    
    private lazy var doneAction: TextEnterHandler = { [weak self] _, _ in
        self?.close()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = alertTitle
        doneButton.setTitle(doneButtonTitle, for: .normal)
        enterTextField.placeholder = textPlaceholder
    }
    
    @IBAction func actionDoneButton(_ sender: UIButton) {
        doneAction(enterTextField.text ?? "", self)
    }
    
    func showAlertMessage(with text: String) {
        messageLabel.text = text
    }
    
    func startLoading() {
        doneButton.isEnabled = false
    }
    
    func stopLoading() {
        doneButton.isEnabled = true
    }
    
    // MARK: - Animation
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        enterTextField.becomeFirstResponder()
        open()
    }
    
    private var isShown = false
    private func open() {
        if isShown {
            return
        }
        isShown = true
        shadowView.transform = NumericConstants.scaleTransform
        containerView.transform = NumericConstants.scaleTransform
        view.alpha = 0
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
            self.shadowView.transform = .identity
            self.containerView.transform = .identity
        }
    }
    
    func close(completion: VoidHandler? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.shadowView.transform = NumericConstants.scaleTransform
            self.containerView.transform = NumericConstants.scaleTransform
        }, completion: { _ in
            self.dismiss(animated: false, completion: completion)
        })
    }
    
    private func isAvailableCharacters(in text: String) -> Bool {
        return text.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

extension TextEnterController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard isAvailableCharacters(in: string) else {
            return false
        }
        if textField.text?.isEmpty == true {
            textField.text = "+"
        }
        
        if let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string), newString.isEmpty {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
        
        return true
    }
}
