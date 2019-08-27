//
//  SpotifyOverwritePopup.swift
//  Depo
//
//  Created by Andrei Novikau on 7/31/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SpotifyOverwritePopup: BlurBackgroundPopup {
    
    static func with(action: @escaping VoidHandler, dismissAction: VoidHandler?) -> UIViewController {
        let controller = initFromNib()
        controller.setup(action: action, dismissAction: dismissAction)
        return controller
    }
    
    override func setupTitleLabel() {
        let message = TextConstants.Spotify.OverwritePopup.message
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributedString = NSMutableAttributedString(string: message,
                                                         attributes: [.font: UIFont.TurkcellSaturaFont(size: 18),
                                                                      .foregroundColor: UIColor.black,
                                                                      .paragraphStyle: paragraphStyle])
        
        let range = (message as NSString).range(of: TextConstants.Spotify.OverwritePopup.messageBoldFontText)
        if range.location != NSNotFound {
            attributedString.setAttributes([.font: UIFont.TurkcellSaturaBolFont(size: 18)], range: range)
        }
        
        titleLabel.attributedText = attributedString
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
    }
    
    override func setupDismissButton() {
        dismissButton.setTitle(TextConstants.Spotify.OverwritePopup.cancelButton, for: .normal)
        dismissButton.setTitleColor(ColorConstants.blueColor, for: .normal)
        dismissButton.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
        dismissButton.layer.masksToBounds = true
        dismissButton.layer.cornerRadius = dismissButton.bounds.height * 0.5
        dismissButton.layer.borderColor = ColorConstants.blueColor.cgColor
        dismissButton.layer.borderWidth = 1
    }
    
    override func setupActionButton() {
        actionButton.setTitle(TextConstants.Spotify.OverwritePopup.importButton, for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.backgroundColor = ColorConstants.blueColor
        actionButton.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
        actionButton.layer.masksToBounds = true
        actionButton.layer.cornerRadius = actionButton.bounds.height * 0.5
    }
}
