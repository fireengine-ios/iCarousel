//
//  UploadProgressView.swift
//  Depo
//
//  Created by Konstantin Studilin on 26.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol UploadProgressViewDelegate: class {
    func show(isMinified: Bool)
}

final class UploadProgressView: UIView, FromNib {

    @IBOutlet private weak var progressHeaderContainer: UIView! {
        willSet {
            newValue.clipsToBounds = true
        }
    }
    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            newValue.allowsSelection = false
            newValue.isScrollEnabled = true
            newValue.alwaysBounceVertical = true
            newValue.alwaysBounceHorizontal = false
        }
    }
    
    private lazy var collectionManager = UploadProgressCollectionManager.with(collectionView: collectionView)
    private lazy var progressHeader = UploadProgressHeader.initFromNib()
    
    private(set) var isMinified = false {
        didSet {
            delegate?.show(isMinified: isMinified)
        }
    }
    
    weak var delegate: UploadProgressViewDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        setupHeader()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        setupHeader()
    }
    
    //MARK: - Override
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        progressHeaderContainer.roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }
    
    private func setupHeader() {
        progressHeader.delegate = self
        progressHeaderContainer.addSubview(progressHeader)
        progressHeader.translatesAutoresizingMaskIntoConstraints = false
        progressHeader.pinToSuperviewEdges()
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
        collectionManager.setProgress(item: item, ratio: ratio)
    }
    
    func cleanAll() {
        collectionManager.clean()
        progressHeader.clean()
    }
    
    func setUploadProgress(uploaded: Int, total: Int) {
        progressHeader.set(uploaded: uploaded, total: total)
    }
}


extension UploadProgressView: UploadProgressHeaderDelegate {
    func onActionButtonTap() {
        isMinified = !isMinified
    }
}
