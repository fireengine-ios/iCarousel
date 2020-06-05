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
        controller.syncResult = syncResult
        controller.type = type
        return controller
    }
    

    @IBOutlet private weak var contentView: UIView!
    
    private var periodicSyncHelper: PeriodicSync!
    private var type: ContactsOperationResult!
    private var syncResult: ContactSync.SyncResponse?
    
    private lazy var successView = BackupContactsOperationView.with(type: .backUp(syncResult), result: .success)
    private lazy var failView = ContactsOperationView.with(type: .backUp(nil), result: .failed)
    
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
        setTitle(withString: TextConstants.contactBackupSuccessNavbarTitle)
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
}
