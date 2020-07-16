//
//  ContactSyncBigCardView.swift
//  Depo
//
//  Created by Konstantin Studilin on 22.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

typealias SenderHandler = (Any) -> ()


final class ContactSyncBigCardView: ContactSyncBaseCardView, NibInit {
    
    //MARK: Top View
    
    @IBOutlet private weak var message: UILabel! {
        willSet {
            newValue.text = TextConstants.contactSyncBigCardBackupMessage
            newValue.font = .TurkcellSaturaMedFont(size: 24.0)
            newValue.textColor =  .white
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var numberOfContacts: UILabel! {
        willSet {
            newValue.text = "0"
            newValue.font = .TurkcellSaturaDemFont(size: 60.0)
            newValue.textColor =  .white
            newValue.numberOfLines = 1
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var contactsText: UILabel! {
        willSet {
            newValue.text = TextConstants.contactSyncBigCardContacts
            newValue.font = .TurkcellSaturaDemFont(size: 20.0)
            newValue.textColor =  .white
            newValue.numberOfLines = 1
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var backUpButton: RoundedInsetsButton! {
        willSet {
            newValue.insets = UIEdgeInsets(topBottom: 8.0, rightLeft: 24.0)
            newValue.setTitle(TextConstants.contactSyncBackupButton, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 16.0)
            newValue.setTitleColor(.lrTealishTwo, for: .normal)
            newValue.setBackgroundColor(.white, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    //MARK: Bottom View
    
    @IBOutlet private weak var seeContactsButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.contactSyncBigCardSeeContactsButton, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 14.0)
            newValue.setTitleColor(.lrTealishTwo, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    
    //MARK: Auto Backup Button UI
    @IBOutlet private weak var autoBackupButton: UIButton! {
        willSet {
            newValue.setTitle(" ", for: .normal)
            newValue.backgroundColor = .clear
        }
    }
    
    @IBOutlet private weak var arrowImage: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFit
            newValue.image = UIImage(named: "ic_arrow_down")
        }
    }
    
    @IBOutlet private weak var autoBackupText: UILabel! {
        willSet {
            newValue.text = TextConstants.contactSyncBigCardAutobackupFormat
            newValue.font = .TurkcellSaturaDemFont(size: 14.0)
            newValue.textColor =  .lrTealishTwo
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    
    //MARK: Buttons action handlers
    
    private var actionHandlerBackup: VoidHandler?
    private var actionHandlerSeeContacts: VoidHandler?
    private var actionHandlerAutoBackup: SenderHandler?
    
    
    //MARK: - Override
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .lrTealishTwo
    }
    
    //MARK: - Public
    
    @discardableResult
    func onBackup(handler: VoidHandler?) -> ContactSyncBigCardView {
        actionHandlerBackup = handler
        return self
    }
    
    @discardableResult
    func onSeeContacts(handler: VoidHandler?) -> ContactSyncBigCardView {
        actionHandlerSeeContacts = handler
        return self
    }
    
    @discardableResult
    func onAutoBackup(handler: SenderHandler?) -> ContactSyncBigCardView {
        actionHandlerAutoBackup = handler
        return self
    }
    
    func set(numberOfContacts: Int) {
        DispatchQueue.toMain {
            self.numberOfContacts.text = "\(numberOfContacts)"
        }
    }
    
    func set(periodicSyncOption: PeriodicContactsSyncOption) {
        DispatchQueue.toMain {
            self.autoBackupText.text = String(format: TextConstants.contactSyncBigCardAutobackupFormat, periodicSyncOption.localizedText)
        }
    }
    
    //MARK: - IB Actions
    
    @IBAction private func didTouchAutoBackup(_ sender: Any) {
        actionHandlerAutoBackup?(sender)
    }
    
    @IBAction func didTouchBackup(_ sender: Any) {
        actionHandlerBackup?()
    }
    
    @IBAction func didTouchSeeContacts(_ sender: Any) {
        actionHandlerSeeContacts?()
    }
    
}
