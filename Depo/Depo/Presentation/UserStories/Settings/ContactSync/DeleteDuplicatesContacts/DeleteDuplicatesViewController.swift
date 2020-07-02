//
//  DeleteDuplicatesViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 5/25/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class DeleteDuplicatesViewController: BaseViewController {

    private lazy var mainView = DeleteDuplicatesMainView.with(contacts: contacts, delegate: self)
    
    var progressView: ContactOperationProgressView?
    
    private let contactSyncHelper = ContactSyncHelper.shared
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var animator = ContentViewAnimator()
    
    private var contacts = [ContactSync.AnalyzedContact]()
    
    private lazy var router = RouterVC()
    
    // MARK: -
    
    static func with(contacts: [ContactSync.AnalyzedContact]) -> DeleteDuplicatesViewController {
        let controller = DeleteDuplicatesViewController()
        controller.contacts = contacts
        return controller
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackScreen()
        
        backButtonForNavigationItem(title: TextConstants.backTitle)
        setTitle(withString: TextConstants.deleteDuplicatesTitle)
        
        showRelatedView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
        contactSyncHelper.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        contactSyncHelper.cancelAnalyze()
    }
    
    private func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.DeleteDuplicateScreen())
        analyticsService.logScreen(screen: .contactSyncDeleteDuplicates)
        analyticsService.trackDimentionsEveryClickGA(screen: .contactSyncDeleteDuplicates)
    }
}

//MARK: - ContactSyncHelperDelegate
//MARK: - ContactSyncControllerProtocol

extension DeleteDuplicatesViewController: ContactSyncControllerProtocol, ContactSyncHelperDelegate {
    
    func show(view: UIView, animated: Bool) {
        animator.showTransition(to: view, on: self.view, animated: animated)
    }
    
    func showRelatedView() {
        show(view: mainView, animated: true)
    }
    
    func handle(error: ContactSyncHelperError, operationType: SyncOperationType) { }
    func didFinishOperation(operationType: SyncOperationType) { }
}

//MARK: - DeleteDuplicatesMainViewDelegate

extension DeleteDuplicatesViewController: DeleteDuplicatesMainViewDelegate {
    
    func onDeleteAllTapped() {
        showPopup(type: .deleteDuplicates)
    }
}
