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
    func didChangeSelection(selected: Int)
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
    
    func cancelSelection() {
        changeSelection(isActive: false)
    }
    
    //MARK: - Private
    
    private func reloadCollection() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    private func setupCollection() {
        collectionView?.register(nibCell: BasicCollectionMultiFileCell.self)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        
        collectionView?.isQuickSelectAllowed = true
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.longPressDelegate = self
    }
    
    private func setupRefresher() {
        let refresher = UIRefreshControl()
        refresher.tintColor = ColorConstants.whiteColor
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
            self?.append(indexes: itemsLoaded)
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
        
        reloadVisibleCells()
        
        if isSelecting {
            delegate?.didStartSelection(selected: fileInfoManager?.selectedItems.count ?? 0)
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
        //TODO: sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //TODO: sections
        return fileInfoManager?.loadedItems.count ?? 0
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
            delegate?.didChangeSelection(selected: fileInfoManager?.selectedItems.count ?? 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? BasicCollectionMultiFileCell else {
            return
        }
        
        if isSelecting {
            fileInfoManager?.deselectItem(at: indexPath)
            cell.setSelection(isSelectionActive: isSelecting, isSelected: false)
            delegate?.didChangeSelection(selected: fileInfoManager?.selectedItems.count ?? 0)
        }
    }
    
    //MARK: Helpers
    private func item(at indexPath: IndexPath) -> WrapData? {
        //TODO: sections
        return fileInfoManager?.loadedItems[indexPath.row]
    }
    
    private func isSelected(item: WrapData) -> Bool {
        return fileInfoManager?.selectedItems.contains(item) ?? false
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
    }
    
    func didEndLongPress(at indexPath: IndexPath?) {
        if isSelecting {
            delegate?.didChangeSelection(selected: fileInfoManager?.selectedItems.count ?? 0)
        }
    }
}
