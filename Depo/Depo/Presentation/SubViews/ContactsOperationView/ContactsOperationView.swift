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
    case backUp
    case deleteBackUp
    case deleteDuplicates
    
    func title(result: ContactsOperationResult) -> String {
        if result == .failed {
            return "Unknown Error"
        }
        
        switch self {
        case .backUp:
            return "Back up Successfully"
        case .deleteBackUp:
            return "Delete Successfully"
        case .deleteDuplicates:
            return TextConstants.deleteDuplicatesSuccessTitle
        }
    }
    
    func message(result: ContactsOperationResult) -> String {
        if result == .failed {
            return "An unknown error was encountered. Please try again later."
        }
        
        switch self {
        case .backUp:
            return "You have new 420 contacts and no possible duplicates to review in your lifebox."
        case .deleteBackUp:
            return "You delete duplicated contacts from your phone and lorem ipsum lorem ipsum."
        case .deleteDuplicates:
            return TextConstants.deleteDuplicatesSuccessMessage
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
    @IBOutlet private weak var cardsStackView: UIStackView!

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
