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

final class PhotoVideoDetailViewController: BaseViewController {
    
    var output: PhotoVideoDetailViewOutput!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var viewForBottomBar: UIView!
    @IBOutlet private weak var bottomBlackView: UIView!
    @IBOutlet private weak var swipeUpContainerView: UIView!
    
    var status: ItemStatus = .active
    var hideTreeDotButton = false
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
    
    private var selectedIndex: Int? {
        didSet {
            setupNavigationBar()
            setupTitle()
            
            if let index = selectedIndex {
                output.setSelectedItemIndex(selectedIndex: index)
            }
        }
    }
    
    private(set) var objects = [Item]()
    
    private var selectedItem: Item? {
        guard let index = selectedIndex else {
            return nil
        }
        return objects[safe: index]
    }
    
    private lazy var threeDotsBarButtonItem: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        button.setImage(UIImage(named: "more"), for: .normal)
        button.addTarget(self, action: #selector(onRightBarButtonItem(sender:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    private var waitVideoPreviewURL = false
    
    private lazy var analytics = PrivateShareAnalytics()
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.contentInsetAdjustmentBehavior = .never
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        collectionView.register(nibCell: PhotoVideoDetailCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isHidden = true
        
        navigationItem.leftBarButtonItem = BackButtonItem(action: hideView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
        showSpinner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        OrientationManager.shared.lock(for: .all, rotateTo: .unknown)
        ItemOperationManager.default.startUpdateView(view: self)
        
        onStopPlay()
        rootNavController(vizible: true)
        blackNavigationBarStyle()
        editingTabBar?.view.layoutIfNeeded()
        editingTabBar.view.backgroundColor = .black
        viewForBottomBar.backgroundColor = .black
        setupTitle()
        
        if hideTreeDotButton {
            navigationItem.rightBarButtonItem?.customView?.isHidden = true
        }
        
        // TODO: EditingBarConfig is not working
        editingTabBar.editingBar.barStyle = .blackOpaque
        editingTabBar.editingBar.clipsToBounds = true
        //editingTabBar.editingBar.layer.borderWidth = 0
        
        statusBarColor = .black
        
        NotificationCenter.default.post(name: .reusePlayer, object: self)
        
        let isFullScreen = self.isFullScreen
        self.isFullScreen = isFullScreen
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setStatusBarHiddenForLandscapeIfNeed(isFullScreen)
        output.viewIsReady(view: viewForBottomBar)
        updateFirstVisibleCell()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setNavigationBackgroundColor(color: UIColor.clear)
        
        visibleNavigationBarStyle()
        statusBarColor = .clear
        
        NotificationCenter.default.post(name: .deinitPlayer, object: self)
        
        output.viewWillDisappear()
        backButtonForNavigationItem(title: TextConstants.backTitle)
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
    
    private func updateFirstVisibleCell() {
        guard let selectedIndex = selectedIndex else {
            return
        }
        
        let cells = collectionView.indexPathsForVisibleItems.compactMap({ collectionView.cellForItem(at: $0) as? PhotoVideoDetailCell })
        cells.first?.setObject(object: objects[selectedIndex])
    }
    
    func hideView() {
        customDeinit()
        OrientationManager.shared.lock(for: .portrait, rotateTo: .portrait)
        
        /// need to check for PopUpController to dismiss it automaticaly for last photo in PhotoVideoDetail
        if let presentedViewController = presentedViewController as? BasePopUpController {
            presentedViewController.close { [weak self] in
                self?.dismiss(animated: true)
            }
        }  else {
            dismiss(animated: true)
        }
    }
        
    private func scrollToSelectedIndex() {
        setupNavigationBar()
        setupTitle()

        guard let index = selectedIndex else  {
            return
        }
        
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        collectionView.isHidden = false
    }
    
    func customDeinit() {
        ItemOperationManager.default.stopUpdateView(view: self)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavigationBar() {
        if navigationItem.rightBarButtonItem == nil && !hideTreeDotButton {
            navigationItem.rightBarButtonItem = threeDotsBarButtonItem
        }

        if let selectedItem = selectedItem {
            //hide 3 dots button for shared or local items
            navigationItem.rightBarButtonItem?.customView?.isHidden = selectedItem.isLocalItem || !selectedItem.isOwner
        } else {
            navigationItem.rightBarButtonItem?.customView?.isHidden = true
        }
    }

    private func setupTitle() {
        setNavigationTitle(title: selectedItem?.name ?? "")
    }
    
    func onShowSelectedItem(at index: Int, from items: [Item]) {
        //update collection on first launch or on change selectedItem
        let needUpdate: Bool
        if let selectedItem = selectedItem, selectedItem == items[safe: index] {
            needUpdate = false
        } else {
            needUpdate = true
        }
        
        if selectedIndex != index {
            selectedIndex = index
        }

        updateAllItems(with: items, updateCollection: needUpdate)
    }

    @objc func onRightBarButtonItem(sender: UIButton) {
        guard let index = selectedIndex else {
            return
        }
        
        output.moreButtonPressed(sender: sender, inAlbumState: false, object: objects[index], selectedIndex: index)
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
//        localPlayer?.pause()
    }
    
    private func updateAllItems(with items: [Item], updateCollection: Bool) {
        objects = items
        
        if updateCollection {
            collectionView.reloadData()
            scrollToSelectedIndex()
            collectionView.layoutIfNeeded()
        }
    }

    func shareCurrentItem() {
        guard let shareTabIndex = output.tabIndex(type: .share),
              let tabBarItem = editingTabBar.editingBar.items?[shareTabIndex] else {
            return
        }
        editingTabBar.tabBar(editingTabBar.editingBar, didSelect: tabBarItem)
    }
}

extension PhotoVideoDetailViewController: PhotoVideoDetailViewInput {
    func showValidateNameSuccess(name: String) {
        setNavigationTitle(title: name)
    }
    
    func show(name: String) { }
    
    func setupInitialState() { }
    
    func onItemSelected(at index: Int, from items: [Item]) {
        if items.isEmpty {
            return
        }
        
        if let item = items[safe: index], item.isLocalItem && item.fileType == .image {
            setThreeDotsMenu(active: false)
        } else {
            setThreeDotsMenu(active: true)
        }
    }
    
    func setThreeDotsMenu(active isActive: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isActive
    }
    
    func play(item: AVPlayerItem) {
        hideSpinnerIncludeNavigationBar()
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.VideoDisplayed())
        
        guard let url = (item.asset as? AVURLAsset)?.url else {
            return
        }
        
        //
    }
    
    func onStopPlay() {
        UIApplication.setIdleTimerDisabled(false)
        output.videoStoped()
        if Device.operationSystemVersionLessThen(11) {
            statusBarHidden = false
        }
    }
    
    func updateItems(objectsArray: [Item], selectedIndex: Int) {
        self.selectedIndex = selectedIndex
        updateAllItems(with: objectsArray, updateCollection: true)
    }
    
    func appendItems(_ items: [Item]) {
        let startIndex = objects.count
        objects.append(contentsOf: items)
        let endIndex = objects.count - 1
        
        let indexPaths = (startIndex...endIndex).map { IndexPath(item: $0, section: 0) }
        collectionView.insertItems(at: indexPaths)
    }
    
    func onLastRemoved() {
        selectedIndex = nil
        updateAllItems(with: [], updateCollection: true)
    }
    
    func getNavigationController() -> UINavigationController? {
        return navigationController
    }
    
    func updateExpiredItem(_ item: WrapData) {
        guard let indexToChange = objects.firstIndex(where: { !$0.isLocalItem && $0.getTrimmedLocalID() == item.getTrimmedLocalID() }),
              objects[indexToChange].hasExpiredPreviewUrl() else {
            return
        }
        update(item: item, at: indexToChange)
    }
    
    
    func updateItem(_ item: WrapData) {
        guard let index = objects.firstIndex(where: { $0 == item }) else {
            return
        }
        update(item: item, at: index)
    }
    
    private func update(item: Item, at index: Int) {
        objects[index] = item
        
        if let indexPath = collectionView.indexPathsForVisibleItems.first(where: { $0.item == index }),
           let cell = collectionView.cellForItem(at: indexPath) as? PhotoVideoDetailCell {
            cell.setObject(object: item)
        }
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
        DispatchQueue.main.async {
            self.replaceUploaded(file)
        }
    }
    
    func startUploadFile(file: WrapData) {
        output.updateBottomBar()
    }
    
    func failedUploadFile(file: WrapData, error: Error?) {
        output.updateBottomBar()
    }
    
    func cancelledUpload(file: WrapData) {
        output.updateBottomBar()
    }
    
    private func replaceUploaded(_ item: WrapData) {
        guard let indexToChange = objects.index(where: { $0.isLocalItem && $0.getTrimmedLocalID() == item.getTrimmedLocalID() }) else {
            return
        }
        
        //need for display local image
        item.patchToPreview = objects[indexToChange].patchToPreview
        objects[indexToChange] = item
        output.replaceUploaded(item)
        
        let visibleIndexes = collectionView.indexPathsForVisibleItems.map { $0.item }
        // update bars only for visible item
        if visibleIndexes.contains(indexToChange) {
            output.updateBars()
            setupNavigationBar()
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
        guard let cell = cell as? PhotoVideoDetailCell else {
            return
        }
        
        guard selectedIndex != nil else {
            return
        }
        
        cell.delegate = self
        let object = objects[indexPath.row]
        cell.setObject(object: object)
        
        if indexPath.row == objects.count - 1 {
            output.willDisplayLastCell()
        }
        
        if !object.isOwner {
            analytics.sharedWithMe(action: .preview, on: object)
        }
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
    
    func preparedMediaItem(completion: @escaping ValueHandler<AVURLAsset?>) {
       
    }
    
    func imageLoadingFinished() {
        hideSpinner()
    }
    
    func tapOnCellForFullScreen() {
        isFullScreen.toggle()
    }
    
//    private func prepareToPlayVideo(file: Item) {
//        let preUrl = file.metaData?.videoPreviewURL ?? file.urlToFile
//
//        if !waitVideoPreviewURL, preUrl == nil || preUrl?.isExpired == true {
//            waitVideoPreviewURL = true
//            output.createNewUrl()
//            return
//        }
//
//        guard let url = preUrl else {
//            hideSpinnerIncludeNavigationBar()
//            if !file.isOwner {
//                SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.privateSharePreviewNotReady)
//            }
//            return
//        }
//
//        switch file.patchToPreview {
//        case let .localMediaContent(local):
//            guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
//                return
//            }
//            let option = PHVideoRequestOptions()
//
//            output.startCreatingAVAsset()
//            debugLog("about to play local video item")
//            DispatchQueue.global(qos: .default).async { [weak self] in
//                PHImageManager.default().requestAVAsset(forVideo: local.asset, options: option) { [weak self] asset, _, _ in
//                    debugPrint("!!!! after local request")
//                    DispatchQueue.main.async {
//                        self?.output.stopCreatingAVAsset()
//                        guard let asset = asset else {
//                            return
//                        }
//                        let playerItem = AVPlayerItem(asset: asset)
//                        debugLog("playerItem created \(playerItem.asset.isPlayable)")
//                        self?.play(item: playerItem)
//                    }
//                }
//            }
//
//        case .remoteUrl(_):
//            debugLog("about to play remote video item")
//            DispatchQueue.global(qos: .default).async { [weak self] in
//                let playerItem = AVPlayerItem(url: url)
//                debugLog("playerItem created \(playerItem.asset.isPlayable)")
//                DispatchQueue.main.async {
//                    self?.play(item: playerItem)
//                }
//            }
//        }
//    }
    
    func didExpireUrl() {
        output.createNewUrl()
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
