//
//  PrivateShareSharedFilesCollectionManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 11.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import UIKit
 
protocol PrivateShareSharedFilesCollectionManagerDelegate: class {
    func didStartSelection(selected: Int)
    func didEndSelection()
    func didChangeSelection(selectedItems: [WrapData])
}

final class PrivateShareSharedFilesCollectionManager: NSObject {
    
    static func with(collection: QuickSelectCollectionView, fileInfoManager: PrivateShareFileInfoManager) -> PrivateShareSharedFilesCollectionManager {
        let collectionManager = PrivateShareSharedFilesCollectionManager()
        collectionManager.collectionView = collection
        collectionManager.fileInfoManager = fileInfoManager
        return collectionManager
    }
    
    weak var delegate: PrivateShareSharedFilesCollectionManagerDelegate?
    private weak var collectionView: QuickSelectCollectionView?
    
    private let router = RouterVC()
    private var fileInfoManager: PrivateShareFileInfoManager?
    
    private(set) var currentCollectionViewType: MoreActionsConfig.ViewType = .List
    private var isSelecting = false
    
    
    //MARK: -
    
    private override init() { }
    
    //MARK: - Public
    
    func setup() {
        setupCollection()
        setupRefresher()
        reload()
    }
    
    func change(viewType: MoreActionsConfig.ViewType) {
        guard viewType != currentCollectionViewType else {
            return
        }
        
        currentCollectionViewType = viewType
        updateLayout()
    }
    
    func change(sortingRule: SortedRules) {
        fileInfoManager?.change(sortingRules: sortingRule) { [weak self] in
            self?.reloadCollection()
        }
    }
    
    func startSelection() {
        changeSelection(isActive: true)
        reloadVisibleCells()
    }
    
    func endSelection() {
        changeSelection(isActive: false)
        reloadVisibleCells()
    }
    
    func selectedItems() -> [WrapData] {
        return fileInfoManager?.selectedItems.getArray() ?? []
    }
    
    //MARK: - Private
    
    private func reloadCollection() {
        DispatchQueue.main.async {
            self.collectionView?.refreshControl?.endRefreshing()
            self.collectionView?.reloadData()
        }
    }
    
    private func setupCollection() {
        collectionView?.register(nibCell: BasicCollectionMultiFileCell.self)
        collectionView?.register(nibSupplementaryView: CollectionViewSimpleHeaderWithText.self,
                                 kind: UICollectionElementKindSectionHeader)
        
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.isQuickSelectAllowed = true
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.longPressDelegate = self
    }
    
    private func setupRefresher() {
        let refresher = UIRefreshControl()
        refresher.tintColor = ColorConstants.blueColor
        refresher.addTarget(self, action: #selector(reload), for: .valueChanged)
        collectionView?.refreshControl = refresher
    }
    
    @objc
    private func reload() {
        fileInfoManager?.reload { [weak self] _ in
            self?.changeSelection(isActive: false)
            self?.reloadCollection()
        }
        
    }
    
    private func loadNextPage() {
        fileInfoManager?.loadNext(completion: { [weak self] itemsLoaded in
//            self?.append(indexes: itemsLoaded)
            self?.reloadCollection()
        })
    }
    
    private func append(indexes: [IndexPath]) {
        guard !indexes.isEmpty else {
            return
        }
        
        DispatchQueue.main.async {
            self.collectionView?.performBatchUpdates({
                self.collectionView?.insertItems(at: indexes)
            }, completion: { (_) in
                //
            })
        }
    }
    
    private func updateLayout() {
        DispatchQueue.toMain {
            self.collectionView?.reloadData()
            let firstVisibleIndexPath = self.collectionView?.indexPathsForVisibleItems.min(by: { first, second -> Bool in
                return first < second
            })

            if let firstVisibleIndexPath = firstVisibleIndexPath {
                if firstVisibleIndexPath.row == 0, firstVisibleIndexPath.section == 0 {
                    self.collectionView?.scrollToItem(at: firstVisibleIndexPath, at: .centeredVertically, animated: false)
                } else{
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
            fileInfoManager?.deselectAll()
        }
        
        if isSelecting {
            delegate?.didStartSelection(selected: fileInfoManager?.selectedItems.count ?? 0)
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
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PrivateShareSharedFilesCollectionManager: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fileInfoManager?.splittedItems.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileInfoManager?.splittedItems[section]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: BasicCollectionMultiFileCell.self, for: indexPath)
        cell.setDelegateObject(delegateObject: self)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? BasicCollectionMultiFileCell, let item = item(at: indexPath) else {
            return
        }
        
        cell.updating()
        cell.setSelection(isSelectionActive: isSelecting, isSelected: isSelected(item: item))
        cell.configureWithWrapper(wrappedObj: item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? BasicCollectionMultiFileCell else {
            return
        }
        
        cell.setSelection(isSelectionActive: isSelecting, isSelected: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? BasicCollectionMultiFileCell else {
            return
        }
        
        if isSelecting {
            fileInfoManager?.selectItem(at: indexPath)
            cell.setSelection(isSelectionActive: isSelecting, isSelected: true)
            delegate?.didChangeSelection(selectedItems: fileInfoManager?.selectedItems.getArray() ?? [])
            
        } else {
            showDetailView(for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? BasicCollectionMultiFileCell else {
            return
        }
        
        if isSelecting {
            fileInfoManager?.deselectItem(at: indexPath)
            cell.setSelection(isSelectionActive: isSelecting, isSelected: false)
            delegate?.didChangeSelection(selectedItems: fileInfoManager?.selectedItems.getArray() ?? [])
        }
    }
    
    //MARK: Helpers
    private func item(at indexPath: IndexPath) -> WrapData? {
        return fileInfoManager?.splittedItems[indexPath.section]?[safe: indexPath.row]
    }
    
    private func isSelected(item: WrapData) -> Bool {
        return fileInfoManager?.selectedItems.contains(item) ?? false
    }
    
    private func showDetailView(for indexPath: IndexPath) {
        guard let item = item(at: indexPath) else {
            return
        }
        
        if item.isFolder == true, let folderId = item.id, let name = item.name ?? "" {
            openFolder(with: folderId, name: name)
            
        } else if let items = fileInfoManager?.sortedItems.getArray().filter({ !($0.isFolder ?? false) }) {
            openPreview(for: item, with: items)
        }
    }
    
    private func openFolder(with folderId: Int64, name: String) {
        DispatchQueue.toMain {
            let controller = self.router.sharedFolder(folderId: folderId, name: name)
            self.router.pushViewController(viewController: controller)
        }
    }
    
    private func openPreview(for item: WrapData, with items: [WrapData]) {
        DispatchQueue.toMain {
            let detailModule = self.router.filesDetailModule(fileObject: item,
                                                        items: items,
                                                        status: .active,
                                                        canLoadMoreItems: true,
                                                        moduleOutput: nil)

            let nController = NavigationController(rootViewController: detailModule.controller)
            self.router.presentViewController(controller: nController)
        }
    }
}


//MARK: - UICollectionViewDelegateFlowLayout
extension PrivateShareSharedFilesCollectionManager: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat
        let height: CGFloat
        
        switch currentCollectionViewType {
            case .List:
                width = collectionView.contentSize.width
                height = BasicCollectionMultiFileCell.bigH
                
            case .Grid:
                if Device.isIpad {
                    width = (collectionView.contentSize.width - NumericConstants.iPadGreedInset * 2 - NumericConstants.iPadGreedHorizontalSpace * (NumericConstants.numerCellInDocumentLineOnIpad - 1)) / NumericConstants.numerCellInDocumentLineOnIpad
                } else {
                    width = (collectionView.contentSize.width - NumericConstants.iPhoneGreedInset * 2 - NumericConstants.iPhoneGreedHorizontalSpace * (NumericConstants.numerCellInDocumentLineOnIphone - 1)) / NumericConstants.numerCellInDocumentLineOnIphone
                }
                height = width
                
            default:
                assertionFailure()
                return .zero
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height: CGFloat =  50
        return CGSize(width: collectionView.contentSize.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeue(supplementaryView: CollectionViewSimpleHeaderWithText.self, kind: kind, for: indexPath)
        sectionHeader.setText(text: "")
        return sectionHeader
    }
}

//MARK: - UIScrollView
extension PrivateShareSharedFilesCollectionManager {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isNearTheNextPage(scrollView) {
            loadNextPage()
        }
    }
    
    //MARK: Helpers
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

//MARK: - LBCellsDelegate, BasicCollectionMultiFileCellActionDelegate
extension PrivateShareSharedFilesCollectionManager: LBCellsDelegate, BasicCollectionMultiFileCellActionDelegate {
    func canLongPress() -> Bool {
        //QuickSelectCollectionView
        return false
    }
    
    func onLongPress(cell: UICollectionViewCell) {
        //QuickSelectCollectionView
    }
    
    func morebuttonGotPressed(sender: Any, itemModel: Item?) {
        //TODO:
    }
}

//MARK: - QuickSelectCollectionViewDelegate
extension PrivateShareSharedFilesCollectionManager: QuickSelectCollectionViewDelegate {
    func didLongPress(at indexPath: IndexPath?) {
        changeSelection(isActive: true)
        reloadVisibleCells()
    }
    
    func didEndLongPress(at indexPath: IndexPath?) {
        if isSelecting {
            delegate?.didChangeSelection(selectedItems: fileInfoManager?.selectedItems.getArray() ?? [])
        }
    }
}
