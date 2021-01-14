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

    @IBOutlet weak var myFilesLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaMedFont(size: 18)
            newValue.text = TextConstants.privateShareAllFilesMyFiles
            newValue.adjustsFontSizeToFitWidth = true
        }
    }
    
    
    @IBOutlet private weak var showAllButton: UIButton! {
        willSet {
            newValue.setImage(UIImage(named: "privateSharePeople"), for: .normal)
            newValue.setTitle(TextConstants.privateShareAllFilesSeeAll, for: .normal)
            newValue.setTitleColor(ColorConstants.textGrayColor, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaRegFont(size: 18)      
            
            newValue.forceImageToRightSide()
            newValue.imageEdgeInsets.left = -10
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            newValue.contentInset = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
        }
    }

    weak var delegate: SharedFilesCollectionSliderDelegate?
    
    private lazy var analytics = PrivateShareAnalytics()
    
    @IBAction private func showAll(_ sender: Any) {
        delegate?.showAllPressed()
        analytics.openAllSharedFiles()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(nibCell: SharedFilesSliderCell.self)
        collectionView.register(nibCell: SharedFilesSliderPlusCell.self)
    }
    
    func reloadData() {
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func setup(sliderCollectionDelegate: SharedFilesCollectionSliderDelegate?, collectionDataSource: UICollectionViewDataSource?, collectitonDelegate: UICollectionViewDelegate?) {
        delegate = sliderCollectionDelegate
        collectionView.dataSource = collectionDataSource
        collectionView.delegate = collectitonDelegate
        reloadData()
    }
}
