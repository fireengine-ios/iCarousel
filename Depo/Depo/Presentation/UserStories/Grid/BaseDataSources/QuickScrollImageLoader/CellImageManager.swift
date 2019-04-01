//
//  CellImageManager.swift
//  Depo
//
//  Created by Konstantin on 10/4/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import SDWebImage
import MetalPetal

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
    
    private static let blurService = BlurService()
    
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
    
    private lazy var dispatchQueue = CellImageManager.globalDispatchQueue//DispatchQueue(label: "\(uniqueId)")
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
            
            let downloadOperation = ImageDownloadOperation(url: url, queue: self.dispatchQueue)
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
        
        let downloadThumbnailOperation = ImageDownloadOperation(url: thumbnail, queue: self.dispatchQueue)
        downloadThumbnailOperation.outputBlock = { [weak self] outputImage in
            guard let `self` = self, let outputImage = outputImage as? UIImage else {
                return
            }
            
            ///another guard in case if we want to save an unblurred thumbnail image
            guard let blurredImage = CellImageManager.blurService.blur(image: outputImage) else {
                return
            }
            
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


private final class BlurService {
    
    private var currentContext: MTIContext?
    private func getCurrentContext() -> MTIContext? {
        guard currentContext == nil else {
            return currentContext
        }

        let options = MTIContextOptions()
        guard let device = MTLCreateSystemDefaultDevice() else {
            return nil
        }

        currentContext = try? MTIContext(device: device, options: options)
        return currentContext
    }
    
    func blur(image: UIImage, radiusInPixels: Float = 2.0) -> UIImage? {
        guard let cgImage = image.cgImage,
            let context = getCurrentContext()
        else {
            return nil
        }
        
        let inputImage = MTIImage(cgImage: cgImage)
        
        let filter = MTIMPSGaussianBlurFilter()
        filter.radius = radiusInPixels
        filter.inputImage = inputImage
        
        guard let filteredImage = filter.outputImage else {
            return nil
        }
        
        do {
            let cgImage = try context.makeCGImage(from: filteredImage)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
}
