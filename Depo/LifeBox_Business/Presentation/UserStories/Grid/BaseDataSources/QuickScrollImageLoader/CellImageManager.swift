//
//  CellImageManager.swift
//  Depo
//
//  Created by Konstantin on 10/4/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import SDWebImage
//import MetalPetal

typealias CellImageManagerOperationsFinished = (_ image: UIImage?, _ cached: Bool, _ shouldBeBlurred: Bool, _ uuid: String?)->Void

enum ImageSize {
    case small
    case medium
    case large
    case original
    case preview
}

final class WrapDataUpdater {
    
    private let privateShareApiService = PrivateShareApiServiceImpl()
    
    private var task: URLSessionTask?
    
    deinit {
        task?.cancel()
    }
    
    func updateItem(_ item: Item, handler: @escaping ValueHandler<Item?>) {
        guard !item.isLocalItem, let accountUuid = item.accountUuid else {
            handler(nil)
            return
        }
        
        task = privateShareApiService.getSharingInfo(projectId: accountUuid, uuid: item.uuid) { result in
            switch result {
            case .success(let info):
                let item = WrapData(privateShareFileInfo: info)
                handler(item)
            case .failed(_):
                handler(nil)
            }
        }
    }
    
    func cancel() {
        task?.cancel()
    }
    
}

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
    
//    private static let blurService = BlurService()
    
    static func instance(by url: URL?) -> CellImageManager? {
        guard let url = url else {
            return nil
        }

        let newInstance = CellImageManager(with: url)
        return newInstance
    }
    
    static func clear() {
        globalDispatchQueue.async {
            globalOperationQueue.cancelAllOperations()
        }
    }
    
    //MARK: - Instance vars
    
    let uniqueId: String
    
    private lazy var dispatchQueue = CellImageManager.globalDispatchQueue//DispatchQueue(label: "\(uniqueId)")
    private lazy var operationQueue = CellImageManager.globalOperationQueue
    private lazy var processingQueue = CellImageManager.operationProcessingQueue
    private var currentOperation: Operation?
    private var isCancelled = false
    
    private let imageCache = SDWebImageManager.shared().imageCache
    private lazy var itemUpdater = WrapDataUpdater()
    private var completionBlock: CellImageManagerOperationsFinished?
    
    
    //MARK: - Interface
    
    required init(with key: URL) {
        uniqueId = key.absoluteString
    }
    
    func loadImage(item: Item, thumbnailUrl: URL?, url: URL?, completionBlock: @escaping CellImageManagerOperationsFinished) {
        if item.isOwner {
            loadImage(thumbnailUrl: thumbnailUrl, url: url, isOwner: item.isOwner, completionBlock: completionBlock)
        } else {
            let thumbnaiSize = getImageSizeFor(url: thumbnailUrl, item: item)
            if let imageSize = getImageSizeFor(url: url, item: item) {
                loadImage(item: item, thumbnaiSize: thumbnaiSize, imageSize: imageSize, completionBlock: completionBlock)
            } else {
                completionBlock(nil, false, false, uniqueId)
            }
        }
    }
    
    func loadImage(item: Item, thumbnaiSize: ImageSize?, imageSize: ImageSize, completionBlock: @escaping CellImageManagerOperationsFinished) {
        let url = item.imageUrl(size: imageSize)

        if item.isOwner || url?.isExpired == false {
            let thumbnailUrl = thumbnaiSize != nil ? item.imageUrl(size: thumbnaiSize!) : nil
            loadImage(thumbnailUrl: thumbnailUrl, url: url, isOwner: item.isOwner, completionBlock: completionBlock)
        } else {
            itemUpdater.updateItem(item) { [weak self] item in
                if let item = item {
                    let thumbnailUrl = thumbnaiSize != nil ? item.imageUrl(size: thumbnaiSize!) : nil
                    let url = item.imageUrl(size: imageSize)
                    self?.loadImage(thumbnailUrl: thumbnailUrl, url: url, isOwner: item.isOwner, completionBlock: completionBlock)
                }
            }
        }
    }
    
    func loadImage(thumbnailUrl: URL?, url: URL?, isOwner: Bool, completionBlock: @escaping CellImageManagerOperationsFinished) {
        isCancelled = false
        dispatchQueue.async { [weak self] in
            self?.completionBlock = completionBlock
            self?.setupOperations(thumbnail: thumbnailUrl, url: url, isOwner: isOwner)
        }
    }
    
    func cancelImageLoading() {
        isCancelled = true
        itemUpdater.cancel()
        
        dispatchQueue.async { [weak self] in
            self?.currentOperation?.cancel()
            self?.currentOperation = nil
        }
    }
    
    
    //MARK: - Private
    
    private func setupOperations(thumbnail: URL?, url: URL?, isOwner: Bool) {
        ///check if image is already downloaded with url
        if let image = getImageFromCache(url: url) {
            completionBlock?(image, true, false, uniqueId)
            return
        }
        
        ///prepare download operation for url
        let downloadImage = { [weak self] in
            guard let self = self else { return }

            guard let url = isOwner ? url?.byTrimmingQuery : url else {
                self.completionBlock?(nil, false, false, self.uniqueId)
                return
            }
            
            let downloadOperation = ImageDownloadOperation(url: url, queue: self.processingQueue)
            //DEVELOP let downloadOperation = ImageDownloadOperation(url: url, queue: self.dispatchQueue)
            downloadOperation.outputBlock = { [weak self] outputImage, _ in
                guard let self = self else {
                    return
                }
                
                if let outputImage = outputImage {
                    self.cache(image: outputImage, url: url.byTrimmingQuery)
                }
                
                self.completionBlock?(outputImage, false, false, self.uniqueId)
            }
            
            self.start(operation: downloadOperation)
        }
        
        ///check if image is already downloaded with thumbnail url
        guard let thumbnail = isOwner ? thumbnail?.byTrimmingQuery : thumbnail else {
            downloadImage()
            return
        }
        
        if let cachedThumbnail = getImageFromCache(url: thumbnail) {
            completionBlock?(cachedThumbnail, true, true, uniqueId)
            downloadImage()
            return
        }
        
        let downloadThumbnailOperation = ImageDownloadOperation(url: thumbnail, queue: self.processingQueue)
        //DEVELOP let downloadThumbnailOperation = ImageDownloadOperation(url: thumbnail, queue: self.dispatchQueue)
        downloadThumbnailOperation.outputBlock = { [weak self] outputImage, _ in
            guard let self = self, let outputImage = outputImage as? UIImage else {
                downloadImage()
                return
            }

            self.cache(image: outputImage, url: thumbnail.byTrimmingQuery)
            self.completionBlock?(outputImage, false, true, self.uniqueId)

            downloadImage()
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
    
    //MARK: - Helper
    
    private func getImageSizeFor(url: URL?, item: Item) -> ImageSize? {
        if url == item.metaData?.largeUrl {
            return .large
        } else if url == item.metaData?.mediumUrl {
            return .medium
        } else if url == item.metaData?.smalURl {
            return .small
        } else if url == item.urlToFile {
            return .original
        } else if case PathForItem.remoteUrl(let remoteUrl) = item.patchToPreview, remoteUrl == url {
            return .preview
        }
        return nil
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


//private final class BlurService {
//    
//    private static let blurQueue = DispatchQueue(label: DispatchQueueLabels.blurServiceQueue)
//    private var currentContext: MTIContext?
//    private func getCurrentContext() -> MTIContext? {
//        guard currentContext == nil else {
//            return currentContext
//        }
//
//        let options = MTIContextOptions()
//        guard let device = MTLCreateSystemDefaultDevice() else {
//            return nil
//        }
//
//        currentContext = try? MTIContext(device: device, options: options)
//        return currentContext
//    }
//    
//    func blur(image: UIImage, radiusInPixels: Float = 2.0, completion: @escaping (_ image: UIImage?) -> Void) {
//        #if targetEnvironment(simulator)
//        completion(image)
//        #endif
//        
//        if MTIContext.defaultMetalDeviceSupportsMPS {
//            completion(blurWithMetal(image: image, radiusInPixels: radiusInPixels))
//        } else {
//            blurWithGPU(image: image, radiusInPixels: radiusInPixels, completion: completion)
//        }
//    }
//    
//    func blurWithMetal(image: UIImage, radiusInPixels: Float = 2.0) -> UIImage? {
//        guard let cgImage = image.cgImage,
//            let context = getCurrentContext()
//        else {
//            return nil
//        }
//        
//        let inputImage = MTIImage(cgImage: cgImage).unpremultiplyingAlpha()
//        
//        let filter = MTIMPSGaussianBlurFilter()
//        filter.radius = radiusInPixels
//        filter.inputImage = inputImage
//        
//        guard let filteredImage = filter.outputImage else {
//            return nil
//        }
//        
//        do {
//            let cgImage = try context.makeCGImage(from: filteredImage)
//            return UIImage(cgImage: cgImage)
//        } catch {
//            return nil
//        }
//    }
//    
//    func blurWithGPU(image: UIImage, radiusInPixels: Float = 2.0, completion: @escaping (_ image: UIImage?) -> Void) {
//        DispatchQueue.main.async {
//            //fix crash - https://developer.apple.com/library/archive/qa/qa1766/_index.html
//            guard UIApplication.shared.applicationState == .active else {
//                completion(image)
//                return
//            }
//            
//            BlurService.blurQueue.async {
//                let filter = GPUImageGaussianBlurFilter()
//                filter.blurRadiusInPixels = CGFloat(radiusInPixels)
//                completion(filter.image(byFilteringImage: image))
//            }
//        }
//    }
//}
