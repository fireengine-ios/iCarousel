//
//  ContactSyncOperationResultController.swift
//  Depo
//
//  Created by Konstantin Studilin on 03.06.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit


class ContactSyncOperationResultController: BaseViewController, NibInit {
    
    static func create(with type: ContactsOperationResult, syncResult: ContactSync.SyncResponse?, periodicSync: PeriodicSync) -> ContactSyncOperationResultController {
        let controller = ContactSyncOperationResultController.initFromNib()
        controller.periodicSyncHelper = periodicSync
        controller.numberOfContacts = syncResult?.totalNumberOfContacts ?? 0
        controller.type = type
        return controller
    }
    

    @IBOutlet private weak var contentView: UIView!
    
    private var periodicSyncHelper: PeriodicSync!
    private var type: ContactsOperationResult!
    private var numberOfContacts = 0
    
    private lazy var successView: UIView = {
        let view = ContactsOperationView.with(type: .backUp(contacts: numberOfContacts), result: .success)
        if periodicSyncHelper.settings.timeSetting.option == .off {
            view.add(card: scheduleCard)
        }
        
        return view
    }()
    
    private lazy var scheduleCard: ContactSyncScheduleCard = {
        let card = ContactSyncScheduleCard.initFromNib()
            .onAction { [weak self] sender in
                self?.showAutoBackupOptions(sender: sender)
        }
        
        card.set(periodicSyncOption: periodicSyncHelper.settings.timeSetting.option)
        
        return card
    }()
    
    
    private lazy var failView: UIView = {
        return ContactsOperationView.with(type: .backUp(contacts: numberOfContacts), result: .failed)
    }()
    
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
     
    
    //MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
        showRelatedView()
    }
    
    //MARK: - Private
    
    private func setupNavBar() {
        navigationBarWithGradientStyle()
        //TODO: set title
        setTitle(withString: "")
    }
    
    private func showRelatedView() {
        
        switch type {
            case .success:
                successView.frame = contentView.bounds
                contentView.addSubview(successView)
            case .failed:
                failView.frame = contentView.bounds
                contentView.addSubview(failView)
            default:
                break
        }
    }
    
    private func showAutoBackupOptions(sender: Any) {
        guard let controller = RouterVC().getViewControllerForPresent() else {
            return
        }
        
        autobackupActionSheet.popoverPresentationController?.sourceView = view
        
        if let button = sender as? UIButton {
            let buttonRect = button.convert(button.bounds, to: view)
            let rect = CGRect(x: buttonRect.midX, y: buttonRect.minY - 10, width: 10, height: 50)
            autobackupActionSheet.popoverPresentationController?.sourceRect = rect
        }
        
        controller.present(autobackupActionSheet, animated: true)
    }
    
    private func changeAutoBackup(to option: PeriodicContactsSyncOption) {
        scheduleCard.set(periodicSyncOption: option)
        periodicSyncHelper.save(option: option)
    }
}
