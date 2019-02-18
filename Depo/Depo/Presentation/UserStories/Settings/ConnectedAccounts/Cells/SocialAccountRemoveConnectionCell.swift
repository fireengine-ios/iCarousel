//
//  SocialAccountRemoveConnectionCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 07/02/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol SocialRemoveConnectionCell: class {
    func setup(with section: Section?)
    func set(username: String?)
}


class SocialAccountRemoveConnectionCell: UITableViewCell, SocialRemoveConnectionCell {

    private(set) var section: Section?
    
    @IBOutlet private weak var connectedAs: UILabel! {
        didSet {
            connectedAs.font = UIFont.TurkcellSaturaMedFont(size: 16.0)
            connectedAs.textColor = ColorConstants.connectedAs
            connectedAs.text = TextConstants.youAreConnected
        }
    }
    
    @IBOutlet private weak var removeConnectionButton: RoundedInsetsButton! {
        didSet {
            removeConnectionButton.tintColor = ColorConstants.removeConnection
            removeConnectionButton.layer.borderColor = removeConnectionButton.tintColor.cgColor
            removeConnectionButton.layer.borderWidth = 2.0
            removeConnectionButton.insets = UIEdgeInsets(topBottom: 8.0, rightLeft: 16.0)
            
            removeConnectionButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 20.0)
            removeConnectionButton.setTitle(TextConstants.removeConnection, for: .normal)
        }
    }
    
    func setup(with section: Section?) {
        self.section = section
    }
    
    func set(username: String?) {
        guard let username = username, !username.isEmpty else {
            return
        }
        DispatchQueue.toMain {
            self.connectedAs.text = String(format: TextConstants.instagramConnectedAsFormat, username)
        }
    }
    
    
    @IBAction func removeConnection(_ sender: Any) {
        let localizedTexts = warningTexts()
        
        let attributedText = NSMutableAttributedString(string: localizedTexts.message, attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        if let connectedAsText = connectedAs.attributedText {
            attributedText.append(connectedAsText)
        }
        
        let warningPopup = PopUpController.with(title: localizedTexts.title,
                                                attributedMessage: attributedText,
                                                image: .none,
                                                firstButtonTitle: TextConstants.cancel,
                                                secondButtonTitle: TextConstants.actionSheetRemove,
                                                firstAction: { popup in
                                                    popup.close()
        }, secondAction: { [weak self] popup in
            popup.close()
            guard let `self` = self, let section = self.section else {
                return
            }
            
            section.mediator.disconnect()
        })
        
        UIApplication.topController()?.present(warningPopup, animated: true, completion: nil)
    }
    
    private func warningTexts() -> (title: String, message: String) {
        guard let account = section?.account else {
            return (" ", " ")
        }
        
        switch account {
        case .instagram:
            return (TextConstants.instagramRemoveConnectionWarning,
                    TextConstants.instagramRemoveConnectionWarningMessage)
        case .facebook:
            return (TextConstants.facebookRemoveConnectionWarning,
                    TextConstants.facebookRemoveConnectionWarningMessage)
        case .dropbox:
            return (TextConstants.dropboxRemoveConnectionWarning,
                    TextConstants.dropboxRemoveConnectionWarningMessage)
        }
    }
}

