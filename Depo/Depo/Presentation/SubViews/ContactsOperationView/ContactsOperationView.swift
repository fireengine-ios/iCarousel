//
//  ContactsOperationView.swift
//  Depo
//
//  Created by Andrei Novikau on 5/25/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

//TODO: Need configure states and localize strings
enum ContactsOperationType {
    case backUp(ContactSync.SyncResponse?)
    case deleteBackUp
    case deleteDuplicates
    case deleteAllContacts
    case restore
    
    func title(result: ContactsOperationResult) -> String {
        if result == .failed {
            return "Unknown Error"
        }
        
        switch self {
        case .backUp(_):
            return TextConstants.contactBackupSuccessTitle
        case .deleteBackUp, .deleteDuplicates, .deleteAllContacts:
            return TextConstants.deleteDuplicatesSuccessTitle
        case .restore:
            return TextConstants.restoreContactsSuccessTitle
        }
    }
    
    func message(result: ContactsOperationResult) -> String {
        if result == .failed {
            return "An unknown error was encountered. Please try again later."
        }
        
        switch self {
        case .backUp(let result):
            let numberOfContacts = result?.totalNumberOfContacts ?? 0
            return String(format: TextConstants.contactBackupSuccessMessage, numberOfContacts)
        case .deleteBackUp:
            return TextConstants.deleteBackupSuccessMessage
        case .deleteDuplicates:
            return TextConstants.deleteDuplicatesSuccessMessage
        case .deleteAllContacts:
            return TextConstants.deleteAllContactsSuccessMessage
        case .restore:
            return TextConstants.restoreContactsSuccessMessage
        }
    }
}

enum ContactsOperationResult {
    case success
    case failed
    
    var image: UIImage? {
        switch self {
        case .success:
            return UIImage(named: "success")
        case .failed:
            return UIImage(named: "failed")
        }
    }
}

final class ContactsOperationView: UIView, NibInit {

    @IBOutlet private weak var headerView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.toolbarTintColor
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .TurkcellSaturaDemFont(size: 24)
            newValue.textAlignment = .center
            newValue.textColor = ColorConstants.navy
        }
    }
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .TurkcellSaturaFont(size: 16)
            newValue.textAlignment = .center
            newValue.textColor = ColorConstants.duplicatesGray
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    @IBOutlet private weak var cardsStackView: UIStackView!{
        willSet {
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.spacing = 24.0
        }
    }

    static func with(type: ContactsOperationType, result: ContactsOperationResult) -> ContactsOperationView {
        let view = ContactsOperationView.initFromNib()
        view.titleLabel.text = type.title(result: result)
        view.messageLabel.text = type.message(result: result)
        view.imageView.image = result.image
        return view
    }

    func add(card: UIView) {
        cardsStackView.addArrangedSubview(card)
    }
}
