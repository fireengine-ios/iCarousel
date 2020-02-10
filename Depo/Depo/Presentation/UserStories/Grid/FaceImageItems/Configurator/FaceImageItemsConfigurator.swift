//
//  FaceImageItemsConfigurator.swift
//  Depo
//
//  Created by Harbros on 30.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class FaceImageItemsConfigurator {
    
    func configure(viewController: FaceImageItemsViewController, remoteServices: RemoteItemsService, title: String, moduleOutput: LBAlbumLikePreviewSliderModuleInput? = nil) {
        let router = FaceImageItemsRouter()
        
        router.view = viewController
        
        let presenter = FaceImageItemsPresenter()
        if remoteServices is PeopleItemsService {
            presenter.faceImageType = .people
        } else if remoteServices is ThingsItemsService {
            presenter.faceImageType = .things
        } else if remoteServices is PlacesItemsService {
            presenter.faceImageType = .places
        }
        
        let alertSheetConfig = AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                   selectionModeTypes: [.createStory, .addToFavorites, .moveToTrash])
        
        let alertSheetModuleInitilizer = AlertFilesActionsSheetPresenterModuleInitialiser()
        let alertModulePresenter = alertSheetModuleInitilizer.createModule()
        presenter.alertSheetModule = alertModulePresenter
        alertModulePresenter.basePassingPresenter = presenter
        
        //presenter.topBarConfig = alertSheetConfig
        
        presenter.view = viewController
        presenter.router = router
        
        if let moduleOutput = moduleOutput {
            presenter.albumSliderModuleOutput = moduleOutput
        }
        
        let interactor = FaceImageItemsInteractor(remoteItems: remoteServices)
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
        
        viewController.mainTitle = title
    }
}
