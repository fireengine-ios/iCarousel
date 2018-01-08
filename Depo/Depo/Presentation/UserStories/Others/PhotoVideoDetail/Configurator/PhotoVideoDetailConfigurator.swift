//
//  PhotoVideoDetailPhotoVideoDetailConfigurator.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhotoVideoDetailModuleConfigurator {

    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, photoVideoBottomBarConfig: EditingBarConfig, documentsBottomBarConfig: EditingBarConfig) {

        if let viewController = viewInput as? PhotoVideoDetailViewController {
            configure(viewController: viewController, photoVideoBottomBarConfig: photoVideoBottomBarConfig, documentsBottomBarConfig: documentsBottomBarConfig, alertSheetExcludeTypes: [.delete],
                      photoDetailMoreMenu: ActionSheetPredetermendConfigs.photoVideoDetailActions)
        }
    }

    func configureModuleFromAlbumForViewInput<UIViewController>(viewInput: UIViewController, photoVideoBottomBarConfig: EditingBarConfig, documentsBottomBarConfig: EditingBarConfig) {
        
        if let viewController = viewInput as? PhotoVideoDetailViewController {
            configure(viewController: viewController, photoVideoBottomBarConfig: photoVideoBottomBarConfig, documentsBottomBarConfig: documentsBottomBarConfig, interactor: PhotoVideoAlbumDetailInteractor(), photoDetailMoreMenu: ActionSheetPredetermendConfigs.photoVideoDetailActions + [.delete])
        }
    }
    
    private func configure(viewController: PhotoVideoDetailViewController,
                           photoVideoBottomBarConfig: EditingBarConfig,
                           documentsBottomBarConfig: EditingBarConfig,
                           alertSheetConfig: AlertFilesActionsSheetInitialConfig? = nil,
                           alertSheetExcludeTypes: [ElementTypes] = [ElementTypes](),
                           interactor: PhotoVideoDetailInteractor = PhotoVideoDetailInteractor(),
                           photoDetailMoreMenu: [ElementTypes]) {
        let router = PhotoVideoDetailRouter()

        let presenter = PhotoVideoDetailPresenter()
        presenter.view = viewController
        presenter.router = router
        presenter.alertSheetExcludeTypes = alertSheetExcludeTypes
        
        interactor.output = presenter
        interactor.photoVideoBottomBarConfig = photoVideoBottomBarConfig
        interactor.documentsBottomBarConfig = documentsBottomBarConfig
        
        interactor.moreMenuConfig = photoDetailMoreMenu
        
        //BotomBar Module Setup
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        let botvarBarVC = bottomBarVCmodule.setupModule(config: photoVideoBottomBarConfig, settablePresenter: BottomSelectionTabBarPresenter())
        viewController.editingTabBar = botvarBarVC
        presenter.bottomBarPresenter = bottomBarVCmodule.presenter
        bottomBarVCmodule.presenter?.basePassingPresenter = presenter
        //--------------------
        //AlertSheetActions Module Setup
        let alertSheetModuleInitilizer = AlertFilesActionsSheetPresenterModuleInitialiser()
        let alertModulePresenter = alertSheetModuleInitilizer.createModule()
        presenter.alertSheetModule = alertModulePresenter
        
        alertModulePresenter.basePassingPresenter = presenter
        //-------------------
        presenter.interactor = interactor
        viewController.output = presenter
        viewController.interactor = interactor
    }

}
