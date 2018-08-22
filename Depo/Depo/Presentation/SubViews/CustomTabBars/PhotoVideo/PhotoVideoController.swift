//
//  PhotoVideoController.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

// TODO: items storage with remotes

// TODO: CheckBoxViewDelegate logic
// TODO: video controller
// TODO: navigation bar appear (we have "setTitle("")" )
// TODO: items operations (progress)
// TODO: todos in file
// TODO: clear code -

final class PhotoVideoController: BaseViewController, NibInit, SegmentedChildController {

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = dataSource
            collectionView.delegate = self
        }
    }
    
    private lazy var navBarManager = PhotoVideoNavBarManager(delegate: self)
    private lazy var collectionViewManager = PhotoVideoCollectionViewManager(collectionView: self.collectionView)
    private lazy var threeDotMenuManager = PhotoVideoThreeDotMenuManager(delegate: self)
    private lazy var bottomBarManager = PhotoVideoBottomBarManager(delegate: self)
    private lazy var dataSource = PhotoVideoDataSource(collectionView: self.collectionView)
    
    private let analyticsManager: AnalyticsService = factory.resolve()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomBarManager.setup()
        collectionViewManager.setup()
        navBarManager.setDefaultMode()
        
        needShowTabBar = true
        floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto,
                                                 .floatingButtonUpload,
                                                 .floatingButtonCreateAStory,
                                                 .floatingButtonCreateAlbum])
        
        performFetch()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateCellSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCellSize()
        // TODO: need layoutIfNeeded?
        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
        collectionViewManager.scrolliblePopUpView.isActive = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        collectionViewManager.scrolliblePopUpView.isActive = false
    }

    
    // MARK: - setup
    
    private func performFetch() {
        dataSource.performFetch()
        collectionView.reloadData()
        collectionViewManager.reloadAlbumsSlider()
    }
    
    private func updateCellSize() {
        let columnsNumber = 4
        _ = collectionView.saveAndGetItemSize(for: columnsNumber)
    }
    
    // MARK: - Editing Mode
    
    private func startEditingMode(at indexPath: IndexPath?) {
        guard !dataSource.isSelectingMode else {
            return
        }
        dataSource.isSelectingMode = true
        if let indexPath = indexPath {
            dataSource.selectedIndexPaths.insert(indexPath)
        }
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        onChangeSelectedItemsCount(selectedItemsCount: dataSource.selectedIndexPaths.count)
        navBarManager.setSelectionMode()
    }
    
    private func stopEditingMode() {
        dataSource.isSelectingMode = false
        dataSource.selectedIndexPaths.removeAll()
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        bottomBarManager.hide()
        navBarManager.setDefaultMode()
    }
    
    // MARK: - helpers
    
    private func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        bottomBarManager.update(for: dataSource.selectedObjects)
        
        if selectedItemsCount == 0 {
            navBarManager.threeDotsButton.isEnabled = false
            bottomBarManager.hide()
        } else {
            navBarManager.threeDotsButton.isEnabled = true
            bottomBarManager.show()
        }
        
        setTitle("\(selectedItemsCount) \(TextConstants.accessibilitySelected)")
    }
    
    private func showDetail(at indexPath: IndexPath) {
        // TODO: trackClickOnPhotoOrVideo(isPhoto: false)
        trackClickOnPhotoOrVideo(isPhoto: true)
        
        let currentMediaItem = dataSource.object(at: indexPath)
        let currentObject = WrapData(mediaItem: currentMediaItem)
        
        let router = RouterVC()
        let controller = router.filesDetailViewController(fileObject: currentObject, items: dataSource.fetchedObjects)
        let nController = NavigationController(rootViewController: controller)
        router.presentViewController(controller: nController)
    }
    
    private func select(cell: PhotoVideoCell, at indexPath: IndexPath) {
        let isSelectedCell = dataSource.selectedIndexPaths.contains(indexPath)
        
        if isSelectedCell {
            dataSource.selectedIndexPaths.remove(indexPath)
        } else {
            dataSource.selectedIndexPaths.insert(indexPath)
        }
        
        cell.set(isSelected: !isSelectedCell, isSelectionMode: dataSource.isSelectingMode, animated: true)
        onChangeSelectedItemsCount(selectedItemsCount: dataSource.selectedIndexPaths.count)
    }
    
    private func trackClickOnPhotoOrVideo(isPhoto: Bool) {
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .click, eventLabel: isPhoto ? .clickPhoto : .clickVideo)
    }
    
    private func showSearchScreen(output: UIViewController?) {
        let router = RouterVC()
        let controller = router.searchView(output: output as? SearchModuleOutput)
        output?.navigationController?.delegate = controller as? BaseViewController
        controller.transitioningDelegate = output as? UIViewControllerTransitioningDelegate
        router.pushViewController(viewController: controller)
    }
}

// MARK: - PhotoVideoCellDelegate
extension PhotoVideoController: PhotoVideoCellDelegate {
    func photoVideoCellOnLongPressBegan(at indexPath: IndexPath) {
        startEditingMode(at: indexPath)
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoVideoController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoVideoCell else {
            return
        }
        cell.delegate = self
        cell.indexPath = indexPath
        
        let object = dataSource.object(at: indexPath)
        let wraped = WrapData(mediaItem: object)
        cell.setup(with: wraped)
        
        let isSelectedCell = dataSource.selectedIndexPaths.contains(indexPath)
        cell.set(isSelected: isSelectedCell, isSelectionMode: dataSource.isSelectingMode, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoVideoCell else {
            return
        }
        
        if dataSource.isSelectingMode {
            select(cell: cell, at: indexPath)
        } else {
            showDetail(at: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       let view = collectionView.dequeue(supplementaryView: CollectionViewSimpleHeaderWithText.self, kind: kind, for: indexPath)
        
        let object = dataSource.object(at: indexPath)
        if let date = object.creationDateValue as Date? {
            let df = DateFormatter()
            df.dateStyle = .medium
            let title = df.string(from: date)
            view.setText(text: title)
        } else {
            view.setText(text: "nil")
        }
        
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoVideoController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        ///return CGSize(width: collectionView.contentSize.width, height: 50)
        return CGSize(width: 0, height: 50)
    }
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        
    //        return CGSize(width: 200, height: 200)
    //    }
}

//extension PhotoVideoController: SegmentedControllerDelegate {
//}

// MARK: - BaseItemInputPassingProtocol 
/// using: bottomBarPresenter.basePassingPresenter = self, PhotoVideoThreeDotMenuManager(delegate: self)
extension PhotoVideoController: BaseItemInputPassingProtocol {
    
    var selectedItems: [BaseDataSourceItem] {
        return dataSource.selectedObjects
    }
    
    func stopModeSelected() {
        stopEditingMode()
    }
    
    func selectModeSelected() {
        startEditingMode(at: nil)
    }
    
    func operationFinished(withType type: ElementTypes, response: Any?) {}
    func operationFailed(withType type: ElementTypes) {}
    func selectAllModeSelected() {}
    func deSelectAll() {}
    func printSelected() {}
    func changeCover() {}
    func deleteFromFaceImageAlbum(items: [BaseDataSourceItem]) {}
}

// MARK: - PhotoVideoNavBarManagerDelegate
extension PhotoVideoController: PhotoVideoNavBarManagerDelegate {
    
    func onCancelSelectionButton() {
        stopEditingMode()
    }
    
    func onThreeDotsButton() {
        threeDotMenuManager.showActions(for: dataSource.selectedObjects, isSelectingMode: dataSource.isSelectingMode)
    }
    
    func onSearchButton() {
        showSearchScreen(output: self)
    }
}
