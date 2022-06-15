//
//  PrivateShareDurationView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShareDurationView: UIView, NibInit {
    
    //MARK: -IBOutlet
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.privateShareStartPageDurationTitle
            newValue.font = UIFont.appFont(.medium, size: 14)
            newValue.textColor = AppColor.filesLabel.color
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    //MARK: -Properties
    private let durations = PrivateShareDuration.allCases
    var duration: PrivateShareDuration {
        if let selectedIndex = collectionView.indexPathsForSelectedItems?.first?.item {
            return durations[selectedIndex]
        }
        return .no
    }
    
    private var selectedCellIndexPath: IndexPath? = IndexPath(item: 0, section: 0) {
        didSet {
            collectionView.reloadData()
        }
    }
    
    //MARK: -Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    //MARK: -Helpers
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(nibCell: PrivateShareDurationCell.self)
        collectionView.allowsSelection = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(topBottom: 0, rightLeft: 16)
        
        if let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewFlowLayout.scrollDirection = .horizontal
            collectionViewFlowLayout.estimatedItemSize = CGSize(width: 80, height: 56)
            collectionViewFlowLayout.minimumLineSpacing = 0
        }
        
        collectionView.reloadData()
    }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PrivateShareDurationView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        durations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: PrivateShareDurationCell.self, for: indexPath)
        cell.setup(with: durations[indexPath.item])
        cell.setSelection(isSelected: indexPath == selectedCellIndexPath)
        return cell
    }
}

extension PrivateShareDurationView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeue(cell: PrivateShareDurationCell.self, for: indexPath)
        selectedCellIndexPath = indexPath
        cell.setSelection(isSelected: true)
    }
}
