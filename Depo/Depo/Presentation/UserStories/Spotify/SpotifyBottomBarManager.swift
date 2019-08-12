//
//  SpotifyBottomBarManager.swift
//  Depo
//
//  Created by Andrei Novikau on 8/12/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

private protocol SpotifyTabBarPresenterDelegate: class {
    func bottomBarSelectedItem(_ item: ElementTypes)
}

private final class SpotifyBottomTabBarPresenter: BottomSelectionTabBarPresenter {
    
    weak var delegate: SpotifyTabBarPresenterDelegate?
    
    private var types = [ElementTypes]()
    
    func setup(with types: [ElementTypes], delegate: SpotifyTabBarPresenterDelegate?) {
        self.types = types
        self.delegate = delegate
    }
    
    override func bottomBarSelectedItem(index: Int, sender: UITabBarItem) {
        delegate?.bottomBarSelectedItem(types[index])
    }
}

protocol SpotifyBottomBarManagerDelegate: class {
    func onBottomBarManagerDelete()
}

final class SpotifyBottomBarManager {
    
    private let spotifyBottomBarConfig = EditingBarConfig(elementsConfig:  [.delete],
                                                          style: .blackOpaque,
                                                          tintColor: nil)
    
    var editingTabBar: BottomSelectionTabBarViewController?
    private let bottomBarPresenter = SpotifyBottomTabBarPresenter()
    
    private weak var delegate: SpotifyBottomBarManagerDelegate?
    
    init(delegate: SpotifyBottomBarManagerDelegate) {
        self.delegate = delegate
    }
    
    func setup() {
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        bottomBarPresenter.setup(with: spotifyBottomBarConfig.elementsConfig, delegate: self)
        let bottomBarVC = bottomBarVCmodule.setupModule(config: spotifyBottomBarConfig, settablePresenter: bottomBarPresenter)
        editingTabBar = bottomBarVC
    }
    
    func show() {
        bottomBarPresenter.show(animated: true, onView: nil)
    }
    
    func hide() {
        bottomBarPresenter.dismissWithNotification()
    }
}

// MARK: - SpotifyTabBarPresenterDelegate

extension SpotifyBottomBarManager: SpotifyTabBarPresenterDelegate {
    
    func bottomBarSelectedItem(_ item: ElementTypes) {
        switch item {
        case .delete:
            delegate?.onBottomBarManagerDelete()
        default:
            break
        }
    }
}
