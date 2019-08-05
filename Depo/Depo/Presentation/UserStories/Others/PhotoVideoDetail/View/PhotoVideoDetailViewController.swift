//
//  PhotoVideoDetailPhotoVideoDetailViewController.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos

final class PhotoVideoDetailViewController: BaseViewController {
    var output: PhotoVideoDetailViewOutput!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var viewForBottomBar: UIView!
    
    @IBOutlet private weak var bottomBlackView: UIView!
    
    private lazy var player: MediaPlayer = factory.resolve()
    
    private var localPlayer: AVPlayer?
    private var playerController: FixedAVPlayerViewController?
    
    var hideActions = false
    var editingTabBar: BottomSelectionTabBarViewController!
    private var needToScrollAfterRotation = true
    
    private var isFullScreen = false {
        didSet {
            ///  ANIMATION
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { 
//                UIApplication.shared.isStatusBarHidden = self.isFullScreen
//            }
//            navigationController?.setNavigationBarHidden(self.isFullScreen, animated: true)
//            
//            if isFullScreen {
//                UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
//                    self.editingTabBar.view.transform = CGAffineTransform(translationX: 0, y: self.editingTabBar.view.bounds.height)
//                }, completion: {_ in
//                    self.editingTabBar.view.isHidden = self.isFullScreen
//                })
//                
//            } else {      
//                editingTabBar.view.isHidden = self.isFullScreen
//                UIView.animate(withDuration: NumericConstants.animationDuration) { 
//                    self.editingTabBar.view.transform = .identity
//                }
//            }
            
            /// without animation

            editingTabBar.view.isHidden = isFullScreen
            navigationController?.setNavigationBarHidden(isFullScreen, animated: false)
            setStatusBarHiddenForLandscapeIfNeed(isFullScreen)
            
            bottomBlackView.isHidden = self.isFullScreen
            viewForBottomBar.isUserInteractionEnabled = !self.isFullScreen
        }
    }
    
    private var selectedIndex = 0 {
        didSet {
            guard !objects.isEmpty, selectedIndex < objects.count else {
                return
            }
            setupNavigationBar()
            setupTitle()
            output.setSelectedItemIndex(selectedIndex: selectedIndex)
        }
    }
    
    private(set) var objects = [Item]() {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
        }
    }
    
    private lazy var threeDotsBarButtonItem: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        button.setImage(#imageLiteral(resourceName: "more"), for: .normal)
        button.addTarget(self, action: #selector(onRightBarButtonItem(sender:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        collectionView.register(nibCell: PhotoVideoDetailCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isHidden = true
        
        navigationItem.leftBarButtonItem = BackButtonItem { [weak self] in
            self?.hideView()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        OrientationManager.shared.lock(for: .all, rotateTo: .unknown)
        ItemOperationManager.default.startUpdateView(view: self)
        
        onStopPlay()
        rootNavController(vizible: true)
        blackNavigationBarStyle()
        editingTabBar?.view.layoutIfNeeded()
        editingTabBar.view.backgroundColor = UIColor.black
        setupTitle()
        
        if hideActions {
            editingTabBar.view.isHidden = true
        }
        
        
        statusBarColor = .black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setStatusBarHiddenForLandscapeIfNeed(isFullScreen)
        output.viewIsReady(view: viewForBottomBar)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setNavigationBackgroundColor(color: UIColor.clear)
        
        visibleNavigationBarStyle()
        statusBarColor = .clear
        
        output.viewWillDisappear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.performBatchUpdates(nil, completion: { [weak self] _ in
            guard let `self` = self else {
                return
            }
            if self.needToScrollAfterRotation {
                self.needToScrollAfterRotation = false
                self.scrollToSelectedIndex()
            }
        })
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .black
    }
    
    func hideView() {
        customDeinit()
        OrientationManager.shared.lock(for: .portrait, rotateTo: .portrait)
        
        /// need to check for PopUpController to dismiss it automaticaly for last photo in PhotoVideoDetail
        if let presentedViewController = presentedViewController as? PopUpController {
            presentedViewController.close { [weak self] in
                self?.dismiss(animated: true)
            }
        }  else {
            dismiss(animated: true)
        }
    }
    
    private func scrollToSelectedIndex() {
        guard !objects.isEmpty, selectedIndex < objects.count else {
            return
        }
        let indexPath = IndexPath(item: selectedIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        self.collectionView.isHidden = false
    } 
    
    /// FIXME: temp logic of deinit. ItemOperationManager holds "self" strong
    func customDeinit() {
        ItemOperationManager.default.stopUpdateView(view: self)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavigationBar() {
        if navigationItem.rightBarButtonItem == nil {
            navigationItem.rightBarButtonItem = threeDotsBarButtonItem
        }

        if hideActions {
            navigationItem.rightBarButtonItem?.customView?.isHidden = true
        } else {
            guard !objects.isEmpty, selectedIndex < objects.count else {
                return
            }
            let item = objects[selectedIndex]
            navigationItem.rightBarButtonItem?.customView?.isHidden = item.isLocalItem
        }
    }

    private func setupTitle() {
        guard !objects.isEmpty, selectedIndex < objects.count else {
            return
        }
        if let name = objects[selectedIndex].name {
            setNavigationTitle(title: name)
        }
    }
    
    func onShowSelectedItem(at index: Int, from items: [Item]) {
        objects = items
        selectedIndex = index
        
        collectionView.reloadData()
        collectionView.performBatchUpdates(nil) { [weak self] _ in
            self?.scrollToSelectedIndex()
        }
    }

    @objc func onRightBarButtonItem(sender: UIButton) {
        let stackCountViews = navigationController?.viewControllers.count ?? 0
        let inAlbumState = stackCountViews > 1 && navigationController?.viewControllers[stackCountViews - 2] is AlbumDetailViewController
        output.moreButtonPressed(sender: sender, inAlbumState: inAlbumState, object: objects[selectedIndex], selectedIndex: selectedIndex)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        needToScrollAfterRotation = true
        setStatusBarHiddenForLandscapeIfNeed(isFullScreen)
        collectionView.reloadData()
    }
    
    override func getBackgroundColor() -> UIColor {
        return UIColor.black
    }
    
    @objc private func applicationDidEnterBackground(_ application: UIApplication) {
        localPlayer?.pause()
    }
}

extension PhotoVideoDetailViewController: PhotoVideoDetailViewInput {
    
    func setupInitialState() { }
    
    func onItemSelected(at index: Int, from items: [Item]) {
        if items.isEmpty {
            return
        }
        
        let item = items[index]
        if item.isLocalItem && item.fileType == .image {
            setThreeDotsMenu(active: false)
        } else {
            setThreeDotsMenu(active: true)
        }
    }
    
    func setThreeDotsMenu(active isActive: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isActive
    }
    
    func play(item: AVPlayerItem) {
        MenloworksTagsService.shared.onVideoDisplayed()
        
        localPlayer?.replaceCurrentItem(with: item)
        playerController = FixedAVPlayerViewController()
        playerController?.player = localPlayer
        ///needs to expend from everywhere
        playerController?.delegate = RouterVC().rootViewController as? TabBarViewController
        debugLog("about to play video item with isEmptyController \(playerController == nil) and \(playerController?.player == nil)")
        present(playerController!, animated: true) { [weak self] in
            self?.playerController?.player?.play()
            self?.output.videoStarted()
            if Device.operationSystemVersionLessThen(11) {
                self?.statusBarHidden = true
            }
        }
    }
    
    func onStopPlay() {
        output.videoStoped()
        if Device.operationSystemVersionLessThen(11) {
            statusBarHidden = false
        }
    }
    
    func updateItems(objectsArray: [Item], selectedIndex: Int, isRightSwipe: Bool) {
        self.objects = objectsArray
        self.selectedIndex = selectedIndex
    }
    
    func getNavigationController() -> UINavigationController? {
        return navigationController
    }
}

extension PhotoVideoDetailViewController: ItemOperationManagerViewProtocol {
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        if let compairedView = object as? PhotoVideoDetailViewController {
            return compairedView == self
        }
        return false
    }
    
    func finishedUploadFile(file: WrapData) {
        DispatchQueue.toMain { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.replaceUploaded(file)
            self.output.replaceUploaded(file)
            self.output.updateBars()
            self.setupNavigationBar()
        }
    }
    
    private func replaceUploaded(_ item: WrapData) {
        if let indexToChange = objects.index(where: { $0.isLocalItem && $0.getTrimmedLocalID() == item.getTrimmedLocalID() }) {
            //need for display local image
            item.patchToPreview = objects[indexToChange].patchToPreview
            objects[indexToChange] = item
        }
    }
}

extension PhotoVideoDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: PhotoVideoDetailCell.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoVideoDetailCell else { return }
        cell.delegate = self
        cell.setObject(object: objects[indexPath.row])
    }
}

extension PhotoVideoDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = collectionView.frame.height
        let cellWidth = collectionView.frame.width
        ///https://github.com/wordpress-mobile/WordPress-iOS/issues/10354
        ///seems like this bug may occur on iOS 12+ when it returns negative value
        return CGSize(width: max(cellWidth, 0), height: max(cellHeight, 0))
    }
}

extension PhotoVideoDetailViewController: PhotoVideoDetailCellDelegate {
    func tapOnCellForFullScreen() {
        isFullScreen.toggle()
    }
    
    func tapOnSelectedItem() {
        let file = objects[selectedIndex]
        
        if file.fileType == .video {
            let preUrl = file.metaData?.videoPreviewURL ?? file.urlToFile
            guard let url = preUrl else {
                return
            }
            
            player.pause()
            playerController?.player = nil
            playerController?.removeFromParentViewController()
            playerController = nil
            localPlayer?.pause()
            localPlayer = nil
            localPlayer = AVPlayer()
            
            switch file.patchToPreview {
            case let .localMediaContent(local):
                guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
                    return 
                }
                let option = PHVideoRequestOptions()
                
                output.startCreatingAVAsset()
                debugLog("about to play local video item")
                DispatchQueue.global(qos: .default).async { [weak self] in
                    PHImageManager.default().requestAVAsset(forVideo: local.asset, options: option) { [weak self] asset, _, _ in
                        
                        DispatchQueue.main.async {
                            self?.output.stopCreatingAVAsset()
                            guard let asset = asset else {
                                return
                            }
                            let playerItem = AVPlayerItem(asset: asset)
                            debugLog("playerItem created \(playerItem.asset.isPlayable)")
                            self?.play(item: playerItem)
                        }   
                    }
                }
                
            case .remoteUrl(_):
                debugLog("about to play remote video item")
                let playerItem = AVPlayerItem(url: url)
                debugLog("playerItem created \(playerItem.asset.isPlayable)")
                play(item: playerItem)
            }
        }
    }
    
}

extension PhotoVideoDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectedIndex()
    }
    
    // MARK: - Helper
    
    private func updateSelectedIndex() {
        let x = collectionView.contentOffset.x
        let w = collectionView.bounds.size.width
        var currentPage = Int(ceil(x / w))
        
        if currentPage >= objects.count {
            currentPage = objects.count - 1
        }
        selectedIndex = currentPage
    }
}

///extension of different class( Need to expand picture-in-picture everywhere)
extension TabBarViewController: AVPlayerViewControllerDelegate {

    func playerViewController(_ playerViewController: AVPlayerViewController,
                              restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        RouterVC().presentViewController(controller: playerViewController) {
            playerViewController.allowsPictureInPicturePlayback = true
            completionHandler(true)
        }
    }
}
