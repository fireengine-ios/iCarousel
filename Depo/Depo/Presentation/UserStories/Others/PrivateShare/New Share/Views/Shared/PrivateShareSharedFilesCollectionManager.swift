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
    
    func showActions(for item: WrapData)
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
    private var fileInfoManager: PrivateShareFileInfoManager!
    
    private let scrollDirectionManager = ScrollDirectionManager()
    
    private(set) var currentCollectionViewType: MoreActionsConfig.ViewType = .List
    private(set) var isSelecting = false
    
    
    //MARK: -
    
    private override init() { }
    
    //MARK: - Public
    
    func setup() {
        setupCollection()
        setupRefresher()
        fullReload()
    }
    
    func change(viewType: MoreActionsConfig.ViewType) {
        guard viewType != currentCollectionViewType else {
            return
        }
        
        currentCollectionViewType = viewType
        updateLayout()
    }
    
    func change(sortingRule: SortedRules) {
        fileInfoManager.change(sortingRules: sortingRule) { [weak self] in
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
    
    func reload(type: ReloadType) {
        switch type {
            case .full:
                fullReload()
                
            case .onOperationFinished:
                reloadAfterOperation()
                
            case .onViewAppear:
                reloadAfterOperation()
        }
    }
    
    func selectedItems() -> [WrapData] {
        return fileInfoManager.selectedItems.getArray()
    }
    
    //MARK: - Private
    
    private func reloadCollection() {
        DispatchQueue.main.async {
            self.collectionView?.refreshControl?.endRefreshing()
            self.collectionView?.reloadData()
            self.delegate?.didEndReload()
        }
    }
    
    private func setupCollection() {
        collectionView?.register(nibCell: BasicCollectionMultiFileCell.self)
        collectionView?.register(nibSupplementaryView: CollectionViewSimpleHeaderWithText.self,
                                 kind: UICollectionElementKindSectionHeader)
        
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.isQuickSelectAllowed = false
        
        collectionView?.backgroundView = EmptyView.view(with: fileInfoManager.type.emptyViewType)
        collectionView?.backgroundView?.isHidden = true
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.longPressDelegate = self
    }
    
    private func setupRefresher() {
        let refresher = UIRefreshControl()
        refresher.tintColor = ColorConstants.blueColor
        refresher.addTarget(self, action: #selector(fullReload), for: .valueChanged)
        collectionView?.refreshControl = refresher
    }
    
    @objc
    private func fullReload() {
        fileInfoManager.reload { [weak self] itmesLoadedCount in
            self?.changeSelection(isActive: false)
            self?.reloadCollection()
            self?.setEmptyScreen(isHidden: itmesLoadedCount != 0)
        }
        
    }
    
    private func reloadAfterOperation() {
        return fileInfoManager.reloadCurerntPages { [weak self] itemsLoadedCount in
            self?.reloadCollection()
            self?.setEmptyScreen(isHidden: itemsLoadedCount != 0)
        }
    }
    
    private func loadNextPage() {
        fileInfoManager.loadNext(completion: { [weak self] itemsLoaded in
//            self?.append(indexes: itemsLoaded)
            if itemsLoaded != 0 {
                self?.reloadCollection()
            }
        })
    }
    
    //TODO: maybe later
//    private func append(indexes: [IndexPath]) {
//        guard !indexes.isEmpty else {
//            return
//        }
//
//        DispatchQueue.main.async {
//            self.collectionView?.performBatchUpdates({
//                self.collectionView?.insertItems(at: indexes)
//            }, completion: { (_) in
//                //
//            })
//        }
//    }
    
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
    
    private func setEmptyScreen(isHidden: Bool) {
        DispatchQueue.main.async {
            self.collectionView?.backgroundView?.isHidden = isHidden
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PrivateShareSharedFilesCollectionManager: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fileInfoManager.splittedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileInfoManager.splittedItems[section]?.count ?? 0
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
        
        let isSelectedCell = isSelected(item: item)
        cell.isSelected = isSelectedCell
        cell.updating()
        cell.setSelection(isSelectionActive: isSelecting, isSelected: isSelectedCell)
        cell.configureWithWrapper(wrappedObj: item)
          
        if case PathForItem.remoteUrl(let url) = item.patchToPreview {
            if let url = url {
                cell.setImage(with: url)
            } else {
                cell.setPlaceholderImage(fileType: item.fileType)
            }
        }
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
            fileInfoManager.selectItem(at: indexPath)
            cell.setSelection(isSelectionActive: isSelecting, isSelected: true)
            delegate?.didChangeSelection(selectedItems: fileInfoManager.selectedItems.getArray())
            
        } else if let item = item(at: indexPath), checkIfCanShowDetail(for: item) {
            showDetailView(for: item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? BasicCollectionMultiFileCell else {
            return
        }
        
        if isSelecting {
            fileInfoManager.deselectItem(at: indexPath)
            cell.setSelection(isSelectionActive: isSelecting, isSelected: false)
            delegate?.didChangeSelection(selectedItems: fileInfoManager.selectedItems.getArray())
        }
    }
    
    //MARK: Helpers
    private func item(at indexPath: IndexPath) -> WrapData? {
        return fileInfoManager.splittedItems[indexPath.section]?[safe: indexPath.row]
    }
    
    private func isSelected(item: WrapData) -> Bool {
        return fileInfoManager.selectedItems.contains(item)
    }
    
    private func showDetailView(for item: WrapData) {
        if item.isFolder == true {
            if let projectId = item.projectId, let name = item.name, let permissions = item.privateSharePermission  {
                let sharedFolder = PrivateSharedFolderItem(projectId: projectId, uuid: item.uuid, name: name, permissions: permissions)
                openFolder(with: sharedFolder)
            }
            
        } else {
            let items = fileInfoManager.sortedItems.getArray().filter({ !($0.isFolder ?? false) })
            openPreview(for: item, with: items)
        }
    }
    
    private func checkIfCanShowDetail(for item: WrapData) -> Bool {
        guard item.isFolder == false else {
            return true
        }
        
        let isSharedWithMe = fileInfoManager.type == .withMe || fileInfoManager.type.rootType == .withMe
        
        if isSharedWithMe, item.fileType.isContained(in: [.image, .video]), !item.hasPreviewUrl {
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
        let sectionIsEmpty = fileInfoManager.splittedItems[section]?.isEmpty ?? true
        let height: CGFloat =  sectionIsEmpty ? 0 : 50
        return CGSize(width: collectionView.contentSize.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeue(supplementaryView: CollectionViewSimpleHeaderWithText.self, kind: kind, for: indexPath)
        
        let title = headerTitle(for: indexPath.section)
        sectionHeader.setText(text: title)
        return sectionHeader
    }
    
    //MARK: Helpers
    private func headerTitle(for section: Int) -> String {
        let furstSectionItemIndexPath = IndexPath(row: 0, section: section)
        guard let item = item(at: furstSectionItemIndexPath) else {
            return ""
        }
        
        switch fileInfoManager.sorting {
            case .timeUp, .timeUpWithoutSection, .lastModifiedTimeUp, .timeDown, .timeDownWithoutSection, .lastModifiedTimeDown:
                return (item.creationDate ?? Date()).getDateInTextForCollectionViewHeader()
                
            case .lettersAZ, .albumlettersAZ, .lettersZA, .albumlettersZA:
                return item.name?.firstLetter ?? ""
                
            case .sizeAZ, .sizeZA:
                return ""
                
            case .metaDataTimeUp, .metaDataTimeDown:
                return (item.creationDate ?? Date()).getDateInTextForCollectionViewHeader()
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
        guard let item = itemModel else {
            return
        }
        
        delegate?.showActions(for: item)
    }
}

//MARK: - QuickSelectCollectionViewDelegate
extension PrivateShareSharedFilesCollectionManager: QuickSelectCollectionViewDelegate {
    func didLongPress(at indexPath: IndexPath?) {
        guard fileInfoManager.type.isSelectionAllowed else {
            return
        }
        
        if !isSelecting {
            changeSelection(isActive: true)
            reloadVisibleCells()
        }
    }
    
    func didEndLongPress(at indexPath: IndexPath?) {
        guard fileInfoManager.type.isSelectionAllowed else {
            return
        }
        
        if isSelecting {
            delegate?.didChangeSelection(selectedItems: fileInfoManager.selectedItems.getArray())
        }
    }
}
