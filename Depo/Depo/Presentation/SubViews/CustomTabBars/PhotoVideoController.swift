//
//  PhotoVideoController.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoVideoDataSourceDelegate: class {
    func selectedModeDidChange(_ selectingMode: Bool)
}

// TODO: selectedIndexPaths NSFetchedResultsController changes
final class PhotoVideoDataSource {
    var isSelectingMode = false {
        didSet {
            delegate?.selectedModeDidChange(isSelectingMode)
        }
    }
    var selectedIndexPaths = Set<IndexPath>()
    weak var delegate: PhotoVideoDataSourceDelegate?
}


final class PhotoVideoController: UIViewController, NibInit {

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
        
        if let segmentedController = parent as? SegmentedController {
            dataSource.delegate = segmentedController
            segmentedController.delegate = self
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateCellSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCellSize()
    }
    
    private func updateCellSize() {
        _ = collectionView.saveAndGetItemSize(for: 4)
    }
    
    private func setupEdittingBar() {
        let photoVideoBottomBarConfig = EditingBarConfig(
            elementsConfig:  [.share, .download, .sync, .addToAlbum, .delete], 
            style: .blackOpaque, tintColor: nil)
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        let botvarBarVC = bottomBarVCmodule.setupModule(config: photoVideoBottomBarConfig, settablePresenter: BottomSelectionTabBarPresenter())
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
        let sortDescriptor2 = NSSortDescriptor(key: #keyPath(MediaItem.creationDateValue), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor2]
        
        // TODO: device isIpad
        if UI_USER_INTERFACE_IDIOM() == .pad {
            fetchRequest.fetchBatchSize = 50
        } else {
            fetchRequest.fetchBatchSize = 20
        }
        
        //fetchRequest.relationshipKeyPathsForPrefetching = [#keyPath(PostDB.id)]
        let context = CoreDataStack.default.mainContext
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: #keyPath(MediaItem.creationDateValue), cacheName: nil)
    }()
    
    private func startEditingMode(at indexPath: IndexPath) {
        guard !dataSource.isSelectingMode else {
            return
        }
        ///history: parent?.navigationItem.leftBarButtonItem = cancelSelectionButton
        dataSource.isSelectingMode = true
        dataSource.selectedIndexPaths.insert(indexPath)
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
    
    private func stopEditingMode() {
        dataSource.isSelectingMode = false
        dataSource.selectedIndexPaths.removeAll()
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
}

extension PhotoVideoController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("--- fetchedResultsController.sections?.count", fetchedResultsController.sections?.count ?? 0)
        return fetchedResultsController.sections?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeue(cell: PhotoVideoCell.self, for: indexPath)
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
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

extension PhotoVideoController: SegmentedControllerDelegate {
    func segmentedControllerEndEditMode() {
        stopEditingMode()
    }
}

extension UICollectionView {
    @discardableResult
    func saveAndGetItemSize(for columnsNumber: Int) -> CGSize {
        
        let viewWidth = UIScreen.main.bounds.width
        
        let desiredItemWidth: CGFloat = 100
        let columns: CGFloat = max(floor(viewWidth / desiredItemWidth), CGFloat(columnsNumber))
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
        return itemSize
    }
}
