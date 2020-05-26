//
//  BackUpContactsCard.swift
//  Depo
//
//  Created by Andrei Novikau on 5/26/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class BackUpContactsCard: UIView, NibInit {
    
    @IBOutlet private weak var contentView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 4
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowOpacity = 0.2
            newValue.layer.shadowRadius = 4
            newValue.layer.shadowColor = UIColor.black.cgColor
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.deleteDuplicatesBackUpTitle
            newValue.textColor = ColorConstants.navy
            newValue.font = .TurkcellSaturaDemFont(size: 18)
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.deleteDuplicatesBackUpMessage
            newValue.textColor = .lrBrownishGrey
            newValue.font = .TurkcellSaturaDemFont(size: 14)
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var backupButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.deleteDuplicatesBackUpButton, for: .normal)
            newValue.setTitleColor(.lrTealishTwo, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 14)
        }
    }
    
    var backUpHandler: VoidHandler?
    
    //MARK: - Actions

    @IBAction private func backUpNow(_ sender: UIButton) {
        backUpHandler?()
    }
}
