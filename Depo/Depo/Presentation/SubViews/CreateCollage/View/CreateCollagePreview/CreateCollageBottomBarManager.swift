//
//  CreateCollageBottomBarManager.swift
//  Lifebox
//
//  Created by Ozan Salman on 9.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class CreateCollageBottomBarManager {
    
    private var config1 = EditingBarConfig(
        elementsConfig:  [.collageSave, .collageDelete],
        style: .default,
        tintColor: AppColor.tint.color,
        unselectedItemTintColor: AppColor.label.color,
        barTintColor: AppColor.secondaryBackground.color
    )
    
    private var config2 = EditingBarConfig(
        elementsConfig:  [.collageSave, .collageChange],
        style: .default,
        tintColor: AppColor.tint.color,
        unselectedItemTintColor: AppColor.label.color,
        barTintColor: AppColor.secondaryBackground.color
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
        let botvarBarVC = bottomBarVCmodule.setupDrawerVariantModule(config: config2, settablePresenter: bottomBarPresenter)
        self.editingTabBar = botvarBarVC
    }
    
    func update(isSelectedAll: Bool) {
        //bottomBarPresenter.setupCreateCollageTabBarWith(originalConfig: isSelectedAll ? config2 : config1)
    }
    
    func show() {
        bottomBarPresenter.show(animated: true, onView: nil)
    }
    
    func hide() {
        bottomBarPresenter.dismissWithNotification()
    }
    
    
}
