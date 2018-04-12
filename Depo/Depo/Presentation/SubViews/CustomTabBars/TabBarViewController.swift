//
//  TabBarViewController.swift
//  Depo
//
//  Created by Aleksandr on 6/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

enum FloatingButtonsType: String {
    case floatingButtonTakeAPhoto = "Take a Photo"
    case floatingButtonUpload = "Upload"
    case floatingButtonCreateAStory = "Create a Story"
    case floatingButtonNewFolder = "New Folder"
    case floatingButtonCreateAlbum = "Create album"
    case floatingButtonUploadFromLifebox = "Upload from lifebox"
}

enum TabScreenIndex: Int {
    case homePageScreenIndex = 0
    case photosScreenIndex = 1
    case videosScreenIndex = 2
    case musicScreenIndex = 3
    case documentsScreenIndex = 4
}

final class TabBarViewController: ViewController, UITabBarDelegate {
    
    @IBOutlet weak var tabBar: CustomTabBar!
    
    @IBOutlet weak var plussButton: UIButton!
    
    var curtainView = UIView()
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var mainContentView: UIView!
    
    @IBOutlet weak var bottomBGView: UIView!
    
    @IBOutlet weak var statusBarBG: UIImageView!
    
    @IBOutlet weak var plusButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var musicBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomTabBarConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var musicBar: MusicBar!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    static let notificationHidePlusTabBar = "HideMainTabBarPlusNotification"
    static let notificationShowPlusTabBar = "ShowMainTabBarPlusNotification"
    static let notificationHideTabBar = "HideMainTabBarNotification"
    static let notificationShowTabBar = "ShowMainTabBarNotification"
    static let notificationMusicDrop = "MusicDrop"
    static let notificationPhotosScreen = "PhotosScreenOn"
    static let notificationVideoScreen = "VideoScreenOn"
    static let notificationFullScreenOn = "FullScreenOn"
    static let notificationFullScreenOff = "FullScreenOff"
    
    fileprivate var photoBtn: SubPlussButtonView!
    fileprivate var uploadBtn: SubPlussButtonView!
    fileprivate var storyBtn: SubPlussButtonView!
    fileprivate var folderBtn: SubPlussButtonView!
    fileprivate var albumBtn: SubPlussButtonView!
    fileprivate var uploadFromLifebox: SubPlussButtonView!

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
            if let navigationController = selectedViewController as? UINavigationController {
                navigationController.popToRootViewController(animated: true)
            }
        }
    }
    
    var activeNavigationController: UINavigationController? {
        var  result: UINavigationController?
        if customNavigationControllers.count > 0 {
            result = customNavigationControllers[selectedIndex]
        }
        return result
    }
    
    //MAKR: - View lifecycle
    
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
    }
       
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return activeNavigationController?.viewControllers.last ?? activeNavigationController?.presentedViewController
    }
    
    deinit {
        player.delegates.remove(self)
    }
    
    private func setupTabBarItems() {
        let items = [("outlineHome", "", TextConstants.accessibilityHome),
                     ("outlinePhotosVideos", "", TextConstants.accessibilityPhotosVideos),
                     ("", "", ""),
                     ("outlineMusic", "", TextConstants.accessibilityMusic),
                     ("outlineDocs", "", TextConstants.accessibilityDocuments)]
        
        tabBar.setupItems(withImageToTitleNames: items)
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
                                               selector: #selector(showPhotosScreen),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationPhotosScreen),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showVideosScreen),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationVideoScreen),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fullScreenOn),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationFullScreenOn),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fullScreenOff),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationFullScreenOff),
                                               object: nil)
        
    }
    
    @objc func showPhotosScreen(_ sender: Any) {
        tabBar.selectedItem = tabBar.items?[TabScreenIndex.photosScreenIndex.rawValue]
        selectedIndex = TabScreenIndex.photosScreenIndex.rawValue
        lastPhotoVideoIndex = TabScreenIndex.photosScreenIndex.rawValue
    }
    
    @objc func showVideosScreen(_ sender: Any) {
        tabBar.selectedItem = tabBar.items?[TabScreenIndex.photosScreenIndex.rawValue]// beacase they share same tab
        selectedIndex = TabScreenIndex.videosScreenIndex.rawValue
        lastPhotoVideoIndex = TabScreenIndex.videosScreenIndex.rawValue
    }
    
    @objc func showMusicBar(_ sender: Any) {
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
    
    @objc func fullScreenOn() {
        if topConstraint.constant >= 0 {
            topConstraint.constant = -statusBarBG.frame.size.height
            bottomConstraint.constant = bottomBGView.frame.size.height
            view.layoutSubviews()
        }
    }
    
    @objc func fullScreenOff() {
        if topConstraint.constant != 0 {
            topConstraint.constant = 0
            bottomConstraint.constant = 0
            view.layoutSubviews()
        }
    }
    
    @objc private func showTabBar(_ sender: Any) {
        changeTabBarStatus(hidden: false)
        if (self.bottomTabBarConstraint.constant < 0) {
            bottomBGView.isHidden = false
            if !musicBar.isHidden {
                musicBar.alpha = 1
                musicBar.isUserInteractionEnabled = true
            }
            UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                self.bottomTabBarConstraint.constant = 0
                self.musicBarHeightConstraint.constant = self.musicBar.isHidden ? 0 : self.musicBarH
                self.view.layoutIfNeeded()
                self.tabBar.isHidden = false
            }, completion: { _ in
                
            })
            
            
        }
    }
    
    @objc private func hideTabBar(_ sender: Any) {
        changeTabBarStatus(hidden: true)
        if (bottomTabBarConstraint.constant >= 0) {
            let bottomConstraintConstant = -self.tabBar.frame.height
            UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                self.bottomTabBarConstraint.constant = bottomConstraintConstant
                self.musicBarHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.tabBar.isHidden = true
                self.bottomBGView.isHidden = true
                
                if !self.musicBar.isHidden {
                    self.musicBar.alpha = 0
                    self.musicBar.isUserInteractionEnabled = false
                }
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
        let list = [router.homePageScreen,
                    router.photosScreen,
                    router.videosScreen,
                    router.musics,
                    router.documents]
        customNavigationControllers = list.compactMap { NavigationController(rootViewController: $0!) }
    }
    
    @objc func gearButtonAction(sender: Any) {
       // output.gearButtonGotPressed()
    }
    
    fileprivate func changeViewState(state: Bool) {
        plussButton.isSelected = state
        
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            if state {
                self.plussButton.transform = CGAffineTransform(rotationAngle: .pi / 4)
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
        
        curtainView.backgroundColor = ColorConstants.whiteColor
        curtainView.alpha = 0.88
        showCurtainView(show: false)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(TabBarViewController.closeCurtainView))
        curtainView.addGestureRecognizer(tap)
    }
    
    private func showCurtainView(show: Bool) {
        
        currentViewController?.navigationItem.rightBarButtonItems?.forEach {
            $0.isEnabled = !show
        }
        
        if show {
            curtainView.frame = CGRect(x: 0, y: 0, width: currentViewController?.view.frame.width ?? 0, height: currentViewController?.view.frame.height ?? 0)
            currentViewController?.view.addSubview(curtainView)
            currentViewController?.view.bringSubview(toFront: curtainView)
        } else {
            curtainView.removeFromSuperview()
        }
        
        
        if let searchController = currentViewController as? SearchViewController {
            searchController.setEnabledSearchBar(!show)
        } else {
            currentViewController?.navigationItem.hidesBackButton = show
        }
    }
    
    @objc func closeCurtainView() {
        changeViewState(state: false)
    }
    
    func setupSubButtons() {
        
        photoBtn = createSubButton(withText: TextConstants.takePhoto, imageName: "TakeFhoto", asLeft: true)
        photoBtn?.changeVisability(toHidden: true)
        
        uploadBtn = createSubButton(withText: TextConstants.upload, imageName: "Upload", asLeft: true)
        uploadBtn?.changeVisability(toHidden: true)
        
        storyBtn = createSubButton(withText: TextConstants.createStory, imageName: "CreateAStory", asLeft: false)
        storyBtn?.changeVisability(toHidden: true)
        
        folderBtn = createSubButton(withText: TextConstants.newFolder, imageName: "NewFolder", asLeft: false)
        folderBtn?.changeVisability(toHidden: true)
        
        uploadFromLifebox = createSubButton(withText: TextConstants.uploadFromLifebox, imageName: "NewFolder", asLeft: false)
        uploadFromLifebox?.changeVisability(toHidden: true)
        
        albumBtn = createSubButton(withText: TextConstants.createAlbum, imageName: "NewFolder", asLeft: false)
        albumBtn?.changeVisability(toHidden: true)
        
        mainContentView.bringSubview(toFront: plussButton)
    }

    func createSubButton(withText text: String, imageName: String, asLeft: Bool) -> SubPlussButtonView? {
        if let subButton = SubPlussButtonView.getFromNib(asLeft: asLeft, withImageName: imageName, labelText: text) {
            subButton.actionDelegate = self
            view.addSubview(subButton)
            
            subButton.translatesAutoresizingMaskIntoConstraints = false
            
            subButton.bottomConstraint = NSLayoutConstraint(item: subButton, attribute: .bottom, relatedBy: .equal, toItem: mainContentView, attribute: .bottom, multiplier: 1, constant: 0)
            subButton.bottomConstraintOrigialConstant = 0
            
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
            case .floatingButtonCreateAlbum:
                buttonsArray.append(albumBtn)
            case .floatingButtonCreateAStory:
                buttonsArray.append(storyBtn)
            case .floatingButtonNewFolder:
                buttonsArray.append(folderBtn)
            case .floatingButtonTakeAPhoto:
                buttonsArray.append(photoBtn)
            case .floatingButtonUpload:
                buttonsArray.append(uploadBtn)
            case .floatingButtonUploadFromLifebox:
                buttonsArray.append(uploadFromLifebox)
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
        buttonsArray.append(uploadFromLifebox)
        return buttonsArray
    }
    
    static let bottomSpace: CGFloat = 7
    static let spaceBeetwenbuttons: CGFloat = 3
    
    private func showButtonRainbow() {
        
        let buttonsArray = getFloatingButtonsArray()
        let count = buttonsArray.count
        
        if count == 1 {
            let obj0 = buttonsArray[0]
            obj0.centerXConstraint!.constant = 0
            obj0.bottomConstraint!.constant = -obj0.frame.size.height - tabBar.frame.size.height - TabBarViewController.bottomSpace
        }
        if count == 2 {
            let obj0 = buttonsArray[0]
            let obj1 = buttonsArray[1]
            
            obj0.centerXConstraint!.constant = -obj0.frame.size.width * 0.75
            obj0.bottomConstraint!.constant = -obj0.frame.size.height * 0.75 - tabBar.frame.size.height - TabBarViewController.bottomSpace - TabBarViewController.spaceBeetwenbuttons
            
            obj1.centerXConstraint!.constant = obj0.frame.size.width * 0.75
            obj1.bottomConstraint!.constant = -obj0.frame.size.height * 0.75 - tabBar.frame.size.height - TabBarViewController.bottomSpace - TabBarViewController.spaceBeetwenbuttons
        }
        if count == 3 {
            let obj0 = buttonsArray[0]
            let obj1 = buttonsArray[1]
            let obj2 = buttonsArray[2]
            
            obj0.centerXConstraint!.constant = -obj0.frame.size.width
            obj0.bottomConstraint!.constant = -tabBar.frame.size.height - TabBarViewController.bottomSpace
            
            obj1.centerXConstraint!.constant = 0
            obj1.bottomConstraint!.constant = -obj0.frame.size.height - tabBar.frame.size.height - TabBarViewController.bottomSpace - TabBarViewController.spaceBeetwenbuttons
            
            obj2.centerXConstraint!.constant = obj0.frame.size.width
            obj2.bottomConstraint!.constant = -tabBar.frame.size.height - TabBarViewController.bottomSpace
        }
        if count == 4 {
            let obj0 = buttonsArray[0]
            let obj1 = buttonsArray[1]
            let obj2 = buttonsArray[2]
            let obj3 = buttonsArray[3]
            
            obj0.centerXConstraint!.constant = -obj0.frame.size.width
            obj0.bottomConstraint!.constant = -tabBar.frame.size.height - TabBarViewController.bottomSpace
            
            obj1.centerXConstraint!.constant = -obj0.frame.size.width * 0.5
            obj1.bottomConstraint!.constant = -obj0.frame.size.height - tabBar.frame.size.height - TabBarViewController.bottomSpace - TabBarViewController.spaceBeetwenbuttons
            
            obj2.centerXConstraint!.constant = obj0.frame.size.width * 0.5
            obj2.bottomConstraint!.constant = -obj3.frame.size.height - tabBar.frame.size.height - TabBarViewController.bottomSpace - TabBarViewController.spaceBeetwenbuttons
            
            obj3.centerXConstraint!.constant = obj0.frame.size.width
            obj3.bottomConstraint!.constant = -tabBar.frame.size.height - TabBarViewController.bottomSpace
            
            
        }
        changeButtonsAppearance(toHidden: false, withAnimation: true, forButtons: buttonsArray)
        //view.layoutIfNeeded()
    }
    
    private func hideButtonRainbow() {
        let buttonsArray = getAllFloatingButtonsArray()
        changeButtonsAppearance(toHidden: true, withAnimation: true, forButtons: buttonsArray)
    }
    
    fileprivate func log(for index: TabScreenIndex) {
        switch index {
        case .photosScreenIndex:
            MenloworksAppEvents.onPhotosAndVideosOpen()
            let settings = AutoSyncDataStorage().getAutosyncSettings()
            MenloworksTagsService.shared.onAutosyncStatus(isOn: settings.isAutoSyncEnabled)
            
            if settings.isAutoSyncEnabled {
                MenloworksTagsService.shared.onAutosyncPhotosStatusOn(isWifi: !(settings.photoSetting.option == .wifiOnly))
                MenloworksTagsService.shared.onAutosyncVideosStatusOn(isWifi: !(settings.videoSetting.option == .wifiOnly))
            } else {
                MenloworksTagsService.shared.onAutosyncVideosStatusOff()
                MenloworksTagsService.shared.onAutosyncPhotosStatusOff()
            }
        case .musicScreenIndex:
            MenloworksAppEvents.onMusicOpen()
        case .documentsScreenIndex:
            MenloworksAppEvents.onDocumentsOpen()
        default:
            break
        }
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
    
    
    // MARK: - tab bar delegate
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        changeViewState(state: false)
        
        if var tabbarSelectedIndex = (tabBar.items?.index(of: item)) {
            
            if tabbarSelectedIndex == TabScreenIndex.photosScreenIndex.rawValue,
                (lastPhotoVideoIndex == TabScreenIndex.photosScreenIndex.rawValue ||
                lastPhotoVideoIndex == TabScreenIndex.videosScreenIndex.rawValue ) {
                tabbarSelectedIndex = lastPhotoVideoIndex
                tabBar.selectedItem = tabBar.items?[TabScreenIndex.photosScreenIndex.rawValue]
            } else {
                tabBar.selectedItem = tabBar.items?[tabbarSelectedIndex]
            }
            
            selectedIndex = tabbarSelectedIndex
            
            if let tabScreenIndex = TabScreenIndex(rawValue: selectedIndex) {
                log(for: tabScreenIndex)
            }
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
            action = .uploadFromLifeBox
        
        default:
            return
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
        
        let wrapData = WrapData(imageData: data)
        
        UploadService.default.uploadFileList(items: [wrapData], uploadType: .fromHomePage, uploadStategy: .WithoutConflictControl, uploadTo: .MOBILE_UPLOAD, folder: getFolderUUID() ?? "", isFavorites: false, isFromAlbum: false, isFromCamera: true, success: {
        }) { [weak self] error in
            DispatchQueue.main.async {
                let vc = PopUpController.with(title: TextConstants.errorAlert,
                                              message: error.description,
                                              image: .error,
                                              buttonTitle: TextConstants.ok)
                self?.present(vc, animated: true, completion: nil)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
            let controller = router.createNewFolder(rootFolderID: getFolderUUID(), isFavorites: isFavorites)
            let nController = NavigationController(rootViewController: controller)
            router.presentViewController(controller: nController)
            
        case .createStory:
            let isFavorites = router.isOnFavoritesView()
            router.createStoryName(items: nil, needSelectionItems: false, isFavorites: isFavorites)
            
        case .upload:
            guard !checkReadOnlyPermission() else { return }

            let controller = router.uploadPhotos()
            let navigation = NavigationController(rootViewController: controller)
            navigation.navigationBar.isHidden = false
            router.presentViewController(controller: navigation)
            
        case .createAlbum:
            let controller = router.createNewAlbum()
            let nController = NavigationController(rootViewController: controller)
            router.presentViewController(controller: nController)
            
        case .uploadFromLifeBox:
            guard !checkReadOnlyPermission() else { return }
            
            let parentFolder = router.getParentUUID()
            let controller: UIViewController
            if let currentVC = currentViewController as? BaseFilesGreedViewController {
                controller = router.uploadFromLifeBox(folderUUID: parentFolder, soorceUUID: "", sortRule: currentVC.getCurrentSortRule())
            } else {
                controller = router.uploadFromLifeBox(folderUUID: parentFolder)
            }
            let navigationController = NavigationController(rootViewController: controller)
            navigationController.navigationBar.isHidden = false
            router.presentViewController(controller: navigationController)
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
