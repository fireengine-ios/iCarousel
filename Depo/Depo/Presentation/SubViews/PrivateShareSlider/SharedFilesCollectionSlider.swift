//
//  SharedFilesCollectionSlider.swift
//  Depo
//
//  Created by Alex Developer on 23.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol SharedFilesCollectionSliderDelegate: class {
    func showAllPressed()
    
}

final class SharedFilesCollectionSliderView: UIView {
    
    @IBOutlet private weak var sliderLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaMedFont(size: 18)
            newValue.text = TextConstants.privateShareAllFilesSharedWithMe
            newValue.adjustsFontSizeToFitWidth = true
        }
    }

//    static let privateShareAllFilesMyFiles
    @IBOutlet private weak var showAllButton: UIButton! {
        willSet {
            newValue.titleLabel?.text = TextConstants.privateShareAllFilesSeeAll
            newValue.titleEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
            
            newValue.setImage(UIImage(named: "people"), for: .normal)
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    

    weak var delegate: SharedFilesCollectionSliderDelegate?
    
    @IBAction private func showAll(_ sender: Any) {
        delegate?.showAllPressed()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(SharedFilesSliderCell.self, forCellWithReuseIdentifier: "SharedFilesSliderCell")
//        collectionView.delegate = self
    }
    
    func setup(sliderCollectionDelegate: SharedFilesCollectionSliderDelegate?, collectionDataSource: UICollectionViewDataSource?, collectitonDelegate: UICollectionViewDelegate?) {
        delegate = sliderCollectionDelegate
        collectionView.dataSource = collectionDataSource
        collectionView.delegate = collectitonDelegate
        collectionView.reloadData()
    }

}
