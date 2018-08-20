//
//  PhotoVideoController.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

// TODO: items storage with remotes

// TODO: slider with albums
// TODO: sync cards
// TODO: action without selection mode
// TODO: items operations (progress)
// TODO: 3 dots
// TODO: clear code
final class PhotoVideoController: UIViewController, NibInit, SegmentedChildController {

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    private let refresher = UIRefreshControl()
    
    var editingTabBar: BottomSelectionTabBarViewController?
    
    private var dataSource = PhotoVideoDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEdittingBar()
        setupPullToRefresh()
//        collectionView.alwaysBounceVertical = true
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        
        
        
        fetchedResultsController.delegate = self
        /// default main queue fetch
        try? fetchedResultsController.performFetch()
        collectionView.reloadData()
        
//        CollectionViewCellsIdsConstant.cellForImage
        collectionView.register(nibCell: PhotoVideoCell.self)
        collectionView.register(nibSupplementaryView: CollectionViewSimpleHeaderWithText.self, kind: UICollectionElementKindSectionHeader)
        
//        if let segmentedController = parent as? SegmentedController {
//            dataSource.delegate = segmentedController
//            segmentedController.delegate = self
//        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateCellSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCellSize()
        editingTabBar?.view.layoutIfNeeded()
    }
    
    private func updateCellSize() {
        _ = collectionView.saveAndGetItemSize(for: 4)
    }
    
    
    
    private lazy var cancelSelectionButton = UIBarButtonItem(
        title: TextConstants.cancelSelectionButtonTitle,
        font: .TurkcellSaturaDemFont(size: 19.0),
        target: self,
        selector: #selector(onCancelSelectionButton))

    @objc private func onCancelSelectionButton() {
        stopEditingMode()
    }
    
    
    
    
    private let bottomBarPresenter = BottomSelectionTabBarPresenter()
    
    let photoVideoBottomBarConfig = EditingBarConfig(
        elementsConfig:  [.share, .download, .sync, .addToAlbum, .delete], 
        style: .blackOpaque, tintColor: nil)
    
    private func setupEdittingBar() {
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        bottomBarPresenter.basePassingPresenter = self
        let botvarBarVC = bottomBarVCmodule.setupModule(config: photoVideoBottomBarConfig, settablePresenter: bottomBarPresenter)
        self.editingTabBar = botvarBarVC
    }
    
    
    
    
    
    private func setupPullToRefresh() {
        //refresher.tintColor = ColorConstants.whiteColor
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.addSubview(refresher)
    }
    
    @objc private func refreshData() {
        
    } 
    
    private lazy var sectionChanges = [() -> Void]()
    private lazy var objectChanges = [() -> Void]()
    
    
    lazy var fetchedResultsController: NSFetchedResultsController<MediaItem> = {
        let fetchRequest: NSFetchRequest = MediaItem.fetchRequest()
        let sortDescriptor1 = NSSortDescriptor(key: #keyPath(MediaItem.creationDateValue), ascending: false)
//        let sortDescriptor2 = NSSortDescriptor(key: #keyPath(MediaItem.nameValue), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor1]
        
        // TODO: device isIpad
        if UI_USER_INTERFACE_IDIOM() == .pad {
            fetchRequest.fetchBatchSize = 50
        } else {
            fetchRequest.fetchBatchSize = 20
        }
        
        //fetchRequest.relationshipKeyPathsForPrefetching = [#keyPath(PostDB.id)]
        let context = CoreDataStack.default.mainContext
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: #keyPath(MediaItem.monthValue), cacheName: nil)
    }()
    
    private func startEditingMode(at indexPath: IndexPath) {
        guard !dataSource.isSelectingMode else {
            return
        }
        ///history: parent?.navigationItem.leftBarButtonItem = cancelSelectionButton
        dataSource.isSelectingMode = true
        dataSource.selectedIndexPaths.insert(indexPath)
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        onChangeSelectedItemsCount(selectedItemsCount: dataSource.selectedIndexPaths.count)
        setLeftBarButtonItems([cancelSelectionButton], animated: true)
    }
    
    private func stopEditingMode() {
        dataSource.isSelectingMode = false
        dataSource.selectedIndexPaths.removeAll()
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        dismissBottomBar(animated: true)
        setLeftBarButtonItems(nil, animated: true)
        setTitle("")
    }
    
    private func setupNewBottomBarConfig() {
        let array: [WrapData] = dataSource.selectedIndexPaths.map { indexPath in
            let object = fetchedResultsController.object(at: indexPath)
            return WrapData(mediaItem: object)
        }
        bottomBarPresenter.setupTabBarWith(items: array, originalConfig: photoVideoBottomBarConfig)
    }
    
    private func dismissBottomBar(animated: Bool) {
        bottomBarPresenter.dismiss(animated: animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar), object: nil)
    }
    
    private func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        setupNewBottomBarConfig()
//        debugLog("BaseFilesGreedPresenter onChangeSelectedItemsCount")
        
        if selectedItemsCount == 0 {
//            debugLog("BaseFilesGreedPresenter onChangeSelectedItemsCount selectedItemsCount == 0")
            
            dismissBottomBar(animated: true)
        } else {
//            debugLog("BaseFilesGreedPresenter onChangeSelectedItemsCount selectedItemsCount != 0")
            
            bottomBarPresenter.show(animated: true, onView: nil)
        }
        
        setTitle("\(selectedItemsCount) \(TextConstants.accessibilitySelected)")
        
//        view.setThreeDotsMenu(active: canShow3DotsButton())
//        self.view.selectedItemsCountChange(with: selectedItemsCount)
    }
}

extension PhotoVideoController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: PhotoVideoCell.self, for: indexPath)
    }
}

extension PhotoVideoController: PhotoVideoCellDelegate {
    func photoVideoCellOnLongPressBegan(at indexPath: IndexPath) {
        startEditingMode(at: indexPath)
    }
}

extension PhotoVideoController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoVideoCell else {
            return
        }
        cell.delegate = self
        cell.indexPath = indexPath
        
        let object = fetchedResultsController.object(at: indexPath)
        let wraped = WrapData(mediaItem: object)
        cell.setup(with: wraped)
        
        let isSelectedCell = dataSource.selectedIndexPaths.contains(indexPath)
        cell.set(isSelected: isSelectedCell, isSelectionMode: dataSource.isSelectingMode, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoVideoCell else {
            return
        }
        
        guard dataSource.isSelectingMode else {
            return
        }
        
        let isSelectedCell = dataSource.selectedIndexPaths.contains(indexPath)
        
        if isSelectedCell {
            dataSource.selectedIndexPaths.remove(indexPath)
        } else {
            dataSource.selectedIndexPaths.insert(indexPath)
        }
        
        cell.set(isSelected: !isSelectedCell, isSelectionMode: dataSource.isSelectingMode, animated: true)
        onChangeSelectedItemsCount(selectedItemsCount: dataSource.selectedIndexPaths.count)
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        return CGSize(width: 200, height: 200)
//    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       let view = collectionView.dequeue(supplementaryView: CollectionViewSimpleHeaderWithText.self, kind: kind, for: indexPath)
        
        let object = fetchedResultsController.object(at: indexPath)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        ///return CGSize(width: collectionView.contentSize.width, height: 50)
        return CGSize(width: 0, height: 50)
    }
}

/// https://github.com/jessesquires/JSQDataSourcesKit/blob/develop/Source/FetchedResultsDelegate.swift
/// https://gist.github.com/nor0x/c48463e429ba7b053fff6e277c72f8ec
extension PhotoVideoController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sectionChanges.removeAll()
        objectChanges.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let section = IndexSet(integer: sectionIndex)
        
        sectionChanges.append { [unowned self] in
            switch type {
            case .insert:
                self.collectionView.insertSections(section)
            case .delete:
                self.collectionView.deleteSections(section)
            default:
                break
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.insertItems(at: [indexPath])
                }
            }
        case .delete:
            if let indexPath = indexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.deleteItems(at: [indexPath])
                }
            }
        case .update:
            if let indexPath = indexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.moveItem(at: indexPath, to: newIndexPath)
                }
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({ [weak self] in  
            self?.objectChanges.forEach { $0() }
//            self?.sectionChanges.forEach { $0() }
        }, completion: { [weak self] _ in
            
            self?.collectionView.performBatchUpdates({
                self?.sectionChanges.forEach { $0() }
            }, completion: { _ in 
                self?.reloadSupplementaryViewsIfNeeded()
            })
        })
    }
    
    private func reloadSupplementaryViewsIfNeeded() {
        if !sectionChanges.isEmpty {
            collectionView.reloadData()
        }
    }

}

//extension PhotoVideoController: SegmentedControllerDelegate {
//    func segmentedControllerEndEditMode() {
//        stopEditingMode()
//    }
//}

extension PhotoVideoController: BaseItemInputPassingProtocol {
    func operationFinished(withType type: ElementTypes, response: Any?) {
        
    }
    
    func operationFailed(withType type: ElementTypes) {
        
    }
    
    func selectModeSelected() {
        
    }
    
    func selectAllModeSelected() {
        
    }
    
    func deSelectAll() {
        
    }
    
    func stopModeSelected() {
        stopEditingMode()
    }
    
    func printSelected() {
        
    }
    
    func changeCover() {
        
    }
    
    func deleteFromFaceImageAlbum(items: [BaseDataSourceItem]) {
        
    }
    
    var selectedItems: [BaseDataSourceItem] {
        let array: [WrapData] = dataSource.selectedIndexPaths.map { indexPath in
            let object = fetchedResultsController.object(at: indexPath)
            return WrapData(mediaItem: object)
        }
        return array
    }
}
