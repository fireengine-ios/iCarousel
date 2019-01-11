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
    func onSeeDetailsForAnanyze(_ analyze: InstapickAnalyze)
}

final class AnalyzeHistoryDataSourceForCollectionView: NSObject {
    
    private var collectionView: UICollectionView!
    
    private var items = [InstapickAnalyze]()
    
    private var analysisCount = InstapickAnalysisCount(left: 0, total: 0) {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
            }
        }
    }
    
    private var isSelectionStateActive = false
    
    var isPaginationDidEnd = false
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    weak var delegate: AnalyzeHistoryDataSourceDelegate?
    
    // MARK: - Functions
    
    func setupCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
        
        collectionView.register(nibCell: CollectionViewCellForInstapickPhoto.self)
        collectionView.register(nibCell: CollectionViewCellForInstapickAnalysis.self)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func reloadCards(with analysisCount: InstapickAnalysisCount) {
        self.analysisCount = analysisCount
    }
    
    func appendHistoryItems(_ newItems: [InstapickAnalyze]) {
        if items.isEmpty {
            items = newItems
            collectionView.reloadData()
        } else {
            mergeItems(with: newItems)
        }

        isPaginationDidEnd = newItems.isEmpty
    }
    
    private func mergeItems(with newItems: [InstapickAnalyze]) {
        let uuids = items.map {$0.requestIdentifier}
        
        var insertIndexPaths = [IndexPath]()
        
        newItems.forEach { item in
            if !uuids.contains(item.requestIdentifier) {
                insertIndexPaths.append(IndexPath(item: items.count, section: 1))
                self.items.append(item)
            }
        }
        
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: insertIndexPaths)
        })
    }
}

// MARK: - UICollectionViewDataSource

extension AnalyzeHistoryDataSourceForCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            return collectionView.dequeue(cell: CollectionViewCellForInstapickAnalysis.self, for: indexPath)
        } else {
            return collectionView.dequeue(cell: CollectionViewCellForInstapickPhoto.self, for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            (cell as? CollectionViewCellForInstapickAnalysis)?.setup(with: analysisCount)
            (cell as? CollectionViewCellForInstapickAnalysis)?.delegate = self
        } else {
            (cell as? CollectionViewCellForInstapickPhoto)?.setup(with: items[indexPath.item])
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
    
    private func analyzeForCell(_ cell: UICollectionViewCell) -> InstapickAnalyze? {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return nil
        }
        return items[safe: indexPath.item]
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AnalyzeHistoryDataSourceForCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: collectionView.bounds.width, height: 126)
        } else {
            return CGSize(width: 80, height: 108)
        }
    }
}

// MARK: - InstapickAnalysisCellDelegate

extension AnalyzeHistoryDataSourceForCollectionView: InstapickAnalysisCellDelegate {
    func onPurchase() {
        delegate?.onPurchase()
    }
    
    func onSeeDetails(cell: UICollectionViewCell) {
        if let analyze = analyzeForCell(cell) {
            delegate?.onSeeDetailsForAnanyze(analyze)
        }
    }
    
    func canLongPress() -> Bool {
        return true
    }
    
    func onLongPress(cell: UICollectionViewCell) {
        if !isSelectionStateActive {
            delegate?.onLongPressInCell()
        }
    }
}
