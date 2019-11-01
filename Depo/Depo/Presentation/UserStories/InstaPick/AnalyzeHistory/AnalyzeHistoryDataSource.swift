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
    func onSeeDetails()
    func onSelectAnalyze(_ analyze: InstapickAnalyze)
    func onUpdateSelectedItems(count: Int)
}

private enum AnalyzeHistoryCardType {
    case analysis
    case free
    case campaign
    case empty
    
    /// NOTE: add "collectionView.register(nibCell:" for new cell (or will be crash)
    var cellType: UICollectionViewCell.Type {
        switch self {
        case .analysis: return InstapickAnalysisCell.self
        case .free: return InstapickFreeCell.self
        case .campaign: return InstapickCampaignCell.self
        case .empty: return AnalyzeHistoryEmptyCell.self
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .analysis: return 126
        case .free: return 95
        case .campaign: return 178
        case .empty: return 108
        }
    }
}

private enum AnalyzeHistorySectionType: Int {
    case cards = 0
    case photos
    
    var numberOfColumns: CGFloat {
        return Device.isIpad ? 7 : 4
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
}

final class AnalyzeHistoryDataSourceForCollectionView: NSObject {
    
    private var collectionView: UICollectionView!
    
    private let sections: [AnalyzeHistorySectionType] = [.cards, .photos]
    
    private lazy var indexOfPhotoSection: Int? = {
        return sections.index(of: .photos)
    }()
    
    private var cards = [AnalyzeHistoryCardType]()
    private var items = [InstapickAnalyze]()
    private(set) var selectedItems = [InstapickAnalyze]()
    
    private(set) var analysisCount: InstapickAnalyzesCount?
    private var campaignCard: CampaignCardResponse?
    
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
        
        collectionView.register(nibCell: InstapickAnalyzeHistoryPhotoCell.self)
        collectionView.register(nibCell: InstapickAnalysisCell.self)
        collectionView.register(nibCell: InstapickFreeCell.self)
        collectionView.register(nibCell: InstapickCampaignCell.self)
        collectionView.register(nibCell: AnalyzeHistoryEmptyCell.self)
        
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
        cards = [analysisCount.isFree ? .free : .analysis]
        
        if campaignCard == nil {
            reloadSection(.cards)
        }
    }
    
    func showCampaignCard(with campaignCard: CampaignCardResponse) {
        self.campaignCard = campaignCard
        if !cards.contains(.campaign) {
            cards.append(.campaign)
        }
        reloadSection(.cards)
    }
    
    func reloadHistoryItems(_ newItems: [InstapickAnalyze]) {
        items = newItems
        reloadSection(.photos)
    }
    
    private func reloadSection(_ type: AnalyzeHistorySectionType) {
        guard let index = sections.index(of: type) else {
            return
        }

        self.collectionView.performBatchUpdates({
            self.collectionView.reloadSections(IndexSet(arrayLiteral: index))
        })
    }
    
    func appendHistoryItems(_ newItems: [InstapickAnalyze]) {
        guard !newItems.isEmpty else {
            isPaginationDidEnd = true
            return
        }
        mergeItems(with: newItems, insertFirst: false)
    }
    
    func insertNewItems(_ newItems: [InstapickAnalyze]) {
        mergeItems(with: newItems, insertFirst: true)
    }
    
    private func mergeItems(with newItems: [InstapickAnalyze], insertFirst: Bool) {
        guard let section = indexOfPhotoSection else {
            return
        }
        
        let uuids = items.map {$0.requestIdentifier}
        
        var insertIndexPaths = [IndexPath]()
        
        newItems.enumerated().forEach { index, item in
            if !uuids.contains(item.requestIdentifier) {
                if insertFirst {
                    insertIndexPaths.append(IndexPath(item: index, section: section))
                    self.items.insert(item, at: index)
                } else {
                    insertIndexPaths.append(IndexPath(item: items.count, section: section))
                    self.items.append(item)
                } 
            }
        }
        
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: insertIndexPaths)
        })
    }
    
    func deleteSelectedItems(completion: VoidHandler?) {
        guard let section = indexOfPhotoSection else {
            return
        }
        
        var deleteIndexPaths = [IndexPath]()
        selectedItems.forEach { item in
            if let index = self.items.index(of: item) {
                deleteIndexPaths.append(IndexPath(item: index, section: section))
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
    
    func showEmptyCard() {
        if !cards.contains(.empty) {
            cards.append(.empty)
        }
        reloadSection(.cards)
    }
}

// MARK: - UICollectionViewDataSource

extension AnalyzeHistoryDataSourceForCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .cards: return cards.count
        case .photos: return items.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .cards:
            return collectionView.dequeue(cell: cards[indexPath.item].cellType, for: indexPath)
        case .photos:
            return collectionView.dequeue(cell: InstapickAnalyzeHistoryPhotoCell.self, for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .cards:
            switch cards[indexPath.item] {
            case .analysis:
                if let cell = cell as? InstapickAnalysisCell, let count = analysisCount {
                    cell.setup(with: count)
                    cell.delegate = self
                }
            case .free, .empty:
                /// static card, nothing to setup
                break
            case .campaign:
                if let cell = cell as? InstapickCampaignCell,
                    let campaignCardResponse = campaignCard {
                    cell.setup(with: campaignCardResponse)
                }
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
        guard indexPath.section == indexOfPhotoSection else {
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
            delegate?.onSelectAnalyze(item)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AnalyzeHistoryDataSourceForCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = sections[indexPath.section]
        ///https://github.com/wordpress-mobile/WordPress-iOS/issues/10354
        ///seems like this bug may occur on iOS 12+ when it returns negative value
        switch section {
        case .cards:
            let cellWidth = max(collectionView.bounds.width, 0)
            
            switch cards[indexPath.item]  {
            case .analysis, .free:
                return CGSize(width: cellWidth, height: cards[indexPath.item].cellHeight)
                
            case .campaign:
                /// can be added heights cache.
                /// but will be need logic to invalidate it after campaignCard changes.
                guard let campaignCard = campaignCard else {
                    assertionFailure("campaignCard must exist if .campaign added")
                    return .zero
                }
                
                let cell = InstapickCampaignCell.initFromNib()
                cell.setup(with: campaignCard)
                /// "max" need to fix random number from "sizeToFit(width" (173.66 and 177.66)
                let height = max(cell.sizeToFit(width: cellWidth).height, AnalyzeHistoryCardType.campaign.cellHeight)
                return CGSize(width: cellWidth, height: height)
                
            case .empty:
                let cell = AnalyzeHistoryEmptyCell.initFromNib()
                let height = cell.sizeToFit(width: cellWidth).height
                return CGSize(width: cellWidth, height: height)
            }
            
        case .photos:
            var width = (collectionView.bounds.width - section.sectionInsets.left - section.sectionInsets.right - section.interitemSpacing * (section.numberOfColumns - 1)) / section.numberOfColumns
            width = max(width, 0)
            return CGSize(width: width, height: width + InstapickAnalyzeHistoryPhotoCell.underPhotoOffset)
        }
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
        delegate?.onSeeDetails()
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
