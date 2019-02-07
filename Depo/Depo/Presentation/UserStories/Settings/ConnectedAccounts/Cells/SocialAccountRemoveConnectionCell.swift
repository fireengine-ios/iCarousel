//
//  SocialAccountRemoveConnectionCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 07/02/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol SocialRemoveConnectionCellDelegate: class {
    
}

protocol SocialRemoveConnectionCell: class {
    var delegate: SocialRemoveConnectionCellDelegate? { get set }
}


class SocialAccountRemoveConnectionCell: UITableViewCell, SocialRemoveConnectionCell {
    
    weak var delegate: SocialRemoveConnectionCellDelegate?
    
    @IBOutlet private weak var connectedAs: UILabel! {
        didSet {
            connectedAs.font = UIFont.TurkcellSaturaMedFont(size: 16.0)
            connectedAs.text = " "
        }
    }
    
    @IBOutlet private weak var removeConnectionButton: UIButton! {
        didSet {
            removeConnectionButton.contentEdgeInsets = UIEdgeInsets.make(topBottom: 8.0, rightLeft: 16.0)
            removeConnectionButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 20.0)
            removeConnectionButton.layer.borderColor = removeConnectionButton.currentTitleColor.cgColor
            removeConnectionButton.layer.borderWidth = 2.0
            removeConnectionButton.layer.cornerRadius = removeConnectionButton.bounds.height * 0.25
        }
    }
    
    
    @IBAction func removeConnection(_ sender: Any) {
        let attributedText = NSMutableAttributedString(string: TextConstants.instagramRemoveConnectionWarningMessage, attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        if let connectedAsText = connectedAs.attributedText {
            attributedText.append(connectedAsText)
        }
        let warningPopup = PopUpController.with(title: TextConstants.instagramRemoveConnectionWarning,
                                                attributedMessage: attributedText,
                                                image: .none,
                                                firstButtonTitle: TextConstants.cancel, secondButtonTitle: TextConstants.actionSheetRemove,
                                                firstAction: { popup in
                                                    popup.close()
        }, secondAction: { [weak self] popup in
            popup.close()
//            self?.presenter.disconnectAccount()
        })
        
        UIApplication.topController()?.present(warningPopup, animated: true, completion: nil)
    }
}

