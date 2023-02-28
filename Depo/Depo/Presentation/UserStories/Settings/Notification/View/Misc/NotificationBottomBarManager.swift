//
//  NotificationBottomBarManager.swift
//  Depo
//
//  Created by yilmaz edis on 18.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

final class NotificationBottomBarManager {
    
    private var config1 = EditingBarConfig(
        elementsConfig:  [.selectAll, .delete],
        style: .default,
        tintColor: AppColor.tint.color,
        unselectedItemTintColor: AppColor.label.color,
        barTintColor: AppColor.secondaryBackground.color
    )
    
    private var config2 = EditingBarConfig(
        elementsConfig:  [.selectAll, .deleteAll],
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
    
    func update(for status: Bool, isSelectedAll: Bool) {
        bottomBarPresenter.setupNotificationTabBarWith(status: status, originalConfig: isSelectedAll ? config2 : config1)
    }
    
    func show() {
        bottomBarPresenter.show(animated: true, onView: nil)
    }
    
    func hide() {
        bottomBarPresenter.dismissWithNotification()
    }
}
