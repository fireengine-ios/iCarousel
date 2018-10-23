//
//  CellImageManager.swift
//  Depo
//
//  Created by Konstantin on 10/4/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


typealias CellImageManagerOperationsFinished = (_ image: UIImage?, _ cached: Bool, _ uuid: String?)->Void


protocol DataTransferrableOperation: class {
    var inputData: AnyObject? { get set}
    var outputData: AnyObject? { get }
}


final class CellImageManager {
    
    private enum ImageProcessingState {
        case unprocessed
        case thumbnailReady
        case mediumReady
    }
    
    //MARK: - Static vars
    private static let maxConcurrentOperations = Device.isIpad ? 96 : 32
    private static let globalDispatchQueue = DispatchQueue(label: DispatchQueueLabels.cellImageManagerQueue)
    
    private static let globalOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = maxConcurrentOperations
        queue.qualityOfService = .userInteractive
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
            instances.removeAll()
            globalOperationQueue.cancelAllOperations()
        }
    }
    
    //MARK: - Instance vars
    
    private var completionBlock: CellImageManagerOperationsFinished?

    private lazy var operationQueue = CellImageManager.globalOperationQueue
    private lazy var dispatchQueue = CellImageManager.globalDispatchQueue

    private (set) var uniqueId: String = UUID().uuidString
    private var myOperationsOrdered = [Operation]()
    
    private var lastSavedImage: UIImage?
    private var processingState: ImageProcessingState = .unprocessed
    
    
    //MARK: - Interface
    
    func loadImage(thumbnailUrl: URL?, url: URL?, completionBlock: @escaping CellImageManagerOperationsFinished) {
        dispatchQueue.async { [weak self] in
            self?.completionBlock = completionBlock
            self?.setupOperations(thumbnail: thumbnailUrl, url: url)
        }
    }
    
    func cancelImageLoading() {
        dispatchQueue.async { [weak self] in
            self?.myOperationsOrdered.forEach { $0.cancel() }
            self?.myOperationsOrdered.removeAll()
        }
    }
    
    
    //MARK: - Private
    
    private func setupOperations(thumbnail: URL?, url: URL?) {
        guard processingState != .mediumReady else {
            completionBlock?(lastSavedImage, true, uniqueId)
            return
        }
        
        let downloadMediumOperation = ImageDownloadOperation(url: url)
        let doneMediumOperation = BlockOperation { [weak self, unowned downloadMediumOperation] in
            if let uuid = self?.uniqueId, let outputImage = downloadMediumOperation.outputData as? UIImage {
                if downloadMediumOperation.name == self?.uniqueId {
                    self?.lastSavedImage = outputImage
                    self?.processingState = .mediumReady
                    self?.completionBlock?(outputImage, true, uuid)
                }
            }
        }
        
        guard processingState != .thumbnailReady else {
            completionBlock?(lastSavedImage, true, uniqueId)
            myOperationsOrdered = [downloadMediumOperation, doneMediumOperation]
            startOperations()
            return
        }
        
        let downloadThumbnailOperation = ImageDownloadOperation(url: thumbnail)
        ///Testing default blur effect
//        let blurOperation = ImageBlurOperation()
//        let adapter = generateAdapterBlockOperation(dependent: blurOperation, dependency: downloadThumbnailOperation)
        let doneThumbnailOperation = BlockOperation { [weak self, unowned downloadThumbnailOperation] in
            if let outputImage = downloadThumbnailOperation.outputData as? UIImage {
                if let uuid = self?.uniqueId, downloadThumbnailOperation.name == self?.uniqueId {
                    self?.lastSavedImage = outputImage
                    self?.processingState = .thumbnailReady
                    self?.completionBlock?(outputImage, false, uuid)
                } else {
                    self?.cancelImageLoading()
                }
            }
        }
        
        myOperationsOrdered = [downloadThumbnailOperation, doneThumbnailOperation, downloadMediumOperation, doneMediumOperation]
        ///Testing default blur effect
//        myOperationsOrdered = [downloadThumbnailOperation, adapter, blurOperation, doneThumbnailOperation, downloadMediumOperation, doneMediumOperation]
        startOperations()
    }
    
    private func startOperations() {
        setDependecies(ordered: myOperationsOrdered)
        name(operations: myOperationsOrdered)
        operationQueue.addOperations(myOperationsOrdered, waitUntilFinished: false)
    }
}



//MARK: - Helpers
extension CellImageManager {
    
    ///in order to transfer data between operations
    private func generateAdapterBlockOperation(dependent: DataTransferrableOperation, dependency: DataTransferrableOperation) -> BlockOperation {
        return BlockOperation { [unowned dependent, unowned dependency] in
            if type(of: dependent.inputData) == type(of: dependency.outputData) {
                dependent.inputData = dependency.outputData
            }
        }
    }
    
    ///ordered by prioriy: first-to-run...last-to-run
    private func setDependecies(ordered: [Operation]) {
        guard ordered.count > 1 else {
            return
        }
        
        for i in 0...ordered.count-2 {
            let firstOp = ordered[i]
            let secondOp = ordered[i+1]
            secondOp.addDependency(firstOp)
        }
    }
    
    private func name(operations: [Operation]) {
        operations.forEach { $0.name = uniqueId }
    }
    
}
