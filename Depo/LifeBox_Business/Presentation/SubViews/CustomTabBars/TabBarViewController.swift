//
//  TabBarViewController.swift
//  Depo
//
//  Created by Aleksandr on 6/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import SDWebImage


//TODO: Use with MyDisk?
enum DocumentsScreenSegmentIndex: Int {
    case allFiles = 0
    case documents = 2
    case music = 3
    case favorites = 4
    case trashBin = 5
}

final class TabBarViewController: ViewController, UITabBarDelegate {
    
    @IBOutlet weak var tabBar: CustomTabBar!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var mainContentView: UIView!
    
    @IBOutlet weak var musicBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomTabBarConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var musicBar: MusicBar!
    
    @IBOutlet weak var uploadProgressView: UploadProgressView! {
        willSet {
            UploadProgressManager.shared.delegate = newValue
        }
    }
    @IBOutlet weak var uploadProgressViewHeightConstraint: NSLayoutConstraint!
    

    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var externalFileUploadService = ExternalFileUploadService()
    private lazy var galleryFileUploadService = GalleryFileUploadService()
    private lazy var cameraService = CameraService()
    private lazy var player: MediaPlayer = factory.resolve()
    private lazy var router = RouterVC()
    
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
        
        setupCustomNavControllers()
        
        selectedIndex = 0
        tabBar.selectedItem = tabBar.items?.first
        
        changeVisibleStatus(hidden: true)
        setupObserving()
        
        player.delegates.add(self)
        
        AnalyticsService.updateUser()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        player.delegates.remove(self)
    }
    
    private func setupTabBarItems() {
        tabBar.setupItems()
    }
    
    private func setupObserving() {
        NotificationCenter.default.addObserver(self, selector: #selector(hideTabBar), name: .hideTabBar, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showTabBar), name: .showTabBar, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideMusicBar), name: .musicDrop, object: nil)
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
    
    private func changeVisibleStatus(hidden: Bool) {
        musicBar.isHidden = hidden
        musicBar.isUserInteractionEnabled = !hidden
    }
    
    @objc private func showTabBar() {
        if self.bottomTabBarConstraint.constant <= 0 {
            if !musicBar.isHidden {
                musicBar.alpha = 1
                musicBar.isUserInteractionEnabled = true
            }
            UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                self.bottomTabBarConstraint.constant = 0
                self.musicBarHeightConstraint.constant = self.musicBar.isHidden ? 0 : self.musicBarH
                self.uploadProgressViewHeightConstraint.constant = self.uploadProgressView.isHidden ? 0 : UIScreen.main.bounds.size.height / 2
                debugLog("TabBarVC showTabBar about to layout")
                self.view.layoutIfNeeded()
                self.tabBar.isHidden = false
            }, completion: { _ in
                
            })
        }
    }
    
    @objc private func hideTabBar() {
        if bottomTabBarConstraint.constant >= 0 {
            let bottomConstraintConstant = -tabBar.frame.height - view.safeAreaInsets.bottom
            UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                self.bottomTabBarConstraint.constant = bottomConstraintConstant
                self.musicBarHeightConstraint.constant = 0
                self.uploadProgressViewHeightConstraint.constant = 0
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
    
    func setupCustomNavControllers() {
        customNavigationControllers = TabBarConfigurator.generateControllers(router: router)
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
        
        if let tabbarSelectedIndex = (tabBar.items?.index(of: item)) {
            let arrayOfIndexesOfViewsThatShouldntBeRefreshed = [TabScreenIndex.sharedFiles.rawValue]
            
            if tabbarSelectedIndex == selectedIndex && arrayOfIndexesOfViewsThatShouldntBeRefreshed.contains(tabbarSelectedIndex) {
                return
            }

            selectedIndex = tabbarSelectedIndex
        }
    }
    
    func folderUUID() -> String? {
        if let controller = currentViewController as? BaseFilesGreedViewController {
            return controller.getFolder()?.uuid
        }
        
        if let controller = currentViewController as? PrivateShareSharedFilesViewController,
           case let PrivateShareType.innerFolder(_, folder) = controller.shareType {
            return folder.uuid
        }
        
        return nil
    }

}

//MARK: - UIImagePickerControllerDelegate

extension TabBarViewController: GalleryFileUploadServiceDelegate {
    func uploaded(items: [WrapData]) {
        //
    }
    
    func failed(error: ErrorResponse?) {
        guard let error = error else {
            return
        }
        
        guard !error.isOutOfSpaceError else {
            //showing special popup for this error
            return
        }
        
        DispatchQueue.main.async {
            let vc = PopUpController.with(title: TextConstants.errorAlert,
                                          message: error.description,
                                          image: .error,
                                          buttonTitle: TextConstants.ok)
            self.present(vc, animated: true, completion: nil)
        }
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
            case .createFolder(type: _):
            let controller: UIViewController
            if let sharedFolder = router.sharedFolderItem {
                let isSharedByWithMe = sharedFolder.type.isContained(in: [.byMe, .withMe])
                let parameters = CreateFolderParameters(accountUuid: sharedFolder.accountUuid, rootFolderUuid: sharedFolder.uuid, isShared: isSharedByWithMe)
                controller = router.createNewFolder(parameters: parameters)
            } else {
                assertionFailure()
                return
            }
            
            let nController = NavigationController(rootViewController: controller)
            router.presentViewController(controller: nController)

        case .upload(type: let uploadType):
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .uploadFromPlus))
            galleryFileUploadService.upload(type:uploadType, rootViewController: self, delegate: self)
            
        case .uploadFiles(type: let uploadType):
            externalFileUploadService.showViewController(type: uploadType, router: router, externalFileType: .any)
                
        case .uploadFromApp:
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
        }
    }
}
