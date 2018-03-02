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

class DocumentActionViewController: FPUIActionExtensionViewController {
    
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var actionTypeLabel: UILabel!
    
    /// not used
    override func prepare(forAction actionIdentifier: String, itemIdentifiers: [NSFileProviderItemIdentifier]) {
        identifierLabel?.text = actionIdentifier
        actionTypeLabel?.text = "Custom action"
    }
    
    override func prepare(forError error: Error) {
        
        if error.localizedDescription == "passcode" {
            identifierLabel?.text = "Passcode"
            actionTypeLabel?.text = "passcode"
        } else if error.localizedDescription == "authentication" {
            identifierLabel?.text = "Authenticate"
            actionTypeLabel?.text = "authenticate"
        } else {
            identifierLabel?.text = nil
            actionTypeLabel?.text = nil
        }
    }

    /// not used
    @IBAction func doneButtonTapped(_ sender: Any) {
        // Perform the action and call the completion block. If an unrecoverable error occurs you must still call the completion block with an error. Use the error code FPUIExtensionErrorCode.failed to signal the failure.
        extensionContext.completeRequest()
    }
    
    /// need
    @IBAction func cancelButtonTapped(_ sender: Any) {
        extensionContext.cancelRequest(withError: NSError(domain: FPUIErrorDomain, code: Int(FPUIExtensionErrorCode.userCancelled.rawValue), userInfo: nil))
    }
    
}

