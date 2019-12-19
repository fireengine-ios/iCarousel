//
//  HiddenPhotosBottomBarManager.swift
//  Depo
//
//  Created by Andrei Novikau on 12/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

private protocol HiddenPhotosTabBarPresenterDelegate: class {
    func bottomBarSelectedItem(_ item: ElementTypes)
}

private final class HiddenPhotosBottomTabBarPresenter: BottomSelectionTabBarPresenter {
    
    weak var delegate: HiddenPhotosTabBarPresenterDelegate?
    
    private var types = [ElementTypes]()
    
    func setup(with types: [ElementTypes], delegate: HiddenPhotosTabBarPresenterDelegate?) {
        self.types = types
        self.delegate = delegate
    }
    
    override func bottomBarSelectedItem(index: Int, sender: UITabBarItem) {
        delegate?.bottomBarSelectedItem(types[index])
    }
}

protocol HiddenPhotosBottomBarManagerDelegate: class {
    func onBottomBarDelete()
    func onBottomBarUnhide()
}

final class HiddenPhotosBottomBarManager {

    private let bottomBarConfig = EditingBarConfig(elementsConfig:  [.unhide, .delete],
                                                          style: .blackOpaque,
                                                          tintColor: nil)
    
    var editingTabBar: BottomSelectionTabBarViewController?
    private let bottomBarPresenter = HiddenPhotosBottomTabBarPresenter()
    
    private weak var delegate: HiddenPhotosBottomBarManagerDelegate?
    
    init(delegate: HiddenPhotosBottomBarManagerDelegate) {
        self.delegate = delegate
    }
    
    func setup() {
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        bottomBarPresenter.setup(with: bottomBarConfig.elementsConfig, delegate: self)
        let bottomBarVC = bottomBarVCmodule.setupModule(config: bottomBarConfig, settablePresenter: bottomBarPresenter)
        editingTabBar = bottomBarVC
    }
    
    func show() {
        bottomBarPresenter.show(animated: true, onView: nil)
    }
    
    func hide() {
        bottomBarPresenter.dismissWithNotification()
    }
}

// MARK: - HiddenPhotosTabBarPresenterDelegate

extension HiddenPhotosBottomBarManager: HiddenPhotosTabBarPresenterDelegate {
    
    func bottomBarSelectedItem(_ item: ElementTypes) {
        switch item {
        case .unhide:
            delegate?.onBottomBarUnhide()
        case .delete:
            delegate?.onBottomBarDelete()
        default:
            assertionFailure("unknown action \(item)")
        }
    }
}
