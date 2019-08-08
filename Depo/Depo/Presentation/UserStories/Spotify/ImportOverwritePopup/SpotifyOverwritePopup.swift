//
//  SpotifyOverwritePopup.swift
//  Depo
//
//  Created by Andrei Novikau on 7/31/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SpotifyOverwritePopup: BaseViewController, NibInit {

    @IBOutlet private weak var contentView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 4
        }
    }
    
    @IBOutlet private weak var messageTitle: UILabel! {
        willSet {
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
            
            newValue.attributedText = attributedString
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var cancelButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.Spotify.OverwritePopup.cancelButton, for: .normal)
            newValue.setTitleColor(ColorConstants.blueColor, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = newValue.bounds.height * 0.5
            newValue.layer.borderColor = ColorConstants.blueColor.cgColor
            newValue.layer.borderWidth = 1
            newValue.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        }
    }
    
    @IBOutlet private weak var importButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.Spotify.OverwritePopup.importButton, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = ColorConstants.blueColor
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = newValue.bounds.height * 0.5
            newValue.addTarget(self, action: #selector(onImport), for: .touchUpInside)
        }
    }
    
    private var importAction: VoidHandler?
    
    // MARK: - View lifecycle
    
    static func with(importAction: @escaping VoidHandler) -> UIViewController {
        let controller = SpotifyOverwritePopup.initFromNib()
        controller.importAction = importAction
        
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        return controller
    }

    // MARK: - Actions
    
    @objc private func onCancel() {
        dismiss(animated: true)
    }
    
    @objc private func onImport() {
        dismiss(animated: true) {
            self.importAction?()
        }
    }
}
