//
//  SpotifyCancelImportPopup.swift
//  Depo
//
//  Created by Andrei Novikau on 8/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SpotifyCancelImportPopup: BlurBackgroundPopup {

    @IBOutlet private weak var subtitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.Spotify.CancelImportPopup.subtitle
            newValue.lineBreakMode = .byWordWrapping
            newValue.numberOfLines = 0
            newValue.textColor = ColorConstants.charcoalGrey.withAlphaComponent(0.5)
            newValue.font = UIFont.TurkcellSaturaFont(size: 14)
        }
    }
    
    static func with(action: @escaping VoidHandler, dismissAction: VoidHandler?) -> UIViewController {
        let controller = initFromNib()
        controller.setup(action: action, dismissAction: dismissAction)
        return controller
    }
    
    override func setupTitleLabel() {
        let message = TextConstants.Spotify.CancelImportPopup.title
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributedString = NSMutableAttributedString(string: message,
                                                         attributes: [.font: UIFont.TurkcellSaturaFont(size: 18),
                                                                      .foregroundColor: UIColor.black,
                                                                      .paragraphStyle: paragraphStyle])
        
        let range = (message as NSString).range(of: TextConstants.Spotify.CancelImportPopup.titleBoldFontText)
        if range.location != NSNotFound {
            attributedString.setAttributes([.font: UIFont.TurkcellSaturaBolFont(size: 18)], range: range)
        }
        
        titleLabel.attributedText = attributedString
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
    }
    
    override func setupActionButton() {
        actionButton.setTitle(TextConstants.Spotify.CancelImportPopup.cancelButton, for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.backgroundColor = ColorConstants.selectedBottomBarButtonColor
        actionButton.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
        actionButton.layer.masksToBounds = true
        actionButton.layer.cornerRadius = actionButton.bounds.height * 0.5
    }
    
    override func setupDismissButton() {
        dismissButton.setTitle(TextConstants.Spotify.CancelImportPopup.continueButton, for: .normal)
        dismissButton.setTitleColor(ColorConstants.blueColor, for: .normal)
        dismissButton.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
        dismissButton.layer.masksToBounds = true
        dismissButton.layer.cornerRadius = dismissButton.bounds.height * 0.5
        dismissButton.layer.borderColor = ColorConstants.blueColor.cgColor
        dismissButton.layer.borderWidth = 1
    }

}
