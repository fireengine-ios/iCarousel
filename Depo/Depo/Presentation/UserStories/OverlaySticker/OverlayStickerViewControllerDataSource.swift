//
//  OverlayStickerViewControllerDataSource.swift
//  Depo
//
//  Created by Maxim Soldatov on 1/4/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol OverlayStickerViewControllerDataSourceDelegate: class {
    func didSelectItem(item: SmashStickerResponse, attachmentType: AttachedEntityType)
}

final class OverlayStickerViewControllerDataSource: NSObject {
        
    private final class State {
        var source = [SmashStickerResponse]()
        var page: Int = 0
        var collectionViewOffset: CGPoint = .zero
        var isPaginatingFinished = false
    }
    
    private let stickersCollectionView: UICollectionView
    
    private let paginationPageSize = 20
    private var isPaginating = false
    private var gifState = State()
    private var imageState = State()
    
    private var currentState: State {
        return selectedAttachmentType == .gif ?  gifState : imageState
    }
    
    private let stickerService: SmashService = SmashServiceImpl()
    private let overlayStickerDownloadManager = OverlayStickerDownloadManager()

    weak var delegate: OverlayStickerViewControllerDataSourceDelegate?
    
    private let operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        return operationQueue
    }()
    
    required init(collectionView: UICollectionView, delegate: OverlayStickerViewControllerDataSourceDelegate?) {
        self.stickersCollectionView = collectionView
        self.delegate = delegate
        super.init()
        self.setupCollectionView()
    }
    
    private func setupCollectionView() {
        stickersCollectionView.backgroundColor = ColorConstants.photoEditBackgroundColor
        let inset: CGFloat = Device.isIpad ? 20 : 16
        stickersCollectionView.contentInset = UIEdgeInsets(topBottom: 0, rightLeft: inset)
        stickersCollectionView.register(nibCell: StickerCollectionViewCell.self)
        if let layout = stickersCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 64, height: 64)
            layout.minimumLineSpacing = inset
        }
        stickersCollectionView.dataSource = self
        stickersCollectionView.delegate = self
        stickersCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private var selectedAttachmentType: AttachedEntityType = .gif {
        didSet {
            switch selectedAttachmentType {
            case .gif:

                imageState.collectionViewOffset = stickersCollectionView.contentOffset
                stickersCollectionView.reloadData()
                stickersCollectionView.contentOffset = gifState.collectionViewOffset
                stickersCollectionView.layoutIfNeeded()
                
            case .sticker:

                gifState.collectionViewOffset = stickersCollectionView.contentOffset
                
                if currentState.source.isEmpty {
                    loadNext()
                    
                } else {
                    stickersCollectionView.reloadData()
                    stickersCollectionView.contentOffset = imageState.collectionViewOffset
                    stickersCollectionView.layoutIfNeeded()
                }
            }
        }
    }
    
    func loadNext() {
        
        operationQueue.addOperation {  [weak self] in
            
            guard let self = self else {
                return
            }
            
            let selectedType: StickerType = self.selectedAttachmentType == .gif ? .gif : .image
            let selectedPage = self.currentState.page
            
            self.stickerService.getStickers(type: selectedType, page: selectedPage, size: self.paginationPageSize){ [weak self] result in
                
                guard let self = self else {
                    return
                }
                
                switch result {
                    
                case .success(let successResult):
                    let stickers = successResult.stickers
                    let type = successResult.type
                    
                    let isPaginatingFinished = (stickers.count < self.paginationPageSize)
                    
                    switch type {
                    case .gif:
                        self.gifState.page += 1
                        self.gifState.isPaginatingFinished = isPaginatingFinished
                        self.gifState.source.append(contentsOf: stickers)
                    case .image:
                        self.imageState.page += 1
                        self.imageState.isPaginatingFinished = isPaginatingFinished
                        self.imageState.source.append(contentsOf: stickers)
                    }
                    
                    DispatchQueue.main.async {
                        self.stickersCollectionView.reloadData()
                    }
                    
                case .failed(_):
                    break
                }
                
                self.isPaginating = false
            }
        }
    }
        
    func setStateForSelectedType(type: AttachedEntityType) {
        selectedAttachmentType = type
    }
}

//MARK: - UICollectionViewDataSource

extension OverlayStickerViewControllerDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentState.source.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: StickerCollectionViewCell.self, for: indexPath)
    }
}

//MARK: - UICollectionViewDelegate

extension OverlayStickerViewControllerDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? StickerCollectionViewCell,
              let object = currentState.source[safe: indexPath.row]
        else {
            return
        }

        cell.setup(with: object, type: selectedAttachmentType)        
        if selectedAttachmentType == .gif {
            overlayStickerDownloadManager.prepareGifForCell(url: object.path) {  image in
                DispatchQueue.main.async {
                    if collectionView.visibleCells.contains(cell) {
                        cell.setupGif(image: image, url: object.path)
                    }
                }
            }
        }
        
        let attachmentCount = currentState.source.count
        let isLastCell = (attachmentCount - 1 == indexPath.row)
        let isPaginatingFinished = currentState.isPaginatingFinished
        
        if isLastCell && !isPaginating && !isPaginatingFinished {
            isPaginating = true
            loadNext()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !currentState.source.isEmpty {
            let item = currentState.source[indexPath.row]
            delegate?.didSelectItem(item: item, attachmentType: selectedAttachmentType)
        }
    }
}
