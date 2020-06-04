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
    
    enum CardState {
        case expanded
        case collapsed
        case full
    }
    
    var output: PhotoVideoDetailViewOutput!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var viewForBottomBar: UIView!
    @IBOutlet private weak var bottomBlackView: UIView!
    @IBOutlet weak var collapseDetailView: UIView!
    
    @IBOutlet private weak var swipeUpContainerView: UIView!
    // Bottom detail view

    var bottomDetailView: FileInfoView? {
        willSet {
            newValue?.alpha = 0
        }
    }
    private var passThroughView: PassThroughView?
    private let cardHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    
    private lazy var imageMaxY = {
        return UIScreen.main.bounds.height - getImageMaxY()
    }()
    
    private var detailViewIsHidden = true {
        didSet {
            if detailViewIsHidden != oldValue {
                detailView(isHidden: detailViewIsHidden)
            }
        }
    }
    
    private var gestureBeginLocation: CGPoint = .zero
    private var dragViewBeginLocation: CGPoint = .zero
    private var isCardPresented = false
    var viewState: CardState = .collapsed
    private var nextState: CardState {
        return isCardPresented ? .collapsed : .expanded
    }
    
    private var runningAnimations = [UIViewPropertyAnimator]()
    private var animationProgressWhenInterrupted: CGFloat = 0
    

    private lazy var player: MediaPlayer = factory.resolve()
    
    private var localPlayer: AVPlayer?
    private var playerController: FixedAVPlayerViewController?
    
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
            if oldValue != selectedIndex {
                updateFileInfo()
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
        collapseViewSetup()
        showSpinner()
        updateFileInfo()
        output.getFIRStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBottomDetailsView()
        addTrackSwipeUpView()
        OrientationManager.shared.lock(for: .all, rotateTo: .unknown)
        ItemOperationManager.default.startUpdateView(view: self)
        
        onStopPlay()
        rootNavController(vizible: true)
        blackNavigationBarStyle()
        editingTabBar?.view.layoutIfNeeded()
        editingTabBar.view.backgroundColor = UIColor.black
        setupTitle()
        
        if hideTreeDotButton {
            navigationItem.rightBarButtonItem?.customView?.isHidden = true
        }
        
        // TODO: EditingBarConfig is not working
        editingTabBar.editingBar.barStyle = .blackOpaque
        editingTabBar.editingBar.clipsToBounds = true
        //editingTabBar.editingBar.layer.borderWidth = 0
        
        statusBarColor = .black

        let isFullScreen = self.isFullScreen
        self.isFullScreen = isFullScreen
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setStatusBarHiddenForLandscapeIfNeed(isFullScreen)
        output.viewIsReady(view: viewForBottomBar)
        passThroughView?.enableGestures()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setNavigationBackgroundColor(color: UIColor.clear)
        
        visibleNavigationBarStyle()
        statusBarColor = .clear
        
        output.viewWillDisappear()
        passThroughView?.disableGestures()
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
    
    private func collapseViewSetup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeDetailView))
        collapseDetailView.addGestureRecognizer(tap)
        collapseDetailView.isHidden = true
        collapseDetailView.layer.cornerRadius = 15
    }
        
    private func scrollToSelectedIndex() {
        setupNavigationBar()
        setupTitle()
        updateFileInfo()

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

        if status == .hidden {
            navigationItem.rightBarButtonItem?.customView?.isHidden = true
        } else if let selectedItem = selectedItem {
            navigationItem.rightBarButtonItem?.customView?.isHidden = selectedItem.isLocalItem
        } else {
            navigationItem.rightBarButtonItem?.customView?.isHidden = true
        }
    }

    private func setupTitle() {
        setNavigationTitle(title: selectedItem?.name ?? "")
    }
    
    private func updateFileInfo() {
        guard let selectedItem = selectedItem else { return }
        bottomDetailView?.setObject(selectedItem)
        output.getPersonsForSelectedPhoto()
    }
    
    func onShowSelectedItem(at index: Int, from items: [Item]) {
        //update collection on first launch or on change selectedItem
        let needUpdate: Bool
        if let selectedItem = selectedItem, selectedItem == items[safe: index] {
            needUpdate = false
        } else {
            needUpdate = true
        }
        selectedIndex = index
        updateAllItems(with: items, updateCollection: needUpdate)
    }

    @objc func onRightBarButtonItem(sender: UIButton) {
        guard let index = selectedIndex else {
            return
        }
        
        let stackCountViews = navigationController?.viewControllers.count ?? 0
        let inAlbumState = stackCountViews > 1 && navigationController?.viewControllers[stackCountViews - 2] is AlbumDetailViewController
        output.moreButtonPressed(sender: sender, inAlbumState: inAlbumState, object: objects[index], selectedIndex: index)
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
    
    @objc private func closeDetailView() {
        bottomDetailView?.hideKeyboard()
        viewState = .collapsed
        UIView.animate(withDuration: 1, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.9,
                       options: [.curveEaseInOut, .allowUserInteraction],
                       animations: {
                        self.collectionView.frame.origin.y = .zero
                        self.bottomDetailView?.frame.origin.y = self.view.frame.height
                        self.collapseDetailView.isHidden = true
                        self.isFullScreen = false
                        
        }, completion: { _ in
            self.detailViewIsHidden = self.needHideDetailView()
        })
    }
    
    func showDetailFromThreeDots() {
        UIView.animate(withDuration: 0.3, animations: {
            self.isFullScreen = true
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 0.3,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.9,
                           options: [.curveEaseInOut, .allowUserInteraction],
                           animations: {
                            self.viewState = .expanded
                            self.collectionView.frame.origin.y = self.view.frame.minY - (self.cardHeight - self.imageMaxY)
                            self.bottomDetailView?.frame.origin.y = self.collectionView.frame.maxY - self.imageMaxY
                            self.collapseDetailView.isHidden = false
                            self.detailViewIsHidden = false
            }, completion: nil)
        }
    }
    
    private func updateAllItems(with items: [Item], updateCollection: Bool) {
        objects = items
        
        if updateCollection {
            collectionView.reloadData()
            scrollToSelectedIndex()
            collectionView.layoutIfNeeded()
        }
    }
}


// MARK: Bottom detail view implemantation

extension PhotoVideoDetailViewController: PassThroughViewDelegate {
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        
        guard let bottomDetailView = bottomDetailView else {
            assertionFailure()
            return
        }
        
        switch recognizer.state {
        case .began:
            bottomDetailView.hideKeyboard()
            isFullScreen = true
            gestureBeginLocation = recognizer.location(in: view)
            dragViewBeginLocation = collectionView?.frame.origin ?? .zero
        case .changed:
            
            let newLocation = dragViewBeginLocation.y + (recognizer.location(in: view).y - gestureBeginLocation.y)
            collectionView.frame.origin.y = newLocation
            bottomDetailView.frame.origin.y = collectionView.frame.maxY - imageMaxY
            detailViewIsHidden = needHideDetailView()
    
        case .ended:
            UIView.animate(withDuration: 1, delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.9,
                           options: [.curveEaseOut, .allowUserInteraction],
                           animations: {
                            self.positionForView(velocityY: recognizer.velocity(in: self.bottomDetailView).y)
            }, completion: { _ in
                
                switch self.viewState {
                case .expanded:
                    self.detailViewIsHidden = false
                case .collapsed:
                    self.detailViewIsHidden = true
                case .full:
                    self.detailViewIsHidden = false
                }
            })
        default:
            break
        }
    }
    
    func positionForView(velocityY: CGFloat) {
        
        guard let bottomDetailView = bottomDetailView else {
            assertionFailure()
            return
        }
        
        if velocityY > 50,
            bottomDetailView.frame.origin.y > self.view.frame.height - cardHeight {
            viewState = .collapsed
            collectionView.frame.origin.y = .zero
            bottomDetailView.frame.origin.y = view.frame.height
            isFullScreen = false
            collapseDetailView.isHidden = true
            detailViewIsHidden = needHideDetailView()
        } else if velocityY < -50,
            bottomDetailView.frame.origin.y > view.frame.height - cardHeight, viewState != .expanded {
            viewState = .expanded
            collectionView.frame.origin.y = view.frame.minY - (cardHeight - imageMaxY)
            bottomDetailView.frame.origin.y = collectionView.frame.maxY - imageMaxY
            collapseDetailView.isHidden = false

        } else if bottomDetailView.frame.origin.y < view.frame.height - cardHeight {
            viewState = .full
            
            collectionView.frame.origin.y = -(view.frame.height - imageMaxY)
            bottomDetailView.frame.origin.y = view.frame.minY
            collapseDetailView.isHidden = false
            
        } else if bottomDetailView.frame.origin.y > view.frame.height {
            viewState = .collapsed
            bottomDetailView.frame.origin.y = view.frame.height
            collectionView.frame.origin.y = view.frame.minY
            
            isFullScreen = false
            collapseDetailView.isHidden = true
            
        } else {
            switch self.viewState {
            case .collapsed:
  
                collectionView.frame.origin.y = .zero
                bottomDetailView.frame.origin.y = view.frame.height
                isFullScreen = false
                collapseDetailView.isHidden = true
                detailViewIsHidden = needHideDetailView()
            case .expanded:

                collectionView.frame.origin.y = view.frame.minY - (cardHeight - imageMaxY)
                bottomDetailView.frame.origin.y = view.frame.height - cardHeight
                collapseDetailView.isHidden = false
                detailViewIsHidden = needHideDetailView()
            case .full:

                bottomDetailView.frame.origin.y = view.frame.height - cardHeight
                collectionView.frame.origin.y = bottomDetailView.frame.minY - collectionView.frame.height + imageMaxY
                detailViewIsHidden = needHideDetailView()
                collapseDetailView.isHidden = false
            }
        }
    }

    private func detailView(isHidden: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.bottomDetailView?.alpha = isHidden ? 0 : 1
        }
    }
    
    private func getImageMaxY() -> CGFloat {
        guard let cell = collectionView.cellForItem(at: IndexPath(row: selectedIndex ?? 0, section: 0)) as? PhotoVideoDetailCell else {
            assertionFailure()
            return .zero
        }
        return cell.imageViewMaxY()
    }
        
    func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        switch (recognizer.state, recognizer.direction) {
        case (.ended, .left):
            scrollLeft()
        case (.ended, .right):
            scrollRight()
        default:
            return
        }
    }
    
    private func scrollRight() {
        guard let index = selectedIndex else {
            return
        }
        let newIndex = index - 1
        scroll(to: newIndex)
    }
    
    private func scrollLeft() {
        guard let index = selectedIndex else {
            return
        }
        let newIndex = index + 1
        scroll(to: newIndex)
    }

    private func scroll(to index: Int) {
        guard 0..<objects.count ~= index else {
            return
        }
        
        let cell = collectionView.visibleCells.first as? PhotoVideoDetailCell
        let offsetY = -(cell?.frame.minY ?? 0 + imageMaxY)
        
        selectedIndex = index
        let newContentOffsetX = collectionView.bounds.size.width * CGFloat(index)
        let newContentOffset = CGPoint(x: newContentOffsetX, y: offsetY)

        collectionView.setContentOffset(newContentOffset, animated: true)
        collectionView.frame.origin.y = view.frame.minY - (cardHeight - imageMaxY)
        
        view.layoutIfNeeded()
    }
    
    private func addTrackSwipeUpView() {
        guard let topViewController = RouterVC().getViewControllerForPresent(), passThroughView == nil else {
            return
        }
        let view = PassThroughView(frame: topViewController.view.bounds)
        view.delegate = self
        topViewController.view.addSubview(view)
        passThroughView = view
    }
    
    private func addBottomDetailsView() {
        guard let topViewController = RouterVC().getViewControllerForPresent(), bottomDetailView == nil else {
            return
        }
        
        let fileInfoView = FileInfoView(frame: view.bounds)
        
        output.configureFileInfo(fileInfoView)
        topViewController.view.addSubview(fileInfoView)
        bottomDetailView = fileInfoView
    }
    
    private func needHideDetailView() -> Bool {
        guard let bottomDetailView = bottomDetailView else {
            assertionFailure()
            return false
        }
        return bottomDetailView.frame.minY >= view.frame.height * 0.75
    }
}

extension PhotoVideoDetailViewController: PhotoVideoDetailViewInput {
    func showValidateNameSuccess(name: String) {
        setNavigationTitle(title: name)
        bottomDetailView?.showValidateNameSuccess()
    }
    
    func show(name: String) {
        bottomDetailView?.show(name: name)
    }
    
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
        
        localPlayer?.replaceCurrentItem(with: item)
        playerController = FixedAVPlayerViewController()
        playerController?.player = localPlayer
        ///needs to expend from everywhere
        playerController?.delegate = RouterVC().rootViewController as? TabBarViewController
        debugLog("about to play video item with isEmptyController \(playerController == nil) and \(playerController?.player == nil)")
        present(playerController!, animated: true) { [weak self] in
            UIApplication.setIdleTimerDisabled(true)
            self?.playerController?.player?.play()
            self?.output.videoStarted()
            if Device.operationSystemVersionLessThen(11) {
                self?.statusBarHidden = true
            }
        }
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
    
    func updatePeople(items: [PeopleOnPhotoItemResponse]) {
        bottomDetailView?.reloadCollection(with: items)
    }
    
    func setHiddenPeoplePlaceholder(isHidden: Bool) {
        bottomDetailView?.setHiddenPeoplePlaceholder(isHidden: isHidden)
    }
    
    func setHiddenPremiumStackView(isHidden: Bool) {
        bottomDetailView?.setHiddenPremiumStackView(isHidden: isHidden)
    }
    
    func closeDetailViewIfNeeded() {
        closeDetailView()
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
        cell.setObject(object: objects[indexPath.row])
        
        if indexPath.row == objects.count - 1 {
            output.willDisplayLastCell()
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
    
    func imageLoadingFinished() {
       hideSpinner()
    }
    
    func tapOnCellForFullScreen() {
        isFullScreen.toggle()
    }
    
    func tapOnSelectedItem() {
        guard let index = selectedIndex else {
            return
        }
        
        showSpinnerIncludeNavigationBar()
        let file = objects[index]
        if file.fileType == .video {
            self.prepareToPlayVideo(file: file)
        }
    }
    
    private func prepareToPlayVideo(file: Item) {
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
                    debugPrint("!!!! after local request")
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
            DispatchQueue.global(qos: .default).async { [weak self] in
                let playerItem = AVPlayerItem(url: url)
                debugLog("playerItem created \(playerItem.asset.isPlayable)")
                DispatchQueue.main.async {
                    self?.play(item: playerItem)
                }
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

