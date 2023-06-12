//
//  TabBarViewController.swift
//  Depo
//
//  Created by Aleksandr on 6/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import SDWebImage

enum DocumentsScreenSegmentIndex: Int {
    case documents = 0
    case music = 1
    case favorites = 2
    case share = 3
    case trashBin = 4
    case allFiles = 5
}

final class TabBarViewController: ViewController, UITabBarDelegate {
    
    @IBOutlet weak var tabBar: MainTabBar!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var bottomBarsContainerView: UIView! {
        willSet {
            newValue.clipsToBounds = false
        }
    }
    @IBOutlet weak var bottomBarsContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var musicBarHeightConstraint: NSLayoutConstraint! {
        willSet {
            newValue.constant = MusicBar.standardHeight
        }
    }
    @IBOutlet weak var musicBar: MusicBar!
    @IBOutlet weak var aboveTabBarCardStack: UIStackView!
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var spotifyRoutingService: SpotifyRoutingService = factory.resolve()
    private lazy var externalFileUploadService = ExternalFileUploadService()
    private lazy var cameraService = CameraService()
    private lazy var player: MediaPlayer = factory.resolve()
    private lazy var router = RouterVC()
    private let cardsContainerView = TabBarCardsContainer()

    var customNavigationControllers = TabBarConfigurator.generateControllers(router: RouterVC())

    var selectedViewController: UIViewController? {
        if customNavigationControllers.count > 0 {
            return customNavigationControllers[selectedIndex]
        }
        return nil
    }
    
    var topMostViewController: UIViewController? {
        tabBarController?.selectedViewController
    }
    
    var currentViewController: UIViewController? {
        if let navigationController = selectedViewController as? UINavigationController {
            return navigationController.viewControllers.last
        }
        return nil
    }
    
    var externalActionHandler: TabBarActionHandler? {
        if let actionHandlerContainer = currentViewController as? TabBarActionHandlerContainer {
            return actionHandlerContainer.tabBarActionHandler
        }
        return nil
    }
    
    var lastPhotoVideoIndex = TabScreenIndex.gallery.rawValue
    
    
    var selectedIndex: NSInteger = 0 {
        willSet {
            // will get crash
            selectedViewController?.willMove(toParent: nil)
            selectedViewController?.view.removeFromSuperview()
            selectedViewController?.removeFromParent()
        }
        
        didSet {
            guard tabBar.items?.count != 0 else {
                return
            }
            addChild(selectedViewController!)
            selectedViewController?.view.frame = contentView.bounds
            contentView.addSubview(selectedViewController!.view)
            selectedViewController?.didMove(toParent: self)
            popToRootCurrentNavigationController(animated: true)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var activeNavigationController: UINavigationController? {
        var  result: UINavigationController?
        if customNavigationControllers.count > 0 {
            result = customNavigationControllers[selectedIndex]
        }
        return result
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return activeNavigationController?.childForStatusBarStyle
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return activeNavigationController?.childForStatusBarHidden
    }
    
    //MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.delegate = self
        tabBar.setupItems()

        selectedIndex = 0
        tabBar.selectedItem = tabBar.items?.first

        changeVisibleStatus(hidden: true)
        setupObserving()

        player.delegates.add(self)

        setupCardsContainerView()

        for controller in customNavigationControllers {
            if let topViewController = controller.topViewController {
                adjustBottomSafeAreaInset(for: topViewController)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        player.delegates.remove(self)
    }
    
    private func setupTabBarItems() {
        tabBar.setupItems()
    }
    
    private func setupObserving() {
        NotificationCenter.default.addObserver(self, selector: #selector(hideMusicBar), name: .musicDrop, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPhotoScreen), name: .photosScreen, object: nil)
    }
    
    func showAndScrollPhotosScreen(scrollTo item: Item? = nil) {
        tabBar.selectedItem = tabBar.items?[TabScreenIndex.gallery.rawValue]
        selectedIndex = TabScreenIndex.gallery.rawValue
        lastPhotoVideoIndex = TabScreenIndex.gallery.rawValue
        
        if let item = item {
            scrollPhotoPage(scrollTo: item)
        }
    }
    
    @objc func showPhotoScreen() {
        tabBar.selectedItem = tabBar.items?[TabScreenIndex.gallery.rawValue]
        selectedIndex = TabScreenIndex.gallery.rawValue
        lastPhotoVideoIndex = TabScreenIndex.gallery.rawValue
    }

    @objc func showMusicBar(_ sender: Any) {
        if let segmentedController = customNavigationControllers[selectedIndex].viewControllers.first as? SegmentedController,
            segmentedController.currentController is TrashBinViewController {
            musicBar.status = .trashed
        } else {
            musicBar.status = .active
        }

        musicBar.configurateFromPLayer()
        changeVisibleStatus(hidden: false)

        musicBar.isHidden = false
    }
    
    @objc func hideMusicBar(_ sender: Any) {
        changeVisibleStatus(hidden: true)
        musicBar.isHidden = true
    }
    
    func popToRootCurrentNavigationController(animated: Bool) {
        guard let navigationController = selectedViewController as? UINavigationController else {
            return
        }
        navigationController.popToRootViewController(animated: animated)
    }
    
    private func scrollPhotoPage(scrollTo item: Item) {
        if let photosController = (RouterVC().tabBarController?.customNavigationControllers[TabScreenIndex.gallery.rawValue].viewControllers.first as? HeaderContainingViewController)?.childViewController as? PhotoVideoController {
            photosController.scrollToItem(item)
        }
    }
    
    private func changeVisibleStatus(hidden: Bool) {
        musicBar.isHidden = hidden
        musicBar.isUserInteractionEnabled = !hidden
    }
    
    func setBottomBarsHidden(_ isHidden: Bool, animated: Bool = true) {
        guard animated else {
            bottomBarsContainerView.isHidden = isHidden
            return
        }

        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.bottomBarsContainerView.isHidden = false
            self.bottomBarsContainerView.alpha = isHidden ? 0 : 1
        }) { _ in
            self.bottomBarsContainerView.isHidden = isHidden
            self.adjustBottomSafeAreaInsetForCurrentViewController()
        }
    }

    private func adjustBottomSafeAreaInsetForCurrentViewController() {
        if let activeNavigationController = activeNavigationController?.topViewController {
            adjustBottomSafeAreaInset(for: activeNavigationController)
        }
    }

    private func adjustBottomSafeAreaInset(for viewController: UIViewController) {
        let kContentBottomSpacing: CGFloat = 8
        let bottomBarsHeight = bottomBarsContainerView.isHidden ? 0 : bottomBarsContainerView.frame.height
        let inset = bottomBarsHeight + bottomBarsContainerBottomConstraint.constant + kContentBottomSpacing
        viewController.additionalSafeAreaInsets.bottom = inset
    }

    private func setupCardsContainerView() {
        
        /// Rearranged musicBar and Sync bar and put Sync under to musicBar
        aboveTabBarCardStack.insertArrangedSubview(cardsContainerView, at: 0)
        cardsContainerView.translatesAutoresizingMaskIntoConstraints = false
        cardsContainerView.bottomAnchor.constraint(equalTo: musicBar.topAnchor, constant: 15).isActive = true
        aboveTabBarCardStack.sendSubviewToBack(cardsContainerView)
        
        CardsManager.default.addViewForNotification(view: cardsContainerView)
    }
    
    func setBGColor(color: UIColor) {
        view.backgroundColor = color
    }
    
    func frameForTabAtIndex(index: Int) -> CGRect {
        debugLog("TabBarVC frameForTabAtIndex about to layout")
        view.layoutIfNeeded()
        
        var frames = tabBar.subviews.compactMap { view -> CGRect? in
            if let view = view as? UIControl {
                return view.frame
            }
            return nil
        }
        frames.sort { $0.origin.x < $1.origin.x }
        if frames.count > index {
            return frames[index]
        }
        return frames.last ?? CGRect.zero
    }
    
    // MARK: - tab bar delegate
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if var tabbarSelectedIndex = (tabBar.items?.firstIndex(of: item)) {
            
            ItemOperationManager.default.tabBarDidChange()

            if tabbarSelectedIndex == TabScreenIndex.gallery.rawValue,
                lastPhotoVideoIndex == TabScreenIndex.gallery.rawValue
            {
                tabbarSelectedIndex = lastPhotoVideoIndex
                tabBar.selectedItem = tabBar.items?[TabScreenIndex.gallery.rawValue]
            } else {
                tabBar.selectedItem = tabBar.items?[tabbarSelectedIndex]
            }

            let arrayOfIndexesOfViewsThatShouldntBeRefreshed = [TabScreenIndex.forYou.rawValue,
                                                                TabScreenIndex.contactsSync.rawValue,
                                                                TabScreenIndex.documents.rawValue]

            if tabbarSelectedIndex == selectedIndex && arrayOfIndexesOfViewsThatShouldntBeRefreshed.contains(tabbarSelectedIndex) {
                return
            }

            selectedIndex = tabbarSelectedIndex
        }
    }
}

//MARK: - PlusMenuItemViewDelegate

extension TabBarViewController: PlusMenuItemViewDelegate {
    func selectPlusMenuItem(action: Action) {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .plus, eventLabel: .plusAction(action))

        if let netmeraEvent = NetmeraEvents.Actions.PlusButton(action: action) {
            AnalyticsService.sendNetmeraEvent(event: netmeraEvent)
        }

        if let externalActionHandler = externalActionHandler, externalActionHandler.canHandleTabBarAction(action) {
            externalActionHandler.handleAction(action)
        } else {
            handleAction(action)
        }
    }
}

//MARK: - UIImagePickerControllerDelegate

extension TabBarViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) { [weak self] in
            self?.statusBarHidden = false
        }

        let isFromAlbum = RouterVC().isRootViewControllerAlbumDetail()
        cameraService.saveCapturedImage(info: info, isFromAlbum: isFromAlbum, folderUUID: getFolderUUID(), success: {}) { [weak self] error in
            guard !error.isOutOfSpaceError else {
                //showing special popup for this error
                return
            }

            DispatchQueue.main.async {
                let vc = PopUpController.with(title: TextConstants.errorAlert,
                                              message: error.description,
                                              image: .error,
                                              buttonTitle: TextConstants.ok)
                vc.open()
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
            self.statusBarHidden = false
        })
    }
}

extension TabBarViewController: MediaPlayerDelegate {
    func mediaPlayer(_ mediaPlayer: MediaPlayer, didStartItemWith duration: Float) {
        showMusicBar(())
    }
    func mediaPlayer(_ musicPlayer: MediaPlayer, changedCurrentTime time: Float) {}
    func didStartMediaPlayer(_ mediaPlayer: MediaPlayer) {}
    func didStopMediaPlayer(_ mediaPlayer: MediaPlayer) {}
}

import CoreServices
extension TabBarViewController: TabBarActionHandler {
    
    func canHandleTabBarAction(_ action: TabBarViewController.Action) -> Bool {
        return true
    }
    
    func handleAction(_ action: TabBarViewController.Action) {
        let router = RouterVC()
        
        switch action {
        case .takePhoto:
            guard !checkReadOnlyPermission() else { return }
            
            cameraService.showCamera(onViewController: self)
            
        case .createFolder:
            let isFavorites = router.isOnFavoritesView()
            var folderUUID = getFolderUUID()
            
            /// If the user is on the "Documents" screen, I pass folderUUID to avoid opening the default "AllFiles" screen.
            if folderUUID == nil, selectedIndex == 3 {
                folderUUID = ""
            }
            
            let controller: UIViewController
            if let sharedFolder = router.sharedFolderItem {
                let parameters = CreateFolderSharedWithMeParameters(projectId: sharedFolder.projectId, rootFolderUuid: sharedFolder.uuid)
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
            
        case .uploadDocumentsAndMusic:
            guard !checkReadOnlyPermission() else {
                return
            }
            
            externalFileUploadService.showViewController(router: router, externalFileType: .documentsandaudio)
            
        case .photopick:
            let photopick = router.analyzesHistoryController()
            router.pushViewController(viewController: photopick)
            
        case .createCollage:
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .plus, eventLabel: .createCollage)
            let createCollage = router.createCollage()
            router.pushViewController(viewController: createCollage)
                
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
            guard !checkReadOnlyPermission() else {
                return
            }
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
        case .createWord:
            let vc = OnlyOfficePopup.with(fileType: .createWord)
            vc.open()
        case .createExcel:
            let vc = OnlyOfficePopup.with(fileType: .createExcel)
            vc.open()
        case .createPowerPoint:
            let vc = OnlyOfficePopup.with(fileType: .createPowerPoint)
            vc.open()
        }
        
    }
    
    private func checkReadOnlyPermission() -> Bool {
        if let currentVC = currentViewController as? AlbumDetailViewController,
            let readOnly = currentVC.album?.readOnly, readOnly {
            UIApplication.showErrorAlert(message: TextConstants.uploadVideoToReadOnlyAlbumError)
            return true
        }
        return false
    }
}
