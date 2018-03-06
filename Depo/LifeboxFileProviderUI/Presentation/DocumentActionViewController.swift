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
    
    /// not used
//    override func prepare(forAction actionIdentifier: String, itemIdentifiers: [NSFileProviderItemIdentifier]) {
//        identifierLabel?.text = actionIdentifier
//        actionTypeLabel?.text = "Custom action"
//    }
    
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

    /// not used
//    @IBAction func doneButtonTapped(_ sender: Any) {
//        // Perform the action and call the completion block. If an unrecoverable error occurs you must still call the completion block with an error. Use the error code FPUIExtensionErrorCode.failed to signal the failure.
//        extensionContext.completeRequest()
//    }
    
    /// need
    @IBAction func cancelButtonTapped(_ sender: Any) {
        extensionContext.cancelRequest(withError: NSError(domain: FPUIErrorDomain, code: Int(FPUIExtensionErrorCode.userCancelled.rawValue), userInfo: nil))
    }
}

