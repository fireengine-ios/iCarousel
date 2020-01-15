//
//  PhotoVideoBottomBarManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PhotoVideoBottomBarManager {
    
    private let photoVideoBottomBarConfig = EditingBarConfig(
        elementsConfig:  [.share, .download, .sync, .hide, .moveToTrash],
        style: .blackOpaque, tintColor: nil)
    
    var editingTabBar: BottomSelectionTabBarViewController?
    private let bottomBarPresenter = BottomSelectionTabBarPresenter()
    
    private weak var delegate: BaseItemInputPassingProtocol!
    
    init(delegate: BaseItemInputPassingProtocol) {
        self.delegate = delegate
    }
    
    func setup() {
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        bottomBarPresenter.basePassingPresenter = delegate
        let botvarBarVC = bottomBarVCmodule.setupModule(config: photoVideoBottomBarConfig, settablePresenter: bottomBarPresenter)
        self.editingTabBar = botvarBarVC
    }
    
    func update(for items: [WrapData]) {
        bottomBarPresenter.setupTabBarWith(items: items, originalConfig: photoVideoBottomBarConfig)
    }
    
    func show() {
        bottomBarPresenter.show(animated: true, onView: nil)
    }
    
    func hide() {
        bottomBarPresenter.dismissWithNotification()
    }
}
