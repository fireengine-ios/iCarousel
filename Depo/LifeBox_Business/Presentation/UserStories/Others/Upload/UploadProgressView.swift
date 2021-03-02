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
    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            newValue.allowsSelection = false
            newValue.isScrollEnabled = true
            newValue.alwaysBounceVertical = true
            newValue.alwaysBounceHorizontal = false
        }
    }
    
    private lazy var collectionManager = UploadProgressCollectionManager.with(collectionView: collectionView)
    
    
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
}


extension UploadProgressView: UploadProgressManagerDelegate {
    func append(items: [UploadProgressItem]) {
        collectionManager.append(items: items)
    }
    
    func remove(items: [UploadProgressItem]) {
        collectionManager.remove(items: items)
    }
    
    func update(item: UploadProgressItem) {
        collectionManager.update(item: item)
    }
    
    func setUploadProgress(for item: UploadProgressItem, bytesUploaded: Int, ratio: Float) {
        //TODO:
    }
    
    func cleanAll() {
        collectionManager.clean()
    }
}
