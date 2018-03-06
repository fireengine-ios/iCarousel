//
//  DocumentActionViewController.swift
//  LifeboxFileProviderUI
//
//  Created by Bondar Yaroslav on 3/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import FileProviderUI

/// custom action in Info.plist
/// https://stackoverflow.com/questions/47089696/how-to-create-custom-action-in-fileproviderui
final class DocumentActionViewController: FPUIActionExtensionViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    
    override func prepare(forError error: Error) {
        if error.localizedDescription == "passcode" {
            titleLabel?.text = L10n.errorPasscodeTitle
            messageLabel?.text = L10n.errorPasscodeMessage
        } else if error.localizedDescription == "authentication" {
            titleLabel?.text = L10n.errorAuthenticationTitle
            messageLabel?.text = L10n.errorAuthenticationMessage
        } else {
            titleLabel?.text = L10n.error
            messageLabel?.text = error.localizedDescription
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        extensionContext.cancelRequest(withError: NSError(domain: FPUIErrorDomain, code: Int(FPUIExtensionErrorCode.userCancelled.rawValue), userInfo: nil))
    }
}

