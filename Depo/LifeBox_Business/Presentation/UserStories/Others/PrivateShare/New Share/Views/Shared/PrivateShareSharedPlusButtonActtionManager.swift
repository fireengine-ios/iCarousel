//
//  PrivateShareSharedPlusButtonActtionManager.swift
//  Depo
//
//  Created by Alex Developer on 23.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

final class PrivateShareSharedPlusButtonActtionManager {
    
    private lazy var cameraService = CameraService()
//    private lazy var player: MediaPlayer = factory.resolve()
    private lazy var router = RouterVC()
    
    private lazy var alertPresenter: AlertFilesActionsSheetPresenter = {
        let alert = AlertFilesActionsSheetPresenterModuleInitialiser().createModule()
        alert.basePassingPresenter = delegate
        return alert
    }()
    
    private weak var delegate: BaseItemInputPassingProtocol!
    
    init(delegate: BaseItemInputPassingProtocol) {
        self.delegate = delegate
    }
    
    func showActions(for privateShareTypes: [FloatingButtonsType], sender: Any?) {
        //in case if it's  ios14 action shall be handled by UIMenu, that was settuped in PrivateShareSharedFilesViewController
        guard Device.operationSystemVersionLessThen(14) else {
            return
        }
        alertPresenter.showSubPlusSheet(with: privateShareTypes, sender: sender, viewController: delegate as? ViewController)
        
//        let types = innerFolderActionTypes(for: privateShareType.rootType, item:  item)
//        alert.show(with: types, for: [item], presentedBy: sender, onSourceView: nil, viewController: nil)
    }
    
//    func handleAction(type: ActionType, item: Item, sender: Any?) {
//        switch type {
//        case .elementType(let elementType):
//            alert.handleAction(type: elementType, items: [item], sender: sender)
//        case .shareType(let shareType):
//            alert.handleShare(type: shareType, items: [item], sender: sender)
//        }
//    }
    
    @available(iOS 13.0, *)
    func generateMenu(for subPlusButtonTypes: [FloatingButtonsType]) -> UIMenu {
        
        let relatedActions = generateActions(for: subPlusButtonTypes)
        
        return UIMenu(title: "",
                      identifier: UIMenu.Identifier(rawValue: "PlusButton"),
                      options: .displayInline,
                      children: relatedActions)
    }
    
    @available(iOS 13.0, *)
    func generateActions(for subPlusButtonTypes: [FloatingButtonsType]) -> [UIAction] {
        return subPlusButtonTypes.map { type in
            return UIAction(title: type.title,
                            image: type.image,
                            attributes: []) { _  in
                self.handleAction(for: type)
            }
        }
    }
    
    //used by UIMenu as of now
    ///it handles actuall logic of actions insted of main controller
    func handleAction(for type: FloatingButtonsType) {
        handleGeneralAction(type.action)
    }
    
    
//    enum Action {
//        case createFolder(type: UploadType)
//        case upload(type: UploadType)
//        case uploadFromApp
//        case uploadFiles(type: UploadType)
//    }
    
    
    func handleGeneralAction(_ action: TabBarViewController.Action) {
//        let router = RouterVC()
        
        switch action {
        case .createFolder:
            let isFavorites = router.isOnFavoritesView()
            var folderUUID = getFolderUUID()
            
            /// If the user is on the "Documents" screen, I pass folderUUID to avoid opening the default "AllFiles" screen.
//            if folderUUID == nil, selectedIndex == 3 {
//                folderUUID = ""
//            }
            
            let controller: UIViewController
            if let sharedFolder = router.sharedFolderItem {
                let parameters = CreateFolderSharedWithMeParameters(projectId: sharedFolder.accountUuid, rootFolderUuid: sharedFolder.uuid)
                controller = router.createNewFolderSharedWithMe(parameters: parameters)
            } else {
                controller = router.createNewFolder(rootFolderID: folderUUID, isFavorites: isFavorites)
            }
            
            let nController = NavigationController(rootViewController: controller)
            router.presentViewController(controller: nController)
            
        case .createStory:
            //            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .story, eventLabel: .crateStory(.click)) //FE-55
            let controller = router.createStory(navTitle: TextConstants.createStory)
            router.pushViewController(viewController: controller)
            
        case .upload:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .uploadFromPlus))
            
            guard !checkReadOnlyPermission() else {
                return
            }
            
            let controller = router.uploadPhotos()
            let navigation = NavigationController(rootViewController: controller)
            navigation.navigationBar.isHidden = false
            router.presentViewController(controller: navigation)
            
        case .uploadFiles:
            guard !checkReadOnlyPermission() else {
                return
            }
            
            externalFileUploadService.showViewController(router: router, externalFileType: .any)
            
        case .uploadDocuments:
            guard !checkReadOnlyPermission() else {
                return
            }
            
            externalFileUploadService.showViewController(router: router, externalFileType: .documents)
            
        case .uploadMusic:
            guard !checkReadOnlyPermission() else {
                return
            }
            
            externalFileUploadService.showViewController(router: router, externalFileType: .audio)
            
        case .createAlbum:
            let controller = router.createNewAlbum()
            let nController = NavigationController(rootViewController: controller)
            router.presentViewController(controller: nController)
            
        case .uploadFromApp:
            guard !checkReadOnlyPermission() else {
                return
            }
            let parentFolder = router.getParentUUID()
            
            let controller: UIViewController
            if let currentVC = currentViewController as? BaseFilesGreedViewController {
                controller = router.uploadFromLifeBox(folderUUID: parentFolder,
                                                      soorceUUID: "",
                                                      sortRule: currentVC.getCurrentSortRule(),
                                                      type: .List)
            } else {
                controller = router.uploadFromLifeBox(folderUUID: parentFolder)
            }
            
            let navigationController = NavigationController(rootViewController: controller)
            navigationController.navigationBar.isHidden = false
            router.presentViewController(controller: navigationController)
            
        case .uploadFromAppFavorites:
            //            guard !checkReadOnlyPermission() else {
            //                return
            //            }
            let parentFolder = router.getParentUUID()
            
            let controller: UIViewController
            if let currentVC = currentViewController as? BaseFilesGreedViewController {
                controller = router.uploadFromLifeBoxFavorites(folderUUID: parentFolder, soorceUUID: "", sortRule: currentVC.getCurrentSortRule(), isPhotoVideoOnly: true)
            } else {
                controller = router.uploadFromLifeBoxFavorites(folderUUID: parentFolder, isPhotoVideoOnly: true)
            }
            
            let navigationController = NavigationController(rootViewController: controller)
            navigationController.navigationBar.isHidden = false
            router.presentViewController(controller: navigationController)
        case .importFromSpotify:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .spotifyImport))
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .plus, eventLabel: .importSpotify)
            spotifyRoutingService.connectToSpotify(isSettingCell: false, completion: nil)
        }
    }
}

extension PrivateShareSharedPlusButtonActtionManager {
    
    private func checkReadOnlyPermission() -> Bool {
        if let currentVC = router.currentContrroller() as? AlbumDetailViewController,
            let readOnly = currentVC.album?.readOnly, readOnly {
            UIApplication.showErrorAlert(message: TextConstants.uploadVideoToReadOnlyAlbumError)
            return true
        }
        return false
    }
    
    
    
}

extension PrivateShareSharedPlusButtonActtionManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func getFolderUUID() -> String? {
        if let controller = currentViewController as? BaseFilesGreedViewController {
            return controller.getFolder()?.uuid
        }
        
        if let controller = currentViewController as? PrivateShareSharedFilesViewController,
           case let PrivateShareType.innerFolder(_, folder) = controller.shareType {
            return folder.uuid
        }
        
        return nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let data = UIImageJPEGRepresentation(image.imageWithFixedOrientation, 0.9)
            else { return }
        
        let url = URL(string: UUID().uuidString, relativeTo: RouteRequests.baseUrl)
        SDWebImageManager.shared().saveImage(toCache: image, for: url)
        
        let wrapData = WrapData(imageData: data, isLocal: true)
        /// usedUIImageJPEGRepresentation
        if let wrapDataName = wrapData.name {
            wrapData.name = wrapDataName + ".JPG"
        }
        
        wrapData.patchToPreview = PathForItem.remoteUrl(url)
        
        let isFromAlbum = RouterVC().isRootViewControllerAlbumDetail()
        
        picker.dismiss(animated: true, completion: { [weak self] in
            self?.statusBarHidden = false
            
            UploadService.default.uploadFileList(items: [wrapData], uploadType: .upload, uploadStategy: .WithoutConflictControl, uploadTo: .MOBILE_UPLOAD, folder: self?.getFolderUUID() ?? "", isFavorites: false, isFromAlbum: isFromAlbum, isFromCamera: true, success: {
            }, fail: { [weak self] error in
                guard !error.isOutOfSpaceError else {
                    //showing special popup for this error
                    return
                }
                
                DispatchQueue.main.async {
                    let vc = PopUpController.with(title: TextConstants.errorAlert,
                                                  message: error.description,
                                                  image: .error,
                                                  buttonTitle: TextConstants.ok)
                    self?.present(vc, animated: true, completion: nil)
                }
            }, returnedUploadOperation: { _ in })
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
            self.statusBarHidden = false
        })
    }
}

struct CreateFolderSharedWithMeParameters {// is it  valid for business?
    let projectId: String
    let rootFolderUuid: String?
}
