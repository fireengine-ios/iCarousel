//
//  PrivateShareSharedFilesCollectionManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 11.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import UIKit

enum ReloadType {
    case full
    case onOperationFinished
    case onViewAppear
}
 
protocol PrivateShareSharedFilesCollectionManagerDelegate: class {
    func didStartSelection(selected: Int)
    func didEndSelection()
    func didChangeSelection(selectedItems: [WrapData])
    
    func didEndReload()
    
    func showActions(for item: WrapData, sender: Any)
    func didSelectAction(type: ActionType, on item: Item, sender: Any?)
    
    func needToShowSpinner()
    func needToHideSpinner()
}

final class PrivateShareSharedFilesCollectionManager: NSObject {
    
    static func with(collection: UICollectionView, fileInfoManager: PrivateShareFileInfoManager) -> PrivateShareSharedFilesCollectionManager {
        let collectionManager = PrivateShareSharedFilesCollectionManager()
        collectionManager.collectionView = collection
        collectionManager.fileInfoManager = fileInfoManager
        return collectionManager
    }
    
    weak var delegate: PrivateShareSharedFilesCollectionManagerDelegate?
    private weak var collectionView: UICollectionView?
    
    private let router = RouterVC()
    private var fileInfoManager: PrivateShareFileInfoManager!
    
    private let scrollDirectionManager = ScrollDirectionManager()
    
    private(set) var isSelecting = false
    
    private lazy var mediaPlayer: MediaPlayer = factory.resolve()
    
    var rootPermissions: SharedItemPermission? {
        return fileInfoManager.rootFolder?.permissions
    }
    
    //MARK: -
    
    private override init() { }
    
    //MARK: - Public
    
    func setup() {
        setupCollection()
        setupTopRefresher()
        reload(type: .full)
    }
    
    func change(sortingRule: SortedRules) {
        fileInfoManager.change(sortingRules: sortingRule) { [weak self] in
            self?.reloadCollection()
        }
    }
    
    func startSelection(with item: WrapData) {
        fileInfoManager.selectItem(item)
        changeSelection(isActive: true)
        reloadVisibleCells()
    }
    
    func endSelection() {
        changeSelection(isActive: false)
        reloadVisibleCells()
    }
    
    func startRenaming(item: WrapData) {
        if
            let index = fileInfoManager.sortedItems.index(where: { $0 == item }),
            let cell = collectionView?.cellForItem(at: IndexPath(row: index, section: 0)) as? MultifileCollectionViewCell
        {
            cell.startRenaming()
        }
    }
    
    func reload(type: ReloadType) {
        switch type {
            case .full:
                fullReload()
                
            case .onOperationFinished:
                reloadAfterOperation()
                
            case .onViewAppear:
                reloadOnViewAppear()
        }
    }
    
    func selectedItems() -> [WrapData] {
        return fileInfoManager.selectedItems.getArray()
    }
    
    func delete(uuids: [String]) {
        guard !uuids.isEmpty else {
            return
        }
        
        fileInfoManager.delete(uuids: uuids) { [weak self] in
            self?.reloadCollection()
            self?.reload(type: .onOperationFinished)
        }
    }
    
    //MARK: - Private
    
    private func reloadCollection() {
        DispatchQueue.main.async {
            self.collectionView?.refreshControl?.endRefreshing()
            self.collectionView?.reloadData()
            self.setEmptyScreen(isHidden: !self.fileInfoManager.sortedItems.isEmpty)
            self.delegate?.didEndReload()
        }
    }
    
    private func setupCollection() {
        collectionView?.register(nibCell: MultifileCollectionViewCell.self)
        
        collectionView?.register(nibSupplementaryView: CollectionViewSpinnerFooter.self,
                                 kind: UICollectionElementKindSectionFooter)

        collectionView?.allowsSelection = false
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.backgroundView = EmptyView.view(with: fileInfoManager.type.emptyViewType)
        collectionView?.backgroundView?.isHidden = true
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
    }
    
    private func setupTopRefresher() {
        let refresher = UIRefreshControl()
        refresher.tintColor = ColorConstants.blueColor
        refresher.addTarget(self, action: #selector(fullReload), for: .valueChanged)
        collectionView?.refreshControl = refresher
    }
    
    @objc
    private func fullReload() {
        fileInfoManager.reload { [weak self] (shouldReload, _) in
            if shouldReload {
                self?.changeSelection(isActive: false)
                self?.reloadCollection()
            }
        }
        
    }
    
    private func reloadAfterOperation() {
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.fileInfoManager.reloadCurrentPages { [weak self] (shouldReload, indexes) in
                if shouldReload {
                    if let indexes = indexes {
                        self?.batchUpdate(indexes: indexes)
                    } else {
                        self?.reloadCollection()
                    }
                }
            }
        }
    }
    
    private func reloadOnViewAppear() {
        resetVisibleCellsSwipe()
        fileInfoManager.reloadCurrentPages { [weak self] (shouldReload, indexes) in
            if shouldReload {
                if let indexes = indexes {
                    self?.batchUpdate(indexes: indexes)
                } else {
                    self?.reloadCollection()
                }
            }
        }
    }
    
    private func loadNextPage() {
        showNextPageSpinner()
        fileInfoManager.loadNextPage(completion: { [weak self] (shouldReload, indexes) in
            self?.hideNextPageSpinner()
            if shouldReload {
                if let indexes = indexes {
                    self?.batchUpdate(indexes: indexes)
                } else {
                    self?.reloadCollection()
                }
            }
        })
    }
    
    private func showNextPageSpinner() {
        let lastSectionIndex = IndexPath(item: 0, section: 0)
        DispatchQueue.toMain {
            guard let footerView =
                    self.collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: lastSectionIndex) as? CollectionViewSpinnerFooter else {
                return
            }
            
            footerView.startSpinner()
        }
    }
    
    private func hideNextPageSpinner() {
        let lastSectionIndex = IndexPath(item: 0, section: 0)
        DispatchQueue.toMain {
            guard let footerView =
                    self.collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: lastSectionIndex) as? CollectionViewSpinnerFooter else {
                return
            }
            
            footerView.stopSpinner()
        }
    }
    
    private func batchUpdate(indexes: DeltaIndexes) {
        guard !indexes.inserted.isEmpty || !indexes.deleted.isEmpty else {
            DispatchQueue.main.async {
                self.collectionView?.refreshControl?.endRefreshing()
                self.setEmptyScreen(isHidden: !self.fileInfoManager.sortedItems.isEmpty)
                self.delegate?.didEndReload()
            }
            return
        }
        DispatchQueue.main.async {
            self.collectionView?.refreshControl?.endRefreshing()
            self.collectionView?.performBatchUpdates({
                self.collectionView?.deleteItems(at: indexes.deleted.compactMap { IndexPath(row: $0, section: 0) })
                self.collectionView?.insertItems(at: indexes.inserted.compactMap { IndexPath(row: $0, section: 0) })
                
            }, completion: { (_) in
                self.setEmptyScreen(isHidden: !self.fileInfoManager.sortedItems.isEmpty)
                self.delegate?.didEndReload()
            })
        }
    }
    
    private func updateLayout() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            let firstVisibleIndexPath = self.collectionView?.indexPathsForVisibleItems.min(by: { first, second -> Bool in
                return first < second
            })

            if let firstVisibleIndexPath = firstVisibleIndexPath {
                if firstVisibleIndexPath.row == 0, firstVisibleIndexPath.section == 0 {
                    self.collectionView?.scrollToItem(at: firstVisibleIndexPath, at: .centeredVertically, animated: false)
                } else {
                    self.collectionView?.scrollToItem(at: firstVisibleIndexPath, at: .top, animated: false)
                }
            }
        }
    }
    
    private func changeSelection(isActive: Bool) {
        guard isSelecting != isActive else {
            return
        }
        
        isSelecting = isActive
        
        if !isSelecting {
            fileInfoManager.deselectAll()
        }
        
        if isSelecting {
            delegate?.didStartSelection(selected: fileInfoManager.selectedItems.count)
        } else {
            delegate?.didEndSelection()
        }
        
    }
    
    private func reloadVisibleCells() {
        DispatchQueue.main.async {
            guard let visibleCells = self.collectionView?.indexPathsForVisibleItems, !visibleCells.isEmpty else {
                return
            }
            
            self.collectionView?.reloadItems(at: visibleCells)
        }
    }
    
    private func resetVisibleCellsSwipe() {
        DispatchQueue.main.async {
            guard let visibleCells = self.collectionView?.visibleCells as? [MultifileCollectionViewCell] else {
                return
            }
            
            visibleCells.forEach { $0.resetSwipe() }
        }
    }
    
    private func setEmptyScreen(isHidden: Bool) {
        guard collectionView?.backgroundView?.isHidden != isHidden else {
            return
        }
        
        DispatchQueue.main.async {
            self.collectionView?.backgroundView?.isHidden = isHidden
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PrivateShareSharedFilesCollectionManager: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileInfoManager.sortedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: MultifileCollectionViewCell.self, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MultifileCollectionViewCell, let item = item(at: indexPath) else {
            return
        }
        
        let isSelectedCell = isSelected(item: item)
        let isSharedIconAllowed = fileInfoManager.type.rootType.isContained(in: [.myDisk])
        cell.setSelection(isSelectionActive: isSelecting, isSelected: isSelectedCell)
        cell.setup(with: item, at: indexPath, isSharedIconAllowed: isSharedIconAllowed, menuActionDelegate: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MultifileCollectionViewCell else {
            return
        }
        
        cell.setSelection(isSelectionActive: isSelecting, isSelected: false)
    }

    //MARK: Helpers
    private func item(at indexPath: IndexPath) -> WrapData? {
        return fileInfoManager.sortedItems[indexPath.row]
    }
    
    private func isSelected(item: WrapData) -> Bool {
        return fileInfoManager.selectedItems.getSet().contains(where: { $0.uuid == item.uuid })
    }
    
    private func showDetailView(for item: WrapData) {
        if item.isFolder == true {
            if let name = item.name, let permissions = item.privateSharePermission  {
                let sharedFolder = PrivateSharedFolderItem(accountUuid: item.accountUuid, uuid: item.uuid, name: name, permissions: permissions, type: fileInfoManager.type)
                openFolder(with: sharedFolder)
            }
            
        } else {
            let items = fileInfoManager.sortedItems.getArray().filter({ !($0.isFolder ?? false) })
            openPreview(for: item, with: items)
        }
    }
    
    private func showAudioPlayer(with item: WrapData) {
        if item.urlToFile == nil || item.urlToFile?.isExpired == true {
            delegate?.needToShowSpinner()
            fileInfoManager.createDownloadUrl(item: item) { [weak self] newUrl in
                self?.delegate?.needToHideSpinner()
                
                guard let url = newUrl else {
                    return
                }
                
                item.tmpDownloadUrl = url
                self?.mediaPlayer.play(list: [item], startAt: 0)
            }
        } else {
            mediaPlayer.play(list: [item], startAt: 0)
        }
    }
    
    private func checkIfCanShowDetail(for item: WrapData) -> Bool {
        guard item.isFolder == false else {
            return true
        }
        
        
        if item.fileType.isContained(in: [.image, .video]), !item.hasPreviewUrl {
            SnackbarManager.shared.show(type: SnackbarType.action, message: TextConstants.privateSharePreviewNotReady)
            return false
        }

        return true
    }
    
    private func openFolder(with folder: PrivateSharedFolderItem) {
        DispatchQueue.main.async {
            let controller = self.router.sharedFolder(rootShareType: self.fileInfoManager.type, folder: folder)
            self.router.pushViewController(viewController: controller)
        }
    }
    
    private func openPreview(for item: WrapData, with items: [WrapData]) {
        DispatchQueue.main.async {
            let detailModule = self.router.filesDetailModule(fileObject: item,
                                                        items: items,
                                                        status: .active,
                                                        canLoadMoreItems: true,
                                                        moduleOutput: nil)

            let nController = NavigationController(rootViewController: detailModule.controller)
            self.router.presentViewController(controller: nController)
        }
    }
    
    private func onDidSelectItem(at indexPath: IndexPath) {
        guard let cell = collectionView?.cellForItem(at: indexPath) as? MultifileCollectionViewCell, !cell.isRenamingInProgress, let item = item(at: indexPath) else {
            return
        }
        
        if isSelecting {
            if isSelected(item: item) {
                fileInfoManager.deselectItem(at: indexPath)
                cell.setSelection(isSelectionActive: isSelecting, isSelected: false)
            } else {
                fileInfoManager.selectItem(at: indexPath)
                cell.setSelection(isSelectionActive: isSelecting, isSelected: true)
            }
            
            delegate?.didChangeSelection(selectedItems: fileInfoManager.selectedItems.getArray())
            
        } else {
            cell.setSelection(isSelectionActive: false, isSelected: false)
            if checkIfCanShowDetail(for: item) {
                
                if item.fileType == .audio {
                    showAudioPlayer(with: item)
                } else {
                    showDetailView(for: item)
                }
            }
        }
    }
}


//MARK: - UICollectionViewDelegateFlowLayout
extension PrivateShareSharedFilesCollectionManager: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.contentSize.width
        let height = MultifileCollectionViewCell.height
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let space = Device.isIpad ? NumericConstants.iPadGreedHorizontalSpace : NumericConstants.iPhoneGreedHorizontalSpace
        return space
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let space = Device.isIpad ? NumericConstants.iPadGreedHorizontalSpace : NumericConstants.iPhoneGreedHorizontalSpace
        return space
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: NumericConstants.iPhoneGreedInset, bottom: 0, right: NumericConstants.iPhoneGreedInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let isLastSection = section == 1
        let height: CGFloat = isLastSection ? 44.0 : 0.0
        return CGSize(width: collectionView.contentSize.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            case UICollectionElementKindSectionFooter:
                let footerSpinner = collectionView.dequeue(supplementaryView: CollectionViewSpinnerFooter.self, kind: kind, for: indexPath)
                if fileInfoManager.isNextPageLoading {
                    footerSpinner.startSpinner()
                } else {
                    footerSpinner.stopSpinner()
                }
                
                return footerSpinner
                
            default:
                assertionFailure()
                return UICollectionReusableView()
        }
    }
}

//MARK: - UIScrollView
extension PrivateShareSharedFilesCollectionManager: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDirectionManager.handleScrollBegin(with: scrollView.contentOffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            handleScrollEnd(with: scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrollEnd(with: scrollView)
    }
    
    /// if scroll programmatically
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handleScrollEnd(with: scrollView)
    }
    
    //MARK: Helpers
    private func handleScrollEnd(with scrollView: UIScrollView) {
        scrollDirectionManager.handleScrollEnd(with: scrollView.contentOffset)
        
        if scrollDirectionManager.scrollDirection == .down, isNearTheNextPage(scrollView) {
            loadNextPage()
        }
    }
    
    private func isNearTheNextPage(_ scrollView: UIScrollView) -> Bool {
        let nearTheNextPageValue = scrollView.bounds.height / 2.0
        
        guard scrollView.contentSize.height > scrollView.bounds.height + nearTheNextPageValue else {
            //prevents intersection with refresh when content height is too small
            return false
        }
        
        let distanceToNextPage = scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.height)
        
        return distanceToNextPage <= nearTheNextPageValue
    }
}

//MARK: - LBCellsDelegate, MultifileCollectionViewCellActionDelegate
extension PrivateShareSharedFilesCollectionManager: MultifileCollectionViewCellActionDelegate {
    func onRenameStarted(at indexPath: IndexPath) {
        self.collectionView?.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
    
    func rename(item: WrapData, name: String, completion: @escaping BoolHandler) {
        fileInfoManager.rename(item: item, name: name, completion: completion)
    }
    
    func onCellSelected(indexPath: IndexPath) {
        DispatchQueue.toMain {
            self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: [])
            //collection delegate didSelectItem will not be called
            self.onDidSelectItem(at: indexPath)
        }
    }
    
    func onSelectMenuAction(type: ActionType, itemModel: Item?, sender: Any?, indexPath: IndexPath?) {
        guard let item = itemModel else {
            return
        }
        if let indexPath = indexPath {
            fileInfoManager.selectItem(at: indexPath)
        }
        
        delegate?.didSelectAction(type: type, on: item, sender: sender)
    }
    
    func onMenuPress(sender: Any, itemModel: Item?) {
        guard let item = itemModel else {
            return
        }
        
        delegate?.showActions(for: item, sender: sender)
    }
    
    func onLongPress(cell: UICollectionViewCell) {
        guard fileInfoManager.type.isSelectionAllowed else {
            return
        }
        
        if let indexPath = collectionView?.indexPath(for: cell),
           let object = item(at: indexPath) {
            
            if !isSelecting {
                if !isSelected(item: object) {
                    fileInfoManager.selectItem(at: indexPath)
                }
                changeSelection(isActive: true)
                
            } else if !isSelected(item: object) {
                fileInfoManager.selectItem(at: indexPath)
            }
        }
    }
}
