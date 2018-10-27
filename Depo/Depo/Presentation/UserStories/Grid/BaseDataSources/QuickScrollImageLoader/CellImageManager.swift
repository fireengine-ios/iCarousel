//
//  CellImageManager.swift
//  Depo
//
//  Created by Konstantin on 10/4/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import SDWebImage


typealias CellImageManagerOperationsFinished = (_ image: UIImage?, _ cached: Bool, _ uuid: String?)->Void


final class CellImageManager {
    
    //MARK: - Static vars
    private static let maxConcurrentOperations = 32
    private static let globalDispatchQueue = DispatchQueue(label: DispatchQueueLabels.cellImageManagerQueue)
    
    private static let globalOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = maxConcurrentOperations
        queue.qualityOfService = .default
        return queue
    }()

    
    private static var instances = [URL : CellImageManager]()
    
    static func instance(by url: URL?) -> CellImageManager? {
        guard let url = url else {
            return nil
        }
        
        if let instance = instances[url] {
            return instance
        }
        
        let newInstance = CellImageManager()
        instances[url] = newInstance
        return newInstance
    }
    
    static func clear() {
        globalDispatchQueue.async {
            globalOperationQueue.cancelAllOperations()
            instances.removeAll()
        }
    }
    
    
    //MARK: - Instance vars
    
    let uniqueId: String = UUID().uuidString
    
    private lazy var dispatchQueue = DispatchQueue(label: "\(uniqueId)")
    private lazy var operationQueue = CellImageManager.globalOperationQueue
    private var currentOperation: Operation?
    
    private let imageCache = SDWebImageManager.shared().imageCache
    
    private var completionBlock: CellImageManagerOperationsFinished?
    
    
    //MARK: - Interface
    
    func loadImage(thumbnailUrl: URL?, url: URL?, completionBlock: @escaping CellImageManagerOperationsFinished) {
        dispatchQueue.async { [weak self] in
            self?.completionBlock = completionBlock
            self?.setupOperations(thumbnail: thumbnailUrl, url: url)
        }
    }
    
    func cancelImageLoading() {
        dispatchQueue.async { [weak self] in
            self?.currentOperation?.cancel()
            self?.currentOperation = nil
        }
    }
    
    
    //MARK: - Private
    
    private func setupOperations(thumbnail: URL?, url: URL?) {
        ///check if image is already downloaded with url
        if let image = getImageFromCache(url: url) {
            completionBlock?(image, true, uniqueId)
            return
        }
        
        ///prepare download operation for url
        let downloadImage = { [weak self] in
            guard let `self` = self else { return }
            
            let downloadOperation = ImageDownloadOperation(url: url)
            downloadOperation.outputBlock = { [weak self] outputImage in
                guard let `self` = self, let outputImage = outputImage as? UIImage else { return }
                
                self.cache(image: outputImage, url: url)
                self.completionBlock?(outputImage, false, self.uniqueId)
            }
            
            self.start(operation: downloadOperation)
        }
        
        ///check if image is already downloaded with thumbnail url
        if let image = getImageFromCache(url: thumbnail) {
            completionBlock?(image, true, uniqueId)
            downloadImage()
            return
        }
        
        let downloadThumbnailOperation = ImageDownloadOperation(url: thumbnail)
        downloadThumbnailOperation.outputBlock = { [weak self] outputImage in
            guard let `self` = self, let outputImage = outputImage as? UIImage else { return }
            
            ///another guard in case if we want to save an unblurred thumbnail image
            guard let blurredImage = outputImage.blurred() else { return }
            
            self.cache(image: blurredImage, url: thumbnail)
            self.completionBlock?(blurredImage, false, self.uniqueId)
            
            downloadImage()
        }
        downloadThumbnailOperation.queuePriority = .high
        start(operation: downloadThumbnailOperation)
    }
    
    private func start(operation: Operation) {
        currentOperation = operation
        operationQueue.addOperation(operation)
    }
}



//MARK: - Cache
extension CellImageManager {
    
    private func getImageFromCache(url: URL?) -> UIImage? {
        guard let cacheKey = url?.byTrimmingQuery?.absoluteString else {
            return nil
        }
        
        return imageCache?.imageFromCache(forKey: cacheKey)
    }
    
    private func cache(image: UIImage, url: URL?) {
        guard let cacheKey = url?.byTrimmingQuery?.absoluteString else {
            return
        }
        
        imageCache?.store(image, forKey: cacheKey, completion: nil)
    }
}
