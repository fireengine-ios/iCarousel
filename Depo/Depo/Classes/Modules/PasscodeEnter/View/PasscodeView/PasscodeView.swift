//
//  PasscodeView.swift
//  Passcode
//
//  Created by Bondar Yaroslav on 10/2/17.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit

final class PasscodeView: UIView, FromNib {
    
    @IBOutlet weak var passcodeInputView: PasscodeInputView!
    @IBOutlet private weak var passcodeOutputLabel: UILabel!
    
    let touchIdManager = TouchIdManager()
    var type = PasscodeInputViewType.validate
    
    func set(type: PasscodeInputViewType) {
        self.type = type
        switch type {
        case .new:
            passcodeOutputLabel.text = "Set password"
        case .validate:
            passcodeOutputLabel.text = "Enter the password"
        case .validateNew:
            break /// nothing here
        case .setNew:
            passcodeOutputLabel.text = "Enter old password"
        case .validateWithBiometrics:
            passcodeOutputLabel.text = "Enter the password"
            touchIdManager.authenticate { [weak self] success in
                if success {
                    self?.delegate?.finishValidate()
                }
            }
        }
    }
    
    weak var delegate: PasscodeViewDelegate?
    
    private var passcode: Passcode = ""
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        setupFromNib()
        passcodeInputView.delegate = self
        passcodeOutputLabel.text = "Enter new password"
    }
}

extension PasscodeView: PasscodeInputViewDelegate {
    func finish(with passcode: Passcode) {
        switch type {
        case .new:
            self.passcode = passcode
            passcodeInputView.clearPasscode()
            passcodeOutputLabel.text = "Please repeate your new lifebox passcode "
            type = .validateNew
            
        case .validateNew:
            if self.passcode == passcode {
                passcodeInputView.clearPasscode()
                passcodeOutputLabel.text = "Thank you!"
                delegate?.finishSetNew(passcode: passcode)
                /// FINISH
                
            } else {
                passcodeInputView.animateError()
                passcodeOutputLabel.text = "Wrong password. Set password again"
                type = .new
            }
            
        case .validate, .validateWithBiometrics:
            if delegate?.check(passcode: passcode) ?? false {
                passcodeInputView.clearPasscode()
                passcodeOutputLabel.text = "Thank you!"
                delegate?.finishValidate()
                /// FINISH
            } else {
                passcodeInputView.animateError()
                passcodeOutputLabel.text = "Wrong password"
            }
        case .setNew:
            if delegate?.check(passcode: passcode) ?? false {
                passcodeInputView.clearPasscode()
                passcodeOutputLabel.text = "Enter new Password"
                type = .new
                
            } else {
                passcodeInputView.animateError()
                passcodeOutputLabel.text = "Wrong password"
            }
        }
    }
    
    func finishErrorAnimation() {
        passcodeInputView.clearPasscode()
    }
}

protocol PasscodeViewDelegate: class {
    func check(passcode: Passcode) -> Bool
    func finishSetNew(passcode: Passcode)
    func finishValidate()
}
extension PasscodeViewDelegate {
    func finishValidate() {}
    func finishSetNew(passcode: Passcode) {}
}
