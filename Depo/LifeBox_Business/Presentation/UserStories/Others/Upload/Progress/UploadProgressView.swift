//
//  UploadProgressView.swift
//  Depo
//
//  Created by Konstantin Studilin on 26.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol UploadProgressViewDelegate: class {
    func update()
}

final class UploadProgressView: UIView, FromNib {

    @IBOutlet private weak var progressHeaderContainer: UIView! {
        willSet {
            newValue.clipsToBounds = true
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            newValue.backgroundColor = ColorConstants.UploadProgress.cellBackground.color
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
            delegate?.update()
        }
    }
    
    private(set) var isClosed = true {
        didSet {
            delegate?.update()
        }
    }
    
    var contentHeight: CGFloat {
        return CGFloat(collectionManager.numberOfItems) * UploadProgressCell.height
    }
    
    weak var delegate: UploadProgressViewDelegate?
    
    //MARK: - Override
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        progressHeaderContainer.roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }
    
    //MARK: - Private
    
    private func setupHeader() {
        progressHeader.delegate = self
        progressHeaderContainer.addSubview(progressHeader)
        progressHeader.translatesAutoresizingMaskIntoConstraints = false
        progressHeader.pinToSuperviewEdges()
    }
}


extension UploadProgressView: UploadProgressManagerDelegate {
    func append(items: [UploadProgressItem]) {
        isClosed = false
        let addedTotal = items.reduce(0) { $0 + ($1.item?.fileSize ?? 0) }.intValue
        progressHeader.addTo(totalBytes: addedTotal)
        collectionManager.append(items: items)
        delegate?.update()
    }
    
    func remove(item: UploadProgressItem) {
        let removedTotal = item.item?.fileSize.intValue ?? 0
        progressHeader.addTo(totalBytes: -removedTotal)
        collectionManager.remove(item: item)
        delegate?.update()
    }
    
    func update(item: UploadProgressItem) {
        if item.status.isContained(in: [.failed, .completed]) {
            progressHeader.addTo(uploadedBytesStable: item.item?.fileSize.intValue ?? 0)
        }
        collectionManager.update(item: item)
    }
    
    func setUploadProgress(for item: UploadProgressItem, bytesUploaded: Int, ratio: Float) {
        progressHeader.addTo(uploadedBytesProgress: bytesUploaded)
        collectionManager.setProgress(item: item, ratio: ratio)
    }
    
    func cleanAll() {
        isClosed = true
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
