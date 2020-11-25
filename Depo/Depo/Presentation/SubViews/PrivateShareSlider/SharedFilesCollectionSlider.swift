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

final class SharedFilesCollectionSliderView: UIView, NibInit {
    
    @IBOutlet private weak var sliderLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaMedFont(size: 18)
            newValue.text = TextConstants.privateShareAllFilesSharedWithMe
            newValue.adjustsFontSizeToFitWidth = true
        }
    }

    @IBOutlet private weak var showAllButton: UIButton! {
        willSet {
            newValue.titleLabel?.text = TextConstants.privateShareAllFilesSeeAll
            newValue.titleEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
            
            newValue.setImage(UIImage(named: "people"), for: .normal)
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            newValue.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
    }

    weak var delegate: SharedFilesCollectionSliderDelegate?
    
    @IBAction private func showAll(_ sender: Any) {
        delegate?.showAllPressed()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(nibCell: SharedFilesSliderCell.self)
    }
    
    func setup(sliderCollectionDelegate: SharedFilesCollectionSliderDelegate?, collectionDataSource: UICollectionViewDataSource?, collectitonDelegate: UICollectionViewDelegate?) {
        delegate = sliderCollectionDelegate
        collectionView.dataSource = collectionDataSource
        collectionView.delegate = collectitonDelegate
//        collectionView.collectionViewLayout.
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }

}

extension SharedFilesCollectionSliderView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 112)
    }
}
