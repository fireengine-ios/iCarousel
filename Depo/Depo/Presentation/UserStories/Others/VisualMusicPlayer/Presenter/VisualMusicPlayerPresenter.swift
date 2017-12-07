//
//  VisualMusicPlayerVisualMusicPlayerPresenter.swift
//  Depo
//
//  Created by AlexanderP on 11/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class VisualMusicPlayerPresenter: VisualMusicPlayerModuleInput, VisualMusicPlayerViewOutput, VisualMusicPlayerInteractorOutput, BaseItemInputPassingProtocol {
    
    func operationFinished(withType type: ElementTypes, response: Any?) {}
    func operationFailed(withType type: ElementTypes) {}
    func selectModeSelected() {}
    func selectAllModeSelected() {}
    func shareModeSelected() {}
    func printSelected() {}
    var selectedItems: [BaseDataSourceItem] {
        if let currentItem = view.player.currentItem {
            return [currentItem]
        }
        return []
    }

    weak var view: VisualMusicPlayerViewInput!
    var interactor: VisualMusicPlayerInteractorInput!
    var router: VisualMusicPlayerRouterInput!

    weak var bottomBarPresenter: BottomSelectionTabBarModuleInput?

    func viewIsReady(view: UIView) {
        bottomBarPresenter?.show(animated: false, onView: view)
    }
}
