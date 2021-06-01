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
    case allFiles = 0
    case documents = 2
    case music = 3
    case favorites = 4
    case trashBin = 5
}

final class TabBarViewController: ViewController, UITabBarDelegate {
    
    @IBOutlet weak var tabBar: CustomTabBar!
    
    @IBOutlet weak var plussButton: UIButton!
    
    @IBOutlet weak var curtainView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var mainContentView: UIView!
    
    @IBOutlet weak var plusButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var musicBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomTabBarConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var musicBar: MusicBar!
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var spotifyRoutingService: SpotifyRoutingService = factory.resolve()
    private lazy var externalFileUploadService = ExternalFileUploadService()
    private lazy var cameraService = CameraService()
    private lazy var player: MediaPlayer = factory.resolve()
    private lazy var router = RouterVC()
    
    private var plusMenuItems = [PlusMenuItemView]()
    
    let musicBarH : CGFloat = 70
    
    var customNavigationControllers: [UINavigationController] = []
    
    var selectedViewController: UIViewController? {
        if customNavigationControllers.count > 0 {
            return customNavigationControllers[selectedIndex]
        }
        return nil
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
            selectedViewController?.willMove(toParentViewController: nil)
            selectedViewController?.view.removeFromSuperview()
            selectedViewController?.removeFromParentViewController()
        }
        
        didSet {
            guard tabBar.items?.count != 0 else {
                return
            }
            addChildViewController(selectedViewController!)
            selectedViewController?.view.frame = contentView.bounds
            contentView.addSubview(selectedViewController!.view)
            selectedViewController?.didMove(toParentViewController: self)
            popToRootCurrentNavigationController(animated: true)
        }
    }
    
    var activeNavigationController: UINavigationController? {
        var  result: UINavigationController?
        if customNavigationControllers.count > 0 {
            result = customNavigationControllers[selectedIndex]
        }
        return result
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return activeNavigationController?.presentedViewController ?? activeNavigationController?.viewControllers.last
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return activeNavigationController?.presentedViewController ?? activeNavigationController?.viewControllers.last
    }
    
    //MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.delegate = self
        tabBar.setupItems()
        
        setupCurtainView()
        mainContentView.bringSubview(toFront: plussButton)
        setupCustomNavControllers()
        
        selectedIndex = 0
        tabBar.selectedItem = tabBar.items?.first
        
        changeVisibleStatus(hidden: true)
        setupObserving()
        
        player.delegates.add(self)
        
        plussButton.accessibilityLabel = TextConstants.accessibilityPlus
        
        #if LIFEDRIVE
        plussButton.imageEdgeInsets = UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15)
        #endif
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        player.delegates.remove(self)
    }
    
    private func setupTabBarItems() {
        tabBar.setupItems()
    }
    
    private func setupObserving() {
        NotificationCenter.default.addObserver(self, selector: #selector(hidePlusTabBar), name: .hidePlusTabBar, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPlusTabBar), name: .showPlusTabBar, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideTabBar), name: .hideTabBar, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showTabBar), name: .showTabBar, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideMusicBar), name: .musicDrop, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPhotoScreen), name: .photosScreen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showVideosScreen), name: .videoScreen, object: nil)
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
        openPhotoPage()
    }
    
    
    @objc func showVideosScreen(_ sender: Any) {
//        tabBar.selectedItem = tabBar.items?[TabScreenIndex.photosScreenIndex.rawValue]// beacase they share same tab
//        selectedIndex = TabScreenIndex.videosScreenIndex.rawValue
//        lastPhotoVideoIndex = TabScreenIndex.videosScreenIndex.rawValue
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
        
        musicBarHeightConstraint.constant = musicBarH
        mainContentView.layoutIfNeeded()
    }
    
    @objc func hideMusicBar(_ sender: Any) {
        changeVisibleStatus(hidden: true)
        musicBarHeightConstraint.constant = 0
        mainContentView.layoutIfNeeded()
    }
    
    func popToRootCurrentNavigationController(animated: Bool) {
        guard let navigationController = selectedViewController as? UINavigationController else {
            return
        }
        navigationController.popToRootViewController(animated: animated)
    }
    
    private func scrollPhotoPage(scrollTo item: Item) {
            if let photosController = openPhotoPage()?.currentController as? PhotoVideoController {
                photosController.scrollToItem(item)
            }
    }
    
    @discardableResult
    private func openPhotoPage() -> SegmentedController? {
        
        guard let segmentedController = activeNavigationController?.viewControllers.last as? SegmentedController else {
            return nil
        }
        
        segmentedController.loadViewIfNeeded()
        
        if (segmentedController.currentController as? PhotoVideoController)?.isPhoto == false {
            // if photo page is not active
            guard let index = segmentedController.viewControllers.firstIndex(where: { ($0 as? PhotoVideoController)?.isPhoto == true } ) else {
                assertionFailure("Photo page not found")
                return nil
            }
            segmentedController.switchSegment(to: index)
        }
        return segmentedController
        
    }
    
    private func changeVisibleStatus(hidden: Bool) {
        musicBar.isHidden = hidden
        musicBar.isUserInteractionEnabled = !hidden
    }
    
    @objc private func showPlusTabBar() {
        if (bottomTabBarConstraint.constant >= 0) {
            changeTabBarStatus(hidden: false)
        }
    }
    
    @objc private func hidePlusTabBar() {
        if (bottomTabBarConstraint.constant == 0) {
            changeTabBarStatus(hidden: true)
        }
    }
    
    @objc private func showTabBar() {
        changeTabBarStatus(hidden: false)
        if self.bottomTabBarConstraint.constant <= 0 {
            if !musicBar.isHidden {
                musicBar.alpha = 1
                musicBar.isUserInteractionEnabled = true
            }
            UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                self.bottomTabBarConstraint.constant = 0
                self.musicBarHeightConstraint.constant = self.musicBar.isHidden ? 0 : self.musicBarH
                debugLog("TabBarVC showTabBar about to layout")
                self.view.layoutIfNeeded()
                self.tabBar.isHidden = false
            }, completion: { _ in
                
            })
        }
    }
    
    @objc private func hideTabBar() {
        changeTabBarStatus(hidden: true)
        if bottomTabBarConstraint.constant >= 0 {
            let bottomConstraintConstant = -tabBar.frame.height - view.safeAreaInsets.bottom
            UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                self.bottomTabBarConstraint.constant = bottomConstraintConstant
                self.musicBarHeightConstraint.constant = 0
                debugLog("TabBarVC showTabBar about to layout")
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.tabBar.isHidden = true
            })
        }
    }
    
    func setBGColor(color: UIColor) {
        view.backgroundColor = color
    }
    
    private func changeTabBarStatus(hidden: Bool) {
        plussButton.isHidden = hidden
        plussButton.isEnabled = !hidden
    }
    
    func showRainbowIfNeed() {
        if !plussButton.isSelected {
            plussBtnAction(plussButton)
        }
    }
    
    @IBAction func plussBtnAction(_ sender: Any) {
        if !plussButton.isSelected {
            createPlusMenuItems()
        }
        
        guard !plusMenuItems.isEmpty else {
            SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.privateSharePlusButtonNoAction)
            return
        }
        
        changeViewState(state: !plussButton.isSelected)
    }
    
    func setupCustomNavControllers() {
        customNavigationControllers = TabBarConfigurator.generateControllers(router: router)
    }
    
    @objc func gearButtonAction(sender: Any) {
        // output.gearButtonGotPressed()
    }
    
    fileprivate func changeViewState(state: Bool) {
        plussButton.isSelected = state
        
        let rotationAngle: CGFloat = .pi / 4
        
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            if state {
                self.plussButton.transform = CGAffineTransform(rotationAngle: rotationAngle)
            } else {
                self.plussButton.transform = CGAffineTransform(rotationAngle: 0)
            }
        }
        
        showCurtainView(show: state)
        if state {
            showButtonRainbow()
        } else {
            hideButtonRainbow()
        }
        
        plussButton.accessibilityLabel = state ? TextConstants.accessibilityClose : TextConstants.accessibilityPlus
    }
    
    private func setupCurtainView() {
        curtainView.layer.masksToBounds = true
        
        curtainView.backgroundColor = ColorConstants.searchShadowColor.withAlphaComponent(0.85)
        showCurtainView(show: false)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(TabBarViewController.closeCurtainView))
        curtainView.addGestureRecognizer(tap)
    }
    
    private func showCurtainView(show: Bool) {
        guard var currentViewController = currentViewController else {
            return
        }
            
        if let searchController = currentViewController as? SearchViewController, let navigationViewController = searchController.navigationController {
            currentViewController = navigationViewController
            searchController.tabBarPlusMenu(isShown: show)
        } else {
            currentViewController.navigationItem.hidesBackButton = show
        }
        
        currentViewController.navigationItem.rightBarButtonItems?.forEach {
            $0.isEnabled = !show
        }
        
        if !show {
            NotificationCenter.default.post(name: .updateThreeDots, object: nil)
        }
        
        curtainView.isHidden = !show
    }
    
    @objc func closeCurtainView() {
        changeViewState(state: false)
    }
    
    private func createPlusMenuItems() {
        let types = router.getFloatingButtonsArray()
        plusMenuItems = types.map {
            let itemView = PlusMenuItemView.with(type: $0, delegate: self)
            itemView.add(to: mainContentView)
            return itemView
        }
        view.layoutIfNeeded()
    }
    
    private func showButtonRainbow() {
        let bottomOffset = tabBar.frame.size.height + 7 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        let radius: CGFloat = 100
        
        let angles: [Double]
        switch plusMenuItems.count {
        case 1:
            angles = [90]
        case 2:
            angles = [135, 45]
        case 3:
            angles = [150, 90, 30]
        case 4:
            angles = [165, 115, 65, 15]
        default:
            angles = []
        }
        
        plusMenuItems.enumerated().forEach { index, button in
            let radians = angles[index] * Double.pi / 180
            button.updatePosition(x: radius * CGFloat(cos(radians)),
                                  bottom: -(radius * CGFloat(sin(radians)) - button.frame.height * 0.5 + bottomOffset))
        }
        
        changeButtonsAppearance(toHidden: false, withAnimation: true)
    }
    
    private func hideButtonRainbow() {
        changeButtonsAppearance(toHidden: true, withAnimation: true)
    }
    
    private func changeButtonsAppearance(toHidden hidden: Bool, withAnimation animate: Bool) {
        UIView.animate(withDuration: NumericConstants.animationDuration, delay: 0.0, options: .showHideTransitionViews) {
            self.plusMenuItems.forEach { $0.changeVisability(toHidden: hidden) }
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.view.accessibilityElements = hidden ? nil : self.plusMenuItems + [self.plussButton]
        }
    }
    
    func frameForTabAtIndex(index: Int) -> CGRect {
        debugLog("TabBarVC frameForTabAtIndex about to layout")
        view.layoutIfNeeded()
        
        var frames = tabBar.subviews.flatMap { view -> CGRect? in
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
        changeViewState(state: false)
        
        if var tabbarSelectedIndex = (tabBar.items?.index(of: item)) {
            
            if tabbarSelectedIndex == TabScreenIndex.gallery.rawValue,
                lastPhotoVideoIndex == TabScreenIndex.gallery.rawValue
            {
                tabbarSelectedIndex = lastPhotoVideoIndex
                tabBar.selectedItem = tabBar.items?[TabScreenIndex.gallery.rawValue]
            } else {
                tabBar.selectedItem = tabBar.items?[tabbarSelectedIndex]
            }
            
            let arrayOfIndexesOfViewsThatShouldntBeRefreshed = [TabScreenIndex.home.rawValue,
                                                                TabScreenIndex.contactsSync.rawValue - 1,
                                                                TabScreenIndex.documents.rawValue - 1]
            
            if tabbarSelectedIndex > 2 {
                tabbarSelectedIndex -= 1
            }
            
            if tabbarSelectedIndex == selectedIndex && arrayOfIndexesOfViewsThatShouldntBeRefreshed.contains(tabbarSelectedIndex) {
                return
            }
            
//            if let tabScreenIndex = TabScreenIndex(rawValue: selectedIndex) {
//                log(for: tabScreenIndex)
//            }

            selectedIndex = tabbarSelectedIndex
            
            showCurtainView(show: false)
        }
    }
}

//MARK: - PlusMenuItemViewDelegate

extension TabBarViewController: PlusMenuItemViewDelegate {
    func selectPlusMenuItem(action: Action) {
        changeViewState(state: false)
        
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
