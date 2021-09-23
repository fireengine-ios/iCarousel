//
//  PrivateShareDurationView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShareDurationView: UIView, NibInit {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.privateShareStartPageDurationTitle
            newValue.font = .TurkcellSaturaBolFont(size: 16)
            newValue.textColor = AppColor.marineTwoAndWhite.color
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let durations = PrivateShareDuration.allCases
    var duration: PrivateShareDuration {
        if let selectedIndex = collectionView.indexPathsForSelectedItems?.first?.item {
            return durations[selectedIndex]
        }
        return .no
    }
    
    //MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.register(nibCell: PrivateShareDurationCell.self)
        collectionView.allowsSelection = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(topBottom: 0, rightLeft: 16)
        
        if let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewFlowLayout.scrollDirection = .horizontal
            collectionViewFlowLayout.estimatedItemSize = CGSize(width: 80, height: 25)
            collectionViewFlowLayout.minimumLineSpacing = 4
        }
        
        collectionView.reloadData()
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
    }
    
    //MARK: - Public
}

//MARK: - UICollectionViewDataSource

extension PrivateShareDurationView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        durations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: PrivateShareDurationCell.self, for: indexPath)
        cell.setup(with: durations[indexPath.item])
        return cell
    }
}
