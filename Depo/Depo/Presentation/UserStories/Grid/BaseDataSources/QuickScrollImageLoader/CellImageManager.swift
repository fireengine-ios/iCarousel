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
    private static let globalDispatchQueue = DispatchQueue(label: DispatchQueueLabels.cellImageManagerQueue, attributes: .concurrent)
    private static let operationProcessingQueue = DispatchQueue(label: DispatchQueueLabels.cellImageManagerOperationQueue, attributes: .concurrent)
    
    private static let globalOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = maxConcurrentOperations
        queue.qualityOfService = .default
        queue.underlyingQueue = operationProcessingQueue
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
    private lazy var processingQueue = CellImageManager.operationProcessingQueue
    private var currentOperation: Operation?
    private var isCancelled = false
    
    private let imageCache = SDWebImageManager.shared().imageCache
    
    private var completionBlock: CellImageManagerOperationsFinished?
    
    
    //MARK: - Interface
    
    func loadImage(thumbnailUrl: URL?, url: URL?, completionBlock: @escaping CellImageManagerOperationsFinished) {
        dispatchQueue.async { [weak self] in
            self?.isCancelled = false
            self?.completionBlock = completionBlock
            self?.setupOperations(thumbnail: thumbnailUrl, url: url)
        }
    }
    
    func cancelImageLoading() {
        dispatchQueue.async { [weak self] in
            self?.isCancelled = true
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

            guard let url = url else {
                self.completionBlock?(nil, false, self.uniqueId)
                return
            }
            
            let downloadOperation = ImageDownloadOperation(url: url, queue: self.processingQueue)
            //DEVELOP let downloadOperation = ImageDownloadOperation(url: url, queue: self.dispatchQueue)
            downloadOperation.outputBlock = { [weak self] outputImage in
                guard let `self` = self, let outputImage = outputImage as? UIImage else { return }
                
                self.cache(image: outputImage, url: url)
                self.completionBlock?(outputImage, false, self.uniqueId)
            }
            
            self.start(operation: downloadOperation)
        }
        
        ///check if image is already downloaded with thumbnail url
        guard let thumbnail = thumbnail else {
            downloadImage()
            return
        }
        
        if let image = getImageFromCache(url: thumbnail) {
            completionBlock?(image, true, uniqueId)
            downloadImage()
            return
        }
        
        let downloadThumbnailOperation = ImageDownloadOperation(url: thumbnail, queue: self.processingQueue)
        //DEVELOP let downloadThumbnailOperation = ImageDownloadOperation(url: thumbnail, queue: self.dispatchQueue)
        downloadThumbnailOperation.outputBlock = { [weak self] outputImage in
            guard let outputImage = outputImage as? UIImage else {
                return
            }
            
            CellImageManager.blurService.blur(image: outputImage, completion: { [weak self] blurredImage in
                self?.processingQueue.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    ///another guard in case if we want to save an unblurred thumbnail image
                    guard let blurredImage = blurredImage else {
                        self.completionBlock?(outputImage, false, self.uniqueId)
                        downloadImage()
                        return
                    }
                    
                    self.cache(image: blurredImage, url: thumbnail)
                    self.completionBlock?(blurredImage, false, self.uniqueId)
                    
                    downloadImage()
                }
            })
        }
        downloadThumbnailOperation.queuePriority = .high
        start(operation: downloadThumbnailOperation)
    }
    
    private func start(operation: Operation) {
        guard !isCancelled else {
            return
        }
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
    
    private static let blurQueue = DispatchQueue(label: DispatchQueueLabels.blurServiceQueue)
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
    
    func blur(image: UIImage, radiusInPixels: Float = 2.0, completion: @escaping (_ image: UIImage?) -> Void) {
        #if targetEnvironment(simulator)
        completion(image)
        #endif
        
        if MTIContext.defaultMetalDeviceSupportsMPS {
            completion(blurWithMetal(image: image, radiusInPixels: radiusInPixels))
        } else {
            blurWithGPU(image: image, radiusInPixels: radiusInPixels, completion: completion)
        }
    }
    
    func blurWithMetal(image: UIImage, radiusInPixels: Float = 2.0) -> UIImage? {
        guard let cgImage = image.cgImage,
            let context = getCurrentContext()
        else {
            return nil
        }
        
        let inputImage = MTIImage(cgImage: cgImage).unpremultiplyingAlpha()
        
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
    
    func blurWithGPU(image: UIImage, radiusInPixels: Float = 2.0, completion: @escaping (_ image: UIImage?) -> Void) {
        DispatchQueue.main.async {
            //fix crash - https://developer.apple.com/library/archive/qa/qa1766/_index.html
            guard UIApplication.shared.applicationState == .active else {
                completion(image)
                return
            }
            
            BlurService.blurQueue.async {
                let filter = GPUImageGaussianBlurFilter()
                filter.blurRadiusInPixels = CGFloat(radiusInPixels)
                completion(filter.image(byFilteringImage: image))
            }
        }
    }
}
