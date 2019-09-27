//
//  TBMatikPhotosBottomBarManager.swift
//  Depo
//
//  Created by Andrei Novikau on 9/24/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class TBMatikPhotosBottomBarManager {
    
    private let tbmatikBottomBarConfig = EditingBarConfig(elementsConfig: [.share],
                                                          style: .blackOpaque,
                                                          tintColor: nil)
    
    var editingTabBar: BottomSelectionTabBarViewController?
    private let bottomBarPresenter = BottomSelectionTabBarPresenter()
    
    private weak var delegate: BaseItemInputPassingProtocol!
    
    init(delegate: BaseItemInputPassingProtocol) {
        self.delegate = delegate
        setup()
    }
    
    private func setup() {
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        bottomBarPresenter.basePassingPresenter = delegate
        let botvarBarVC = bottomBarVCmodule.setupModule(config: tbmatikBottomBarConfig, settablePresenter: bottomBarPresenter)
        editingTabBar = botvarBarVC
    }
    
    func shareCurrentItem() {
        bottomBarPresenter.bottomBarSelectedItem(index: 0, sender: UITabBarItem())
    }
}
