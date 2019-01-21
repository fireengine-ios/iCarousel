//
//  AnalyzeHistoryDataSource.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 1/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol AnalyzeHistoryDataSourceDelegate: class {
    func needLoadNextHistoryPage()
    func onLongPressInCell()
    func onPurchase()
    func onSeeDetailsForAnalyze(_ analyze: InstapickAnalyze)
    func onUpdateSelectedItems(count: Int)
}

private enum AnalyzeHistorySectionType: Int {
    case cards = 0
    case photos
    
    var numberOfColumns: CGFloat {
        return Device.isIpad ? 6 : 4
    }
    
    var cellType: UICollectionViewCell.Type {
        switch self {
        case .cards: return InstapickAnalysisCell.self
        case .photos: return InstapickAnalyzeHistoryPhotoCell.self
        }
    }
    
    var lineSpacing: CGFloat {
        switch self {
        case .cards: return 0
        case .photos: return 23
        }
    }
    
    var interitemSpacing: CGFloat {
        switch self {
        case .cards: return 0
        case .photos: return Device.isIpad ? 20 : 8
        }
    }
    
    var sectionInsets: UIEdgeInsets {
        switch self {
        case .cards: return UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        case .photos: return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func cellSize(collectionViewWidth width: CGFloat) -> CGSize {
        switch self {
        case .cards: return CGSize(width: width, height: 126)
        case .photos:
            let cellWidth = (width - sectionInsets.left - sectionInsets.right - interitemSpacing * (numberOfColumns - 1)) / numberOfColumns
            return CGSize(width: cellWidth, height: cellWidth + 28)
        }
    }
}

final class AnalyzeHistoryDataSourceForCollectionView: NSObject {
    
    private var collectionView: UICollectionView!
    
    private let sections: [AnalyzeHistorySectionType] = [.cards, .photos]
    private var items = [InstapickAnalyze]()
    private(set) var selectedItems = [InstapickAnalyze]()
    
    private(set) var analysisCount = InstapickAnalyzesCount(left: 0, total: 0) {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadSections(IndexSet(arrayLiteral: AnalyzeHistorySectionType.cards.rawValue))
            }
        }
    }
    
    private(set) var isSelectionStateActive = false
    
    var isPaginationDidEnd = false
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    var itemsCount: Int {
        return items.count
    }

    weak var delegate: AnalyzeHistoryDataSourceDelegate?
    
    // MARK: - Functions
    
    func setupCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
        
        collectionView.alwaysBounceVertical = true
        collectionView.register(nibCell: InstapickAnalysisCell.self)
        collectionView.register(nibCell: InstapickAnalyzeHistoryPhotoCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func analyzeForCell(_ cell: UICollectionViewCell) -> InstapickAnalyze? {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return nil
        }
        return items[safe: indexPath.item]
    }
    
    func reloadCards(with analysisCount: InstapickAnalyzesCount) {
        self.analysisCount = analysisCount
    }
    
    func reloadHistoryItems(_ newItems: [InstapickAnalyze]) {
        items = newItems
        collectionView.reloadData()
    }
    
    func appendHistoryItems(_ newItems: [InstapickAnalyze]) {
        guard !newItems.isEmpty else {
            isPaginationDidEnd = true
            return
        }
        mergeItems(with: newItems)
    }
    
    private func mergeItems(with newItems: [InstapickAnalyze]) {
        let uuids = items.map {$0.requestIdentifier}
        
        var insertIndexPaths = [IndexPath]()
        
        newItems.forEach { item in
            if !uuids.contains(item.requestIdentifier) {
                insertIndexPaths.append(IndexPath(item: items.count, section: AnalyzeHistorySectionType.photos.rawValue))
                self.items.append(item)
            }
        }
        
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: insertIndexPaths)
        })
    }
    
    func deleteSelectedItems(completion: VoidHandler?) {
        var deleteIndexPaths = [IndexPath]()
        selectedItems.forEach { item in
            if let index = self.items.index(of: item) {
                deleteIndexPaths.append(IndexPath(item: index, section: AnalyzeHistorySectionType.photos.rawValue))
            }
        }
        
        selectedItems.forEach { item in
            items.remove(item)
        }
        
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: deleteIndexPaths)
        }) { [weak self] _ in
            self?.selectedItems.removeAll()
            completion?()
        }
    }
    
    func startSelection(with indexPath: IndexPath? = nil) {
        isSelectionStateActive = true
        if let indexPath = indexPath {
            let item = items[indexPath.item]
            selectedItems = [item]
        } else {
            selectedItems = []
        }
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
    
    func cancelSelection() {
        isSelectionStateActive = false
        selectedItems.removeAll()
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension AnalyzeHistoryDataSourceForCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .cards: return 1
        case .photos: return items.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: sections[indexPath.section].cellType, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .cards:
            if let cell = cell as? InstapickAnalysisCell {
                cell.setup(with: analysisCount)
                cell.delegate = self
            }
        case .photos:
            if let cell = cell as? InstapickAnalyzeHistoryPhotoCell {
                let item = items[indexPath.item]
                let isSelected = isSelectionStateActive && selectedItems.contains(item)
                cell.setSelection(isSelectionActive: isSelectionStateActive, isSelected: isSelected)
                cell.setup(with: item)
                cell.delegate = self
            }
        }
        
        if isPaginationDidEnd {
            return
        }
        
        let countRow: Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        let isLastSection = numberOfSections(in: collectionView) - 1 == indexPath.section
        let isLastCell = countRow - 1 == indexPath.row
        
        if isLastSection, isLastCell {
            delegate?.needLoadNextHistoryPage()
        }
    }
}

// MARK: - UICollectionViewDelegate

extension AnalyzeHistoryDataSourceForCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == AnalyzeHistorySectionType.photos.rawValue else {
            return
        }
        
        let item = items[indexPath.item]
        if isSelectionStateActive {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCellDataProtocol else {
                return
            }
            let isSelected = selectedItems.contains(item)
            cell.setSelection(isSelectionActive: isSelectionStateActive, isSelected: !isSelected)
            if isSelected {
                selectedItems.remove(item)
            } else {
                selectedItems.append(item)
            }
            delegate?.onUpdateSelectedItems(count: selectedItems.count)
        } else {
            delegate?.onSeeDetailsForAnalyze(item)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AnalyzeHistoryDataSourceForCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sections[indexPath.section].cellSize(collectionViewWidth: collectionView.bounds.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sections[section].lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sections[section].interitemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sections[section].sectionInsets
    }
}

// MARK: - InstapickAnalysisCellDelegate

extension AnalyzeHistoryDataSourceForCollectionView: InstapickAnalysisCellDelegate, LBCellsDelegate {
    func onPurchase() {
        delegate?.onPurchase()
    }
    
    func onSeeDetails(cell: UICollectionViewCell) {
        if let analyze = analyzeForCell(cell) {
            delegate?.onSeeDetailsForAnalyze(analyze)
        }
    }
    
    func canLongPress() -> Bool {
        return true
    }
    
    func onLongPress(cell: UICollectionViewCell) {
        if !isSelectionStateActive {
            if let indexPath = collectionView.indexPath(for: cell) {
                startSelection(with: indexPath)
            }
            delegate?.onLongPressInCell()
        }
    }
}
