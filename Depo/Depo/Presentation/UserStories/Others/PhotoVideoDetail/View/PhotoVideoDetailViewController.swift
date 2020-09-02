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
    @IBOutlet weak var collapseDetailView: UIView!
    
    @IBOutlet private weak var swipeUpContainerView: UIView!
    // Bottom detail view
    
    private(set) var bottomDetailViewManager: BottomDetailViewAnimationManagerProtocol?

    var bottomDetailView: FileInfoView?
    private var passThroughView: PassThroughView?

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
    
    deinit {
        NotificationCenter.default.post(name: .deinitPlayer, object: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.contentInsetAdjustmentBehavior = .never
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        collectionView.register(nibCell: PhotoDetailCell.self)
        collectionView.register(nibCell: VideoPlayerCell.self)
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
        
        addTrackSwipeUpView()
        addBottomDetailsView()
        
        OrientationManager.shared.lock(for: .all, rotateTo: .unknown)
        ItemOperationManager.default.startUpdateView(view: self)
        
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
        bottomDetailViewManager?.updatePassThroughViewDelegate(passThroughView: passThroughView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setStatusBarHiddenForLandscapeIfNeed(isFullScreen)
        output.viewIsReady(view: viewForBottomBar)
        passThroughView?.enableGestures()
        updateFirstVisibleCell()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setNavigationBackgroundColor(color: UIColor.clear)
        
        visibleNavigationBarStyle()
        statusBarColor = .clear
        
        output.viewWillDisappear()
        passThroughView?.disableGestures()
        backButtonForNavigationItem(title: TextConstants.backTitle)
        passThroughView?.removeFromSuperview()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideDetailViewIfChangedRotation()
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
    
    private func hideDetailViewIfChangedRotation() {
        if UIDevice.current.orientation.isLandscape {
            bottomDetailViewManager?.closeDetailView()
        }
    }
    
    private func updateFirstVisibleCell() {
        guard let selectedIndex = selectedIndex else {
            return
        }
        
        let cells = collectionView.indexPathsForVisibleItems.compactMap({ collectionView.cellForItem(at: $0) as? CellConfigurable })
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
        output.getFIRStatus { [weak self] in
            self?.updateFileInfo()
        }

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
        bottomDetailView?.setObject(selectedItem) {
            self.output.getPersonsForSelectedPhoto(completion: nil)
        }
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
    
    private func updateAllItems(with items: [Item], updateCollection: Bool) {
        objects = items
        
        if updateCollection {
            collectionView.reloadData()
            scrollToSelectedIndex()
            collectionView.layoutIfNeeded()
        }
    }
    
    private func setupBottomDetailViewManager() {
        guard
            let managedView = bottomDetailView,
            let passThroughView = passThroughView,
            let collectionView = collectionView,
            let collapsedView = collapseDetailView,
            let parentView = view
        else {
            assertionFailure()
            return
        }
        bottomDetailViewManager = BottomDetailViewAnimationManager(managedView: managedView, passThrowView: passThroughView, collectionView: collectionView, collapseView: collapsedView, parentView: parentView, delegate: self)
    }
    
    func getBottomDetailViewState() -> CardState {
        guard let bottomDetailViewManager = bottomDetailViewManager else {
            assertionFailure()
            return .collapsed
        }
        return bottomDetailViewManager.getCurrenState()
    }
    
    func showBottomDetailView() {
        bottomDetailViewManager?.showDetailView()
    }
}


// MARK: Bottom detail view implemantation

extension PhotoVideoDetailViewController: BottomDetailViewAnimationManagerDelegate {
    
    func getSelectedIindex() -> Int {
        return selectedIndex ?? 0
    }
    
    func getObjectsCount() -> Int {
        return objects.count
    }
    
    func getIsFullScreenState() -> Bool {
        return isFullScreen
    }
    
    func setIsFullScreenState(_ isFullScreen: Bool) {
        self.isFullScreen = isFullScreen
    }
    
    func setSelectedIndex(_ selectedIndex: Int) {
        self.selectedIndex = selectedIndex
    }
    
    private func addTrackSwipeUpView() {
        
        let window = UIApplication.shared.keyWindow
        let view = PassThroughView(frame: UIScreen.main.bounds)
        window?.addSubview(view)
        passThroughView = view
    }
    
    private func addBottomDetailsView() {
        guard let topViewController = RouterVC().getViewControllerForPresent(), bottomDetailView == nil else {
            return
        }
        
        let fileInfoView = FileInfoView(frame: CGRect(origin: CGPoint(x: .zero, y: view.frame.height), size: view.frame.size))
        output.configureFileInfo(fileInfoView)
        topViewController.view.addSubview(fileInfoView)
        bottomDetailView = fileInfoView
        setupBottomDetailViewManager()
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
        bottomDetailViewManager?.closeDetailView()
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
            updateFileInfo()
        }
    }
}

//MARK: - CollectionView Delegate
extension PhotoVideoDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        objects[indexPath.item].fileType == .video
            ? collectionView.dequeue(cell: VideoPlayerCell.self, for: indexPath)
            : collectionView.dequeue(cell: PhotoDetailCell.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CellConfigurable else {
            return
        }
        guard selectedIndex != nil else {
            return
        }
        cell.responder = self
        cell.setObject(object: objects[indexPath.row])
        
        if indexPath.row == objects.count - 1 {
            output.willDisplayLastCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? VideoPlayerCell)?.didEndDisplaying()
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

//MARK: - PhotoVideoCellDelegate
extension PhotoVideoDetailViewController: PhotoVideoDetailCellDelegate {
    func imageLoadingFinished() {
        hideSpinner()
    }
    
    func tapOnCellForFullScreen() {
        isFullScreen.toggle()
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
