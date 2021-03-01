//
//  UploadProgressView.swift
//  Depo
//
//  Created by Konstantin Studilin on 26.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class UploadProgressView: UIView, FromNib {

    @IBOutlet private weak var progressBarHeader: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }
    
    //MARK: - Override
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        progressBarHeader.roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }

    //MARK: - Private
    
    private func setupCollectionView() {
        
    }
}
