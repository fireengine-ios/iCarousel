//
//  TabBarViewController.swift
//  Depo
//
//  Created by Aleksandr on 6/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import SDWebImage

enum FloatingButtonsType {
    case takePhoto
    case upload
    case createAStory
    case newFolder
    case createAlbum
    case uploadFromLifebox
    case uploadFromLifeboxFavorites
    case importFromSpotify
    case uploadFiles
}

enum TabScreenIndex: Int {
    case homePageScreenIndex = 0
    case photosScreenIndex = 1
    case contactsSyncScreenIndex = 3
    case documentsScreenIndex = 4
}

enum DocumentsScreenSegmentIndex: Int {
    case allFiles = 0
    case documents = 1
    case music = 2
    case favorites = 3
    case trashBin = 4
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
    
    static let notificationHidePlusTabBar = "HideMainTabBarPlusNotification"
    static let notificationShowPlusTabBar = "ShowMainTabBarPlusNotification"
    static let notificationHideTabBar = "HideMainTabBarNotification"
    static let notificationShowTabBar = "ShowMainTabBarNotification"
    static let notificationMusicDrop = "MusicDrop"
    static let notificationPhotosScreen = "PhotosScreenOn"
    static let notificationVideoScreen = "VideoScreenOn"
    static let notificationUpdateThreeDots = "UpdateThreeDots"
    
    fileprivate var photoBtn: SubPlussButtonView!
    fileprivate var importFromSpotifyBtn: SubPlussButtonView!
    fileprivate var uploadBtn: SubPlussButtonView!
    fileprivate var uploadFilesBtn: SubPlussButtonView!
    fileprivate var storyBtn: SubPlussButtonView!
    fileprivate var folderBtn: SubPlussButtonView!
    fileprivate var albumBtn: SubPlussButtonView!
    fileprivate var uploadFromLifebox: SubPlussButtonView!
    fileprivate var uploadFromLifeboxFavorites: SubPlussButtonView!
    fileprivate var importFromSpotify: SubPlussButtonView!
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var spotifyRoutingService: SpotifyRoutingService = factory.resolve()
    private lazy var externalFileUploadService = ExternalFileUploadService()
    
    
    //    let musicBar = MusicBar.initFromXib()
    lazy var player: MediaPlayer = factory.resolve()
    let cameraService: CameraService = CameraService()
    
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
    
    var lastPhotoVideoIndex = TabScreenIndex.photosScreenIndex.rawValue
    
    
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
    
    //MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.delegate = self
        
        setupTabBarItems()
        
        setupCurtainView()
        setupSubButtons()
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
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return activeNavigationController?.presentedViewController ?? activeNavigationController?.viewControllers.last
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return activeNavigationController?.presentedViewController ?? activeNavigationController?.viewControllers.last
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        player.delegates.remove(self)
    }
    
    private func setupTabBarItems() {
        tabBar.setupItems()
    }
    
    private func setupObserving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.hidePlusTabBar(_:)),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationHidePlusTabBar),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.showPlusTabBar(_:)),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.hideTabBar(_:)),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationHideTabBar),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.showTabBar(_:)),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationShowTabBar),
                                               object: nil)
        
        let dropNotificationName = NSNotification.Name(rawValue: TabBarViewController.notificationMusicDrop)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideMusicBar),
                                               name: dropNotificationName,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showPhotoScreen),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationPhotosScreen),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showVideosScreen),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationVideoScreen),
                                               object: nil)
    }
    
    func showAndScrollPhotosScreen(scrollTo item: Item? = nil) {
        tabBar.selectedItem = tabBar.items?[TabScreenIndex.photosScreenIndex.rawValue]
        selectedIndex = TabScreenIndex.photosScreenIndex.rawValue
        lastPhotoVideoIndex = TabScreenIndex.photosScreenIndex.rawValue
        
        if let item = item {
            scrollPhotoPage(scrollTo: item)
        }
    }
    
    @objc func showPhotoScreen() {
        tabBar.selectedItem = tabBar.items?[TabScreenIndex.photosScreenIndex.rawValue]
        selectedIndex = TabScreenIndex.photosScreenIndex.rawValue
        lastPhotoVideoIndex = TabScreenIndex.photosScreenIndex.rawValue
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
    
    @objc private func showPlusTabBar(_ sender: Any) {
        if (bottomTabBarConstraint.constant >= 0) {
            changeTabBarStatus(hidden: false)
        }
    }
    
    @objc private func hidePlusTabBar(_ sender: Any) {
        if (bottomTabBarConstraint.constant == 0) {
            changeTabBarStatus(hidden: true)
        }
    }
    
    @objc private func showTabBar(_ sender: Any) {
        changeTabBarStatus(hidden: false)
        if self.bottomTabBarConstraint.constant < 0 {
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
    
    @objc private func hideTabBar(_ sender: Any) {
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
        changeViewState(state: !plussButton.isSelected)
    }
    
    func setupCustomNavControllers() {
        let router = RouterVC()
        guard let syncContactsVC = router.syncContacts as? ContactSyncViewController else {
            assertionFailure()
            return
        }
        syncContactsVC.setTabBar(isVisible: true)
        
        let list = [router.homePageScreen,
                    router.segmentedMedia(),
                    syncContactsVC,
                    router.segmentedFiles]
        customNavigationControllers = list.compactMap { NavigationController(rootViewController: $0!) }
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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationUpdateThreeDots), object: nil)
        }
        
        curtainView.isHidden = !show
    }
    
    @objc func closeCurtainView() {
        changeViewState(state: false)
    }
    
    func setupSubButtons() {
        
        photoBtn = createSubButton(withText: TextConstants.takePhoto, imageName: "TakeFhoto", asLeft: true)
        photoBtn?.changeVisability(toHidden: true)
        
        uploadBtn = createSubButton(withText: TextConstants.upload, imageName: "Upload", asLeft: true)
        uploadBtn?.changeVisability(toHidden: true)
        
        uploadFilesBtn = createSubButton(withText: TextConstants.uploadFiles, imageName: "Upload", asLeft: true)
        uploadFilesBtn?.changeVisability(toHidden: true)
        
        storyBtn = createSubButton(withText: TextConstants.createStory, imageName: "CreateAStory", asLeft: false)
        storyBtn?.changeVisability(toHidden: true)
        
        folderBtn = createSubButton(withText: TextConstants.newFolder, imageName: "NewFolder", asLeft: false)
        folderBtn?.changeVisability(toHidden: true)
        
        uploadFromLifebox = createSubButton(withText: TextConstants.uploadFromLifebox, imageName: "Upload", asLeft: false)
        uploadFromLifebox?.changeVisability(toHidden: true)
        
        uploadFromLifeboxFavorites = createSubButton(withText: TextConstants.uploadFromLifebox, imageName: "Upload", asLeft: false)
        uploadFromLifeboxFavorites?.changeVisability(toHidden: true)
        
        albumBtn = createSubButton(withText: TextConstants.createAlbum, imageName: "NewFolder", asLeft: false)
        albumBtn?.changeVisability(toHidden: true)
        
        importFromSpotify = createSubButton(withText: TextConstants.importFromSpotifyBtn, imageName: "ImportFromSpotify", asLeft: true)
        importFromSpotify.changeVisability(toHidden: true)
        
        mainContentView.bringSubview(toFront: plussButton)
    }
    
    func createSubButton(withText text: String, imageName: String, asLeft: Bool) -> SubPlussButtonView? {
        if let subButton = SubPlussButtonView.getFromNib(asLeft: asLeft, withImageName: imageName, labelText: text) {
            subButton.actionDelegate = self
            view.addSubview(subButton)
            
            subButton.translatesAutoresizingMaskIntoConstraints = false
            
            subButton.bottomConstraint = NSLayoutConstraint(item: subButton, attribute: .bottom, relatedBy: .equal, toItem: mainContentView, attribute: .bottom, multiplier: 1, constant: 0)
            subButton.bottomConstraintOriginalConstant = -(UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
            
            subButton.centerXConstraint = NSLayoutConstraint(item: subButton, attribute: .centerX, relatedBy: .equal, toItem: mainContentView, attribute: .centerX, multiplier: 1, constant: 0)
            subButton.centerXConstraintOriginalConstant = 0
            
            var constraintsArray = [NSLayoutConstraint]()
            constraintsArray.append(subButton.bottomConstraint!)
            constraintsArray.append(subButton.centerXConstraint!)
            constraintsArray.append(NSLayoutConstraint(item: subButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80))
            constraintsArray.append(NSLayoutConstraint(item: subButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 65))
            NSLayoutConstraint.activate(constraintsArray)
            
            view.layoutIfNeeded()
            
            return subButton
        }
        
        return nil
    }
    
    private func getFloatingButtonsArray() -> [SubPlussButtonView] {
        let array = RouterVC().getFloatingButtonsArray()
        var buttonsArray = [SubPlussButtonView]()
        for type in array {
            switch type {
            case .createAlbum:
                buttonsArray.append(albumBtn)
            case .createAStory:
                buttonsArray.append(storyBtn)
            case .newFolder:
                buttonsArray.append(folderBtn)
            case .takePhoto:
                buttonsArray.append(photoBtn)
            case .upload:
                buttonsArray.append(uploadBtn)
            case .uploadFromLifebox:
                buttonsArray.append(uploadFromLifebox)
            case .uploadFromLifeboxFavorites:
                buttonsArray.append(uploadFromLifeboxFavorites)
            case .importFromSpotify:
                buttonsArray.append(importFromSpotify)
            case .uploadFiles:
                buttonsArray.append(uploadFilesBtn)
            }
        }
        
        if (buttonsArray.count == 0) || (buttonsArray.count > 4) {
            return [SubPlussButtonView]()
        }
        
        return buttonsArray
    }
    
    private func getAllFloatingButtonsArray() -> [SubPlussButtonView] {
        var buttonsArray = [SubPlussButtonView]()
        buttonsArray.append(albumBtn)
        buttonsArray.append(storyBtn)
        buttonsArray.append(folderBtn)
        buttonsArray.append(photoBtn)
        buttonsArray.append(uploadBtn)
        buttonsArray.append(uploadFilesBtn)
        buttonsArray.append(uploadFromLifebox)
        buttonsArray.append(uploadFromLifeboxFavorites)
        buttonsArray.append(importFromSpotify)
        return buttonsArray
    }
    
    private func showButtonRainbow() {
        
        let bottomOffset = tabBar.frame.size.height + 7 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        let radius: CGFloat = 100
        
        let buttonsArray = getFloatingButtonsArray()
        let count = buttonsArray.count
        
        let angles: [Double]
        switch count {
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
        
        buttonsArray.enumerated().forEach { index, button in
            let radians = angles[index] * Double.pi / 180
            button.centerXConstraint?.constant = radius * CGFloat(cos(radians))
            button.bottomConstraint?.constant = -(radius * CGFloat(sin(radians)) - button.frame.height * 0.5 + bottomOffset)
        }
        
        changeButtonsAppearance(toHidden: false, withAnimation: true, forButtons: buttonsArray)
        //view.layoutIfNeeded()
    }
    
    private func hideButtonRainbow() {
        let buttonsArray = getAllFloatingButtonsArray()
        changeButtonsAppearance(toHidden: true, withAnimation: true, forButtons: buttonsArray)
    }
    
    private func changeButtonsAppearance(toHidden hidden: Bool, withAnimation animate: Bool, forButtons buttons: [SubPlussButtonView]) {
        if buttons.count == 0 {
            return
        }
        
        UIView.animate(withDuration: NumericConstants.animationDuration, delay: 0.0, options: .showHideTransitionViews, animations: {
            for button in buttons {
                button.changeVisability(toHidden: hidden)
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
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
            
            if tabbarSelectedIndex == TabScreenIndex.photosScreenIndex.rawValue,
                lastPhotoVideoIndex == TabScreenIndex.photosScreenIndex.rawValue
            {
                tabbarSelectedIndex = lastPhotoVideoIndex
                tabBar.selectedItem = tabBar.items?[TabScreenIndex.photosScreenIndex.rawValue]
            } else {
                tabBar.selectedItem = tabBar.items?[tabbarSelectedIndex]
            }
            
            let arrayOfIndexesOfViewsThatShouldntBeRefreshed = [TabScreenIndex.homePageScreenIndex.rawValue,
                                                                TabScreenIndex.contactsSyncScreenIndex.rawValue - 1,
                                                                TabScreenIndex.documentsScreenIndex.rawValue - 1]
            
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

extension TabBarViewController: SubPlussButtonViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func buttonGotPressed(button: SubPlussButtonView) {
        changeViewState(state: false)
        let action: Action
        
        switch button {
        case photoBtn:
            action = .takePhoto
        case folderBtn:
            action = .createFolder
        case storyBtn:
            action = .createStory
        case uploadBtn:
            action = .upload
        case albumBtn:
            action = .createAlbum
        case uploadFromLifebox:
            action = .uploadFromApp
        case uploadFromLifeboxFavorites:
            action = .uploadFromAppFavorites
        case importFromSpotify:
            action = .importFromSpotify
        case uploadFilesBtn:
            action = .uploadFiles
        default:
            return
        }
        
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
    
    func getFolderUUID() -> String? {
        if let viewConroller = currentViewController as? BaseFilesGreedViewController {
            return viewConroller.getFolder()?.uuid
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
            
            let controller = router.createNewFolder(rootFolderID: folderUUID, isFavorites: isFavorites)
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
            
            externalFileUploadService.showViewController(router: router)
            
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
