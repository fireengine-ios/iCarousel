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
        var isPaginatingFinished: Bool = false
    }
    
    @IBOutlet private weak var stickersCollectionView: UICollectionView!
    
    private let downloader = ImageDownloder()
    private let optimizingGifService = OptimizingGifService()
    
    private let paginationPageSize = 20
    private var isPaginating = false
    private var gifState = State()
    private var imageState = State()
    
    private var currentState: State {
        return selectedAttachmentType == .gif ?  gifState : imageState
    }
    
    private let stickerService: SmashService = SmashServiceImpl()
    
    weak var delegate: OverlayStickerViewControllerDataSourceDelegate?
    
    private let operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        return operationQueue
    }()
    
    private var selectedAttachmentType: AttachedEntityType = .gif {
        didSet {
            switch selectedAttachmentType {
            case .gif:

                imageState.collectionViewOffset = stickersCollectionView.contentOffset
                stickersCollectionView.reloadData()
                stickersCollectionView?.contentOffset = gifState.collectionViewOffset
                stickersCollectionView.layoutIfNeeded()
                
            case .image:

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
                    
                    DispatchQueue.toMain {
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
        switch type {
        case .gif:
            selectedAttachmentType = .gif
        case .image:
            selectedAttachmentType = .image
        }
    }
    
    private func downloadGifForCell(cell: StickerCollectionViewCell, url: URL) {
    
        downloader.getImageData(url: url) { [weak self] data in
            DispatchQueue.global().async {
                guard let imageData = data, let image = self?.optimizingGifService.optimizeImage(data: imageData, optimizeFor: .cell) else {
                    return
                }
                
                DispatchQueue.toMain {
                    cell.setupGif(image: image, url: url)
                }
            }
        }
    }
}

extension OverlayStickerViewControllerDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentState.source.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: StickerCollectionViewCell.self, for: indexPath)
    }
}

extension OverlayStickerViewControllerDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? StickerCollectionViewCell,
              let object = currentState.source[safe: indexPath.row]
        else {
            return
        }

        cell.setup(with: object, type: selectedAttachmentType)        
        if selectedAttachmentType == .gif {
            downloadGifForCell(cell: cell, url: object.path)
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
