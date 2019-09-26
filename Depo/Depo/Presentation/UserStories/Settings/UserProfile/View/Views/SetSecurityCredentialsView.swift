//
//  SetSecurityCredentialsView.swift
//  Depo
//
//  Created by Maxim Soldatov on 9/20/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol SetSecurityCredentialsViewDelegate: class {
    func setNewQuestionTapped()
    func setNewPasswordTapped()
}

enum CredentialType {
    case password
    case secretQuestion
}

final class SetSecurityCredentialsView: UIView, NibInit {
    
    weak var delegate: SetSecurityCredentialsViewDelegate?
    private var type: CredentialType?
        
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = UIColor.lrTealish
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaFont(size: 18)
        }
    }
    
    @IBOutlet private weak var setNewButton: UIButton!
    
    @IBOutlet private weak var bottomDemarcationView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.lightGrayColor
        }
    }
    
    func setupView(with type: CredentialType, title: String, description: String, buttonTitle: String) {
        
        DispatchQueue.toMain {
            self.type = type
            self.titleLabel.text = title
            self.descriptionLabel.text = description
            
            self.descriptionLabel.textColor = type == .password ? UIColor.black : ColorConstants.lightText.withAlphaComponent(0.5)
            
            let attributedString = NSAttributedString(string: buttonTitle,
                                                      attributes: [
                                                        .font : UIFont.TurkcellSaturaMedFont(size: 15),
                                                        .foregroundColor : UIColor.lrTealish,
                                                        .underlineStyle : NSUnderlineStyle.styleSingle.rawValue ])
            self.setNewButton.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
    func setupDescriptionLabel(question: String) {
        DispatchQueue.toMain {
            self.descriptionLabel.text = question
            self.descriptionLabel.textColor = UIColor.black
        }
    }
    
    @IBAction private func setButtonTapped(_ sender: UIButton) {
        
        guard let type = type else {
            assertionFailure()
            return
        }
        
        switch type {
        case .password:
            delegate?.setNewPasswordTapped()
        case .secretQuestion:
            delegate?.setNewQuestionTapped()
        }
    }
    
}
