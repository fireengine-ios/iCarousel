//
//  BaseFilesGreedRouter.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BaseFilesGreedRouter: BaseFilesGreedRouterInput {

    lazy var player: MediaPlayer = factory.resolve()
    weak var view: BaseFilesGreedViewController!
    weak var presenter: BaseFilesGreedPresenter!
    private let router = RouterVC()

     func onItemSelected(selectedItem: BaseDataSourceItem, sameTypeItems: [BaseDataSourceItem], type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, moduleOutput: BaseFilesGreedModuleOutput?) {
        
        if (selectedItem.fileType == .photoAlbum) {
         
            return
        }
        if (selectedItem.fileType == .musicPlayList) {
            return
        }
        
        guard let wrapperedItem = selectedItem as? Item else {
            return
        }
        guard let wrapperedArray = sameTypeItems as? [Item] else {
            return
        }
        
        switch selectedItem.fileType {
        
        case .folder:
            let controller = router.filesFromFolder(folder: wrapperedItem,
                                                    type: type,
                                                    sortType: sortType,
                                                    status: .active,
                                                    moduleOutput: moduleOutput,
                                                    alertSheetExcludeTypes: presenter.alertSheetExcludeTypes)
            router.pushViewControllertoTableViewNavBar(viewController: controller)
        case .audio:
            player.play(list: wrapperedArray, startAt: wrapperedArray.index(of: wrapperedItem) ?? 0)
            
        case .application(.usdz):
            let controller = router.augumentRealityDetailViewController(fileObject: wrapperedItem)
            router.presentViewController(controller: controller)
            
        default:
            let controller = router.filesDetailViewController(fileObject: wrapperedItem, items: wrapperedArray)
            let nController = NavigationController(rootViewController: controller)
            router.presentViewController(controller: nController)
        }
    }
    
    func showPrint(items: [BaseDataSourceItem]) {
        guard let wrapperedArray = items as? [Item] else {
            return
        }

        let vc = PrintInitializer.viewController(data: wrapperedArray)
        router.pushViewController(viewController: vc)
    }
    
    func showBack() {
        view.dismiss(animated: true, completion: {})
    }
    
    func showSearchScreen(output: UIViewController?) {
        let controller = router.searchView(navigationController: output?.navigationController, output: output as? SearchModuleOutput)
        router.pushViewController(viewController: controller)
    }
    
    func showUpload() {
        let controller = router.uploadPhotos()
        let navigation = NavigationController(rootViewController: controller)
        navigation.navigationBar.isHidden = false
        router.presentViewController(controller: navigation)
    }
    
    func openNeededInstaPick(viewController: UIViewController) {
        let vc = router.createRootNavigationControllerWithModalStyle(controller: viewController)
        router.presentViewController(controller: vc)
    }
}
