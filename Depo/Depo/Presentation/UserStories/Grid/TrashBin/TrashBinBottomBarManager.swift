//
//  TrashBinBottomBarManager.swift
//  Depo
//
//  Created by Andrei Novikau on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

private protocol TrashBinTabBarPresenterDelegate: class {
    func bottomBarSelectedItem(_ item: ElementTypes)
}

private final class TrashBinBottomTabBarPresenter: BottomSelectionTabBarPresenter {
    
    weak var delegate: TrashBinTabBarPresenterDelegate?
    
    private var types = [ElementTypes]()
    
    func setup(with types: [ElementTypes], delegate: TrashBinTabBarPresenterDelegate?) {
        self.types = types
        self.delegate = delegate
    }
    
    override func bottomBarSelectedItem(index: Int, sender: UITabBarItem) {
        delegate?.bottomBarSelectedItem(types[index])
    }
}

protocol TrashBinBottomBarManagerDelegate: class {
    func onBottomBarDelete()
    func onBottomBarRestore()
}

final class TrashBinBottomBarManager {

    private let bottomBarConfig = EditingBarConfig(elementsConfig:  [.restore, .delete],
                                                          style: .blackOpaque,
                                                          tintColor: nil)
    
    var editingTabBar: BottomSelectionTabBarViewController?
    private let bottomBarPresenter = TrashBinBottomTabBarPresenter()
    
    private weak var delegate: TrashBinBottomBarManagerDelegate?
    
    init(delegate: TrashBinBottomBarManagerDelegate) {
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

// MARK: - TrashBinTabBarPresenterDelegate

extension TrashBinBottomBarManager: TrashBinTabBarPresenterDelegate {
    
    func bottomBarSelectedItem(_ item: ElementTypes) {
        switch item {
        case .restore:
            delegate?.onBottomBarRestore()
        case .delete:
            delegate?.onBottomBarDelete()
        default:
            assertionFailure("unknown action \(item)")
        }
    }
}
