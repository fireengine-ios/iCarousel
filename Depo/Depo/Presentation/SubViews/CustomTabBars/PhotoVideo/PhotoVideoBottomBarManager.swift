//
//  PhotoVideoBottomBarManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PhotoVideoBottomBarManager {
    
    var elementsConfig: [ElementTypes] = [.share, .download, .sync, .moveToTrash]
    
    private lazy var photoVideoBottomBarConfig: EditingBarConfig = {
        return EditingBarConfig(
            elementsConfig: self.elementsConfig,
            style: .default,
            tintColor: AppColor.tint.color,
            unselectedItemTintColor: AppColor.label.color,
            barTintColor: AppColor.secondaryBackground.color
        )
    }()
    
    private func configureElementsForTurkey() {
        if SingletonStorage.shared.accountInfo?.isUserFromTurkey == true {
            if let syncIndex = elementsConfig.firstIndex(of: .sync) {
                elementsConfig.insert(.print, at: syncIndex + 1)
            }
        }
    }
    
    var editingTabBar: BottomSelectionTabBarDrawerViewController?
    private let bottomBarPresenter = BottomSelectionTabBarPresenter()
    
    private weak var delegate: BaseItemInputPassingProtocol!
    
    init(delegate: BaseItemInputPassingProtocol) {
        self.delegate = delegate
        configureElementsForTurkey()
    }
    
    func setup() {
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        bottomBarPresenter.basePassingPresenter = delegate
        let botvarBarVC = bottomBarVCmodule.setupDrawerVariantModule(config: photoVideoBottomBarConfig, settablePresenter: bottomBarPresenter)
        self.editingTabBar = botvarBarVC
    }
    
    func update(for items: [WrapData]) {
        bottomBarPresenter.setupTabBarWith(items: items, originalConfig: photoVideoBottomBarConfig)
        
        for item in items {
            switch item.syncStatus {
            case .synced:
                editingTabBar?.enableItems(at: [3])
            case .notSynced:
                editingTabBar?.disableItems(at: [3])
            case .synchronizing:
                print("synchronizing")
            case .unknown:
                print("unknown")
            }
        }
    }
    
    func show() {
        bottomBarPresenter.show(animated: true, onView: nil)
    }
    
    func hide() {
        bottomBarPresenter.dismissWithNotification()
    }
}
