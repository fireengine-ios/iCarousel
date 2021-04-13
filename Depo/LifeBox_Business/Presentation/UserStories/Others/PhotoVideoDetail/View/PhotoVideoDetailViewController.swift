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
    
    var status: ItemStatus = .active
    var editingTabBar: BottomSelectionTabBarViewController!
    private var needToScrollAfterRotation = true
    
    var initinalBarStyle: NavigationBarStyles = .transparent
    
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
            
            if isFullScreen {
                editingTabBar.hideBar(animated: true)
            } else {
                editingTabBar.showBar(animated: true, onView: viewForBottomBar)
            }
            
            navigationController?.setNavigationBarHidden(isFullScreen, animated: true)
            setStatusBarHiddenForLandscapeIfNeed(isFullScreen)
            
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
    
    private var waitVideoPreviewURL = false
    
    private lazy var analytics = PrivateShareAnalytics()
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCollection()
        initialNavBarSetup()
        
        showSpinner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        OrientationManager.shared.lock(for: .all, rotateTo: .unknown)
        
        onStopPlay()
        
        setupNavigationBar()
        editingTabBar?.view.layoutIfNeeded()
        setupTitle()

        let isFullScreen = self.isFullScreen
        self.isFullScreen = isFullScreen
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setStatusBarHiddenForLandscapeIfNeed(isFullScreen)
        output.viewIsReady(view: viewForBottomBar)
        ItemOperationManager.default.startUpdateView(view: self)
        updateFirstVisibleCell()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        statusBarStyle = .default
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
    
    private func setupCollection() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(nibCell: PhotoVideoDetailCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isHidden = true
    }
    
    private func updateFirstVisibleCell() {
        guard let selectedIndex = selectedIndex else {
            return
        }
        
        let cells = collectionView.indexPathsForVisibleItems.compactMap({ collectionView.cellForItem(at: $0) as? PhotoVideoDetailCell })
        cells.first?.update(with: objects[selectedIndex], index: selectedIndex, isFullScreen: isFullScreen)
    }
    
    @objc func hideView() {
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
    
    private func initialNavBarSetup() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        changeLargeTitle(prefersLargeTitles: false, barStyle: .transparent)
        setNavigationBarStyle(initinalBarStyle)
        edgesForExtendedLayout = [.top, .bottom]
        extendedLayoutIncludesOpaqueBars = true
        setNavigationLeftBarButton(style: initinalBarStyle, title: "", target: self, image: UIImage(named: "blackBackButton"), action: #selector(hideView))
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
        guard let selectedItem = selectedItem else {
            return
        }
        let style: NavigationBarStyles
        
        if isFullScreen {
            style = .hidden
        } else {
            if case .application = selectedItem.fileType {
                style = .white
                statusBarStyle = .default
            } else {
                style = .transparent
                statusBarStyle = .lightContent
            }
        }
        setNavigationBarStyle(style)
        edgesForExtendedLayout = [.top, .bottom]
        extendedLayoutIncludesOpaqueBars = true
        navigationItem.leftBarButtonItem?.tintColor = style.textTintColor
//        if navigationItem.rightBarButtonItem == nil && !hideTreeDotButton {
//            navigationItem.rightBarButtonItem = threeDotsBarButtonItem
//        }

//        if let selectedItem = selectedItem {
//            //hide 3 dots button for shared or local items
//            navigationItem.rightBarButtonItem?.customView?.isHidden = selectedItem.isLocalItem || !selectedItem.isOwner
//        } else {
//            navigationItem.rightBarButtonItem?.customView?.isHidden = true
//        }
    }
    
    private func setupView() {
        switch initinalBarStyle {
        case .white:
            view.backgroundColor = ColorConstants.tableBackground
            statusBarStyle = .default
        default:
            break
        }
    }

    private func setupTitle() {
        guard let selectedItem = selectedItem else {
            return
        }
        let style: NavigationBarStyles
        if case .application = selectedItem.fileType {
            style = .white
        } else {
            style = .transparent
        }
        DispatchQueue.main.async {
            self.setNavigationTitle(title: selectedItem.name ?? "", style: style)
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
    
    private func updateAllItems(with items: [Item], updateCollection: Bool) {
        objects = items
        
        if updateCollection {
            collectionView.reloadData()
            scrollToSelectedIndex()
            collectionView.layoutIfNeeded()
        }
    }
}

extension PhotoVideoDetailViewController: PhotoVideoDetailViewInput {
    func showValidateNameSuccess(name: String) {
//        setNavigationTitle(title: name)
        self.title = name
    }
    
    func show(name: String) { }
    
    func setupInitialState() { }
    
    func onItemSelected(at index: Int, from items: [Item]) {
//        if items.isEmpty {
//            return
//        }
//
//        if let item = items[safe: index], item.isLocalItem && item.fileType == .image {
//            setThreeDotsMenu(active: false)
//        } else {
//            setThreeDotsMenu(active: true)
//        }
    }
    
    func play(item: AVPlayerItem) {
        hideSpinnerIncludeNavigationBar()
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.VideoDisplayed())
        
        guard let url = (item.asset as? AVURLAsset)?.url else {
            return
        }
        //TODO: player
        //
    }
    
    func onStopPlay() {
        //TODO: Player
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
    
    func updateItem(_ item: WrapData) {
        guard let index = objects.firstIndex(where: { $0 == item }) else {
            return
        }
        update(item: item, at: index)
    }
    
    private func update(item: Item, at index: Int) {
        objects[index] = item
        
        if let indexPath = collectionView.indexPathsForVisibleItems.first(where: { $0.row == index }),
           let cell = collectionView.cellForItem(at: indexPath) as? PhotoVideoDetailCell {
            cell.setup(with: item, index: index, isFullScreen: isFullScreen)
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
        
        let barStyle: BottomActionsBarStyle = object.fileType.isDocument ? .opaque : .transparent
        editingTabBar.changeBar(style: barStyle)
        
        if !object.fileType.isDocument, !isFullScreen {
            setNavigationBarStyle(.transparent)
        }
        
        viewForBottomBar.backgroundColor = object.fileType.isDocument ? .white : .clear
        
        cell.setup(with: object, index: indexPath.row, isFullScreen: isFullScreen)
        
        if indexPath.row == objects.count - 1 {
            output.willDisplayLastCell()
        }
        
        if !object.isOwner {
            analytics.sharedWithMe(action: .preview, on: object)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoVideoDetailCell else {
            return
        }
        
        cell.didEndDisplaying()
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
    func loadingFinished() {
        hideSpinner()
    }
    
    func tapOnCellForFullScreen() {
        isFullScreen.toggle()
    }
   
    func didExpireUrl(at index: Int, isFull: Bool) {
        if isFull {
            output.createNewUrl(at: index)
        } else {
            output.updateInfo(at: index)
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
