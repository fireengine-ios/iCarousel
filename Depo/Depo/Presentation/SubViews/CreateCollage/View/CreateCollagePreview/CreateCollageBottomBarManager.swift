//
//  CreateCollageBottomBarManager.swift
//  Lifebox
//
//  Created by Ozan Salman on 9.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class CreateCollageBottomBarManager {
    
    private var saveConfig = EditingBarConfig(
        elementsConfig:  [.collageSave, .collageDelete],
        style: .default,
        tintColor: AppColor.tint.color,
        unselectedItemTintColor: AppColor.label.color,
        barTintColor: AppColor.drawerBackground.color
    )
    
    private var changeConfig = EditingBarConfig(
        elementsConfig:  [.collageChange, .collageCancel],
        style: .default,
        tintColor: AppColor.tint.color,
        unselectedItemTintColor: AppColor.label.color,
        barTintColor: AppColor.drawerBackground.color
    )
    
    var editingTabBar: BottomSelectionTabBarDrawerViewController?
    private let bottomBarPresenter = BottomSelectionTabBarPresenter()
    
    private weak var delegate: BaseItemInputPassingProtocol!
    
    init(delegate: BaseItemInputPassingProtocol) {
        self.delegate = delegate
    }
    
    func setup() {
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        bottomBarPresenter.basePassingPresenter = delegate
        let botvarBarVC = bottomBarVCmodule.setupDrawerVariantModule(config: saveConfig, settablePresenter: bottomBarPresenter)
        self.editingTabBar = botvarBarVC
    }
    
    func update(configType: PhotoSelectType) {
        switch configType {
        case .newPhotoSelection:
            bottomBarPresenter.setupCreateCollageTabBarWith(originalConfig: saveConfig)
        case .changePhotoSelection:
            bottomBarPresenter.setupCreateCollageTabBarWith(originalConfig: changeConfig)
        }
        
    }
    
    func show() {
        bottomBarPresenter.show(animated: true, onView: nil)
    }
    
    func hide() {
        bottomBarPresenter.dismissWithNotification()
    }
    
    
}
