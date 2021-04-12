//
//  PrivateShareSharedFilesBottomBarManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 16.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class PrivateShareSharedFilesBottomBarManager {
    
    private var editingTabBar: BottomSelectionTabBarViewController?
    private let bottomBarPresenter = BottomSelectionTabBarPresenter()
    
    private weak var delegate: BaseItemInputPassingProtocol!
    
    init(delegate: BaseItemInputPassingProtocol) {
        self.delegate = delegate
    }
    
    func setup() {
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        bottomBarPresenter.basePassingPresenter = delegate
        let botvarBarVC = bottomBarVCmodule.setupModule(config: EditingBarConfig.emptyConfig, settablePresenter: bottomBarPresenter)
        self.editingTabBar = botvarBarVC
    }
    
    func updateLayout() {
        DispatchQueue.main.async {
            self.editingTabBar?.view.layoutIfNeeded()
        }
    }
    
    func update(for items: [WrapData], shareType: PrivateShareType) {
        bottomBarPresenter.setupTabBarWith(items: items, shareType: shareType)
    }
    
    func show(on view: UIView) {
        bottomBarPresenter.show(animated: true, onView: view)
    }
    
    func hide() {
        bottomBarPresenter.dismissWithNotification()
    }
}
