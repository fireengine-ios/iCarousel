//
//  ContactSyncMainView.swift
//  Depo
//
//  Created by Konstantin Studilin on 21.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit


protocol ContactSyncMainViewDelegate: ContactsBackupActionProviderProtocol {
    func showBackups()
    func deleteDuplicates()
    func changePeriodicSync(to option: PeriodicContactsSyncOption)
}



final class ContactSyncMainView: UIView, NibInit {
    
    weak var delegate: ContactSyncMainViewDelegate?
    

    @IBOutlet weak var cardsStack: UIStackView! {
        willSet {
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.spacing = 24.0
        }
    }

    
    private lazy var bigInfoCard: ContactSyncBigCardView = {
        let bigBackupCard = ContactSyncBigCardView.initFromNib()
        
        bigBackupCard.onBackup { [weak self] in
            self?.delegate?.backUp()
        }
        .onSeeBackup { [weak self] in
            self?.delegate?.showBackups()
        }
        .onAutoBackup { [weak self] sender in
            self?.showAutoBackupOptions(sender: sender)
        }
        
        return bigBackupCard
    }()
    
    
    private lazy var autobackupActionSheet: UIAlertController = {
        
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let options: [PeriodicContactsSyncOption] = [.off, .weekly, .monthly]
        
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
    
    
    //MARK:- Override
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    
    //MARK:- Public
    
    func update(with model: ContactSync.SyncResponse, periodicSyncOption: PeriodicContactsSyncOption) {
        bigInfoCard.set(numberOfContacts: model.totalNumberOfContacts)
        bigInfoCard.set(periodicSyncOption: periodicSyncOption)
    }
    
    
    //MARK:- Private
    
    private func setup() {
        DispatchQueue.toMain {
            self.cardsStack.addArrangedSubview(self.bigInfoCard)
            
            let showBackupCard = ContactSyncSmallCardView.initFromNib()
            showBackupCard.setup(with: .showBackup, action: { [weak self] in
                self?.delegate?.showBackups()
            })
            self.cardsStack.addArrangedSubview(showBackupCard)
            
            let deleteDuplicatesCard = ContactSyncSmallCardView.initFromNib()
            deleteDuplicatesCard.setup(with: .deleteDuplicates, action: { [weak self] in
                self?.delegate?.deleteDuplicates()
            })
            self.cardsStack.addArrangedSubview(deleteDuplicatesCard)
        }
    }
    
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
    
    private func changeAutoBackup(to option: PeriodicContactsSyncOption) {
        bigInfoCard.set(periodicSyncOption: option)
        delegate?.changePeriodicSync(to: option)
    }
    
}
