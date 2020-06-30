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
            switch self {
            case .backUp(_):
                return TextConstants.contactSyncErrorBackupTitle
            case .deleteBackUp, .deleteDuplicates, .deleteAllContacts:
                return TextConstants.contactSyncErrorDeleteTitle
            case .restore:
                return TextConstants.contactSyncErrorRestoreTitle
            }
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

    static func with(title: String, message: String, operationResult: ContactsOperationResult) -> ContactsOperationView {
        let view = ContactsOperationView.initFromNib()
        view.titleLabel.text = title
        view.messageLabel.text = message
        view.imageView.image = operationResult.image
        return view
    }
    
    func add(card: UIView) {
        cardsStackView.addArrangedSubview(card)
    }
}

final class BackupContactsOperationView: UIView {
    
    static func with(type: ContactsOperationType, result: ContactsOperationResult) -> BackupContactsOperationView {
        let view = BackupContactsOperationView()
        view.contentView = ContactsOperationView.with(type: type, result: result)
        view.addSubview(view.contentView)
        view.setupCards()
        return view
    }
    
    private var contentView: ContactsOperationView!
    
    private lazy var scheduleCard: ContactSyncScheduleCard = {
        let card = ContactSyncScheduleCard.initFromNib()
            .onAction { [weak self] sender in
                self?.showAutoBackupOptions(sender: sender)
        }
        
        card.set(periodicSyncOption: periodicSyncHelper.settings.timeSetting.option)
        
        return card
    }()
    
    private let periodicSyncHelper = PeriodicSync()
    
    private lazy var autobackupActionSheet: UIAlertController = {
        
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let options: [PeriodicContactsSyncOption] = [.off, .daily, .weekly, .monthly]
        
        options.forEach { type in
            let action = UIAlertAction(title: type.localizedText, style: .default, handler: { [weak self] _ in
                self?.changeAutoBackup(to: type)
            })
            actionSheetVC.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: TextConstants.actionSheetCancel, style: .cancel)
        actionSheetVC.addAction(cancelAction)
        
        actionSheetVC.view.tintColor = UIColor.black
        actionSheetVC.popoverPresentationController?.permittedArrowDirections = .up
        
        return actionSheetVC
    }()
    
    private func showAutoBackupOptions(sender: Any) {
        guard let controller = RouterVC().getViewControllerForPresent() else {
            return
        }
        
        autobackupActionSheet.popoverPresentationController?.sourceView = self
        
        if let button = sender as? UIButton {
            let buttonRect = button.convert(button.bounds, to: self)
            let rect = CGRect(x: buttonRect.midX, y: buttonRect.minY - 10, width: 10, height: 50)
            autobackupActionSheet.popoverPresentationController?.sourceRect = rect
        }
        
        controller.present(autobackupActionSheet, animated: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
    
    private func changeAutoBackup(to option: PeriodicContactsSyncOption) {
        scheduleCard.set(periodicSyncOption: option)
        periodicSyncHelper.save(option: option)
    }
    
    func setupCards() {
        if periodicSyncHelper.settings.timeSetting.option == .off {
            contentView.add(card: scheduleCard)
        }
    }
}
