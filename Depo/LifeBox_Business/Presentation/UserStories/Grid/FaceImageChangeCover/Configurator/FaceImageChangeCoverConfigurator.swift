//
//  FaceImageChangeCoverConfigurator.swift
//  Depo
//
//  Created by Harbros on 30.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class FaceImageChangeCoverConfigurator {
    
    func configure(viewController: FaceImageChangeCoverViewController,
                   itemsService: FaceImageDetailService, moduleOutput: FaceImageChangeCoverModuleOutput?) {
        let router = FaceImageChangeCoverRouter()
        
        let presenter = FaceImageChangeCoverPresenter(sortedRule: .timeUp)
        
        let alertSheetConfig = AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                   selectionModeTypes: [.createStory, .addToFavorites, .moveToTrash])
        
        let alertSheetModuleInitilizer = AlertFilesActionsSheetPresenterModuleInitialiser()
        let alertModulePresenter = alertSheetModuleInitilizer.createModule()
        presenter.alertSheetModule = alertModulePresenter
        alertModulePresenter.basePassingPresenter = presenter
        
        //presenter.topBarConfig = alertSheetConfig
        
        presenter.view = viewController
        presenter.router = router
        presenter.customModuleOutput = moduleOutput
        
        let interactor = FaceImageChangeCoverInteractor(remoteItems: itemsService)
        interactor.output = presenter
        interactor.alertSheetConfig = alertSheetConfig
        
        presenter.interactor = interactor
        viewController.output = presenter
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .print, .addToAlbum, .removeFromAlbum],
                                               style: .default, tintColor: nil)
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        let botvarBarVC = bottomBarVCmodule.setupModule(config: bottomBarConfig, settablePresenter: BottomSelectionTabBarPresenter())
        viewController.editingTabBar = botvarBarVC
        presenter.bottomBarPresenter = bottomBarVCmodule.presenter
        bottomBarVCmodule.presenter?.basePassingPresenter = presenter
        
        interactor.bottomBarOriginalConfig = bottomBarConfig
    }
}
