//
//  PasscodeView2.swift
//  LifeBox-new
//
//  Created by Bondar Yaroslav on 14/11/2017.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit

final class PasscodeViewImp: UIView, FromNib {
    
    @IBOutlet private weak var passcodeInputView: PasscodeInputView!
    @IBOutlet private weak var passcodeOutputLabel: UILabel!
    @IBOutlet weak var passcodeErrorLabel: UILabel!
    
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
    }
    
    lazy var passcodeOutput: PasscodeOutput = {
        let po = PasscodeOutputImp()
        po.passcodeErrorLabel = passcodeErrorLabel
        po.passcodeOutputLabel = passcodeOutputLabel
        return po
    }()
}
extension PasscodeViewImp: PasscodeView {
//    var passcodeOutput: PasscodeOutput {
//        return passcodeOutputLabel
//    }
    var passcodeInput: PasscodeInput {
        return passcodeInputView
    }
}

final class PasscodeOutputImp: PasscodeOutput {
    
    var passcodeOutputLabel: UILabel!
    var passcodeErrorLabel: UILabel!
    
    var text: String? {
        didSet {
            passcodeOutputLabel.text = text
        }
    }
    
    func animateError(with numberOfTries: Int) {
        animateError(with: "\(numberOfTries)")
    }
    
    func animateError(with text: String) {
        passcodeErrorLabel.text = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.passcodeErrorLabel.text = ""
        }
    }
}
