//
//  NotificationThreeDotMenuManager.swift
//  Depo
//
//  Created by yilmaz edis on 16.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

final class NotificationThreeDotMenuManager {
    
    private lazy var alert: AlertFilesActionsSheetPresenter = {
        let alert = AlertFilesActionsSheetPresenterModuleInitialiser().createModule()
        alert.basePassingPresenter = delegate
        return alert
    }()
    
    private weak var delegate: BaseItemInputPassingProtocol!
    
    init(delegate: BaseItemInputPassingProtocol) {
        self.delegate = delegate
    }
    
    func showActions(sender: Any?) {
        self.alert.showNotification(with: [.selectMode,
                               .deleteAll], presentedBy: sender, onSourceView: nil, viewController: nil)
    }
}
