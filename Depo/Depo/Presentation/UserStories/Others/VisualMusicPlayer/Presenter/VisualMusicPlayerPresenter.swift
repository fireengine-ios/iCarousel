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
    func changeCover() {}
    func deleteFromFaceImageAlbum(items: [BaseDataSourceItem]) { }
    func selectModeSelected() {}
    func selectAllModeSelected() {}
    func deSelectAll() {}
    func stopModeSelected() {}
    func printSelected() {}
    func openInstaPick() { }
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        guard let currentItem = view.player.currentItem else {
            selectedItemsCallback([])
            return
        }
        selectedItemsCallback([currentItem])
    }

    weak var view: VisualMusicPlayerViewInput!
    var interactor: VisualMusicPlayerInteractorInput!
    var router: VisualMusicPlayerRouterInput!

    weak var bottomBarPresenter: BottomSelectionTabBarModuleInput?

    func viewIsReady(view: UIView, alert: AlertFilesActionsSheetPresenter) {
        alert.basePassingPresenter = self
        bottomBarPresenter?.show(animated: false, onView: view)
    }
    
    func closeMediaPlayer() {
        router.dismiss()
    }
}
