//
//  BackUpContactsCard.swift
//  Depo
//
//  Created by Andrei Novikau on 5/26/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class BackUpContactsCard: ContactSyncBaseCardView, NibInit {
        
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
