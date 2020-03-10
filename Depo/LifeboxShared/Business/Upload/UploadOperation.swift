//
//  UploadOperation.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/28/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

final class UploadOperation: Operation {
    
    typealias InterruptedInfo = (identifier: String, interruptedId: String)
    
    private lazy var uploadService = UploadService()
    
    private let sharedItem: SharedItemSource
    private let progressHandler: Request.ProgressHandler
    private let didStartUpload: VoidHandler?
    private let complition: ResponseVoid
    private var dataRequest: DataRequest?
    
    private var chunker: DataChunkProvider?
    private let resumableUploadInfoService = ResumableUploadInfoService.shared
    private var isResumable = false
    private var interruptedInfo: InterruptedInfo?
    
    private let semaphore = DispatchSemaphore(value: 0)
    private let attemptWaitSeconds = 5
    private let attemptsMax = 5
    private var attempts = 0
    
    init(sharedItem: SharedItemSource,
         progressHandler: @escaping Request.ProgressHandler,
         didStartUpload: VoidHandler?,
         complition: @escaping ResponseVoid) {
        self.sharedItem = sharedItem
        self.progressHandler = progressHandler
        self.didStartUpload = didStartUpload
        self.complition = complition
        
        super.init()
    }
    
    
    //MARK: - Override
    
    override func cancel() {
        super.cancel()
        dataRequest?.cancel()
    }
    
    // TODO: add with right handlers
//    if isCancelled {
//        return
//    }
    override func main() {
        didStartUpload?()
        upload()
    }
    
    
    //MARK: - General
    
    private func upload() {
        
        let completion: ResponseVoid = { [weak self] result in
            
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(_):
                if let identifier = self.interruptedInfo?.identifier {
                    self.resumableUploadInfoService.removeInterruptedId(for: identifier)
                }
                self.complition(result)
                self.semaphore.signal()
                
            case .failed(let error):
                if error.isNetworkError, self.attempts < self.attemptsMax {
                    DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(self.attemptWaitSeconds)) {
                        self.attempts += 1
                        self.upload()
                    }
                } else {
                    self.complition(result)
                    self.semaphore.signal()
                }
            }
            
        }
        
        let dataRequestHandler: DataRequestHandler = { [weak self] dataRequest in
            self?.dataRequest = dataRequest
        }
        
        let preparationHandler: ResponseVoid = { [weak self] result  in
            switch result {
            case .success(_):
                if self?.isResumable == true {
                    self?.resumableUpload(dataRequestHandler: dataRequestHandler, completion: completion)
                } else {
                    self?.simpleUpload(dataRequestHandler: dataRequestHandler, completion: completion)
                }
                
            case .failed(let error):
                completion(.failed(error))
            }
        }
        
        switch sharedItem {
        case .url(let item):
            prepareFileForUpload(url: item.url, completion: preparationHandler)
            
        case .data(let item):
            prepareDataForUpload(data: item.data, completion: preparationHandler)
        }

        semaphore.wait()
    }
    
    private func prepareDataForUpload(data: Data, completion: @escaping ResponseVoid) {
        let fileSize = data.count
        
        guard fileSize < NumericConstants.fourGigabytes else {
            let error = CustomErrors.text(TextConstants.syncFourGbVideo)
            completion(.failed(error))
            return
        }
        
        guard fileSize > 0 else {
            assertionFailure(TextConstants.syncZeroBytes)
            let error = CustomErrors.text(TextConstants.syncZeroBytes)
            completion(.failed(error))
            return
        }
        
        isResumable = resumableUploadInfoService.isResumableUploadAllowed(with: Int64(fileSize))
        
        completion(.success(()))
    }
    
    private func prepareFileForUpload(url: URL, completion: @escaping ResponseVoid) {
        FilesExistManager.shared.waitFilePreparation(at: url) { [weak self] result in
            switch result {
            case .success(_):
                guard
                    let fileSize = FileManager.default.fileSize(at: url),
                    fileSize < NumericConstants.fourGigabytes
                else {
                    let error = CustomErrors.text(TextConstants.syncFourGbVideo)
                    completion(.failed(error))
                    return
                }
                
                guard fileSize > 0 else {
                    assertionFailure(TextConstants.syncZeroBytes)
                    let error = CustomErrors.text(TextConstants.syncZeroBytes)
                    completion(.failed(error))
                    return
                }
                
                self?.isResumable = resumableUploadInfoService.isResumableUploadAllowed(with: fileSize)
                
                completion(.success(()))
                
            case .failed(let error):
                completion(.failed(error))
            }
        }
    }
    
    
    //MARK: - Simple
    
    private func simpleUpload(dataRequestHandler: @escaping DataRequestHandler, completion: @escaping ResponseVoid) {
        switch sharedItem {
        case .url(let item):
            uploadService.upload(url: item.url,
                                 name: item.name,
                                 contentType: item.contentType,
                                 progressHandler: progressHandler,
                                 dataRequestHandler: dataRequestHandler,
                                 completion: completion)
        case .data(let item):
            uploadService.upload(data: item.data,
                                 name: item.name,
                                 contentType: item.contentType,
                                 progressHandler: progressHandler,
                                 dataRequestHandler: dataRequestHandler,
                                 completion: completion)
        }
    }
    
    
    //MARK: - Resumable
    
    private func resumableUpload(dataRequestHandler: @escaping DataRequestHandler, completion: @escaping ResponseVoid) {
        
        prepareInterruptedInfo()
        
        let bufferCapacity = resumableUploadInfoService.chunkSize
        
        switch sharedItem {
        case .url(let item):
            chunker = DataChunkProviderFactory.createWithSource(source: item.url, bufferCapacity: bufferCapacity)
            attemptResumableUpload(item: item, dataRequestHandler: dataRequestHandler, completion: completion)
            
        case .data(let item):
            chunker = DataChunkProviderFactory.createWithSource(source: item.data, bufferCapacity: bufferCapacity)
            attemptResumableUpload(item: item, dataRequestHandler: dataRequestHandler, completion: completion)
        }
    }
    
    private func prepareInterruptedInfo(newInterruptedId: String? = nil) {
        switch sharedItem {
        case .url(let item):
            if let identifier = item.url.byTrimmingQuery?.path,
                let interruptedId = newInterruptedId ?? resumableUploadInfoService.getInterruptedId(for: identifier) {
                
                interruptedInfo = (identifier, interruptedId)
            }
            
        case .data(let item):
            let identifier = item.name + "\(item.data.count)"
            
            if let interruptedId = newInterruptedId ?? resumableUploadInfoService.getInterruptedId(for: identifier) {
                interruptedInfo = (identifier, interruptedId)
            }
        }
        
        if let info = interruptedInfo {
            resumableUploadInfoService.save(interruptedId: info.interruptedId, for: info.identifier)
        }
    }
    

    private func attemptResumableUpload(item: SharedItem, dataRequestHandler: @escaping DataRequestHandler, completion: @escaping ResponseVoid) {
        
        guard let interruptedId = interruptedInfo?.interruptedId else {
            let newId = UUID().uuidString
            prepareInterruptedInfo(newInterruptedId: newId)
            uploadContiniously(item: item, interruptedId: newId, dataRequestHandler: dataRequestHandler, completion: completion)
            return
        }
        
        uploadService.checkResumableUploadStatus(interruptedId: interruptedId, name: item.name, contentType: item.contentType, dataRequestHandler: dataRequestHandler) { [weak self] result in
            switch result {
            case .failed(let error):
                completion(.failed(error))
                
            case .success(let status):
                switch status {
                case .completed:
                    completion(.success(()))
                    
                case .didntStart:
                    self?.uploadContiniously(item: item, interruptedId: interruptedId, dataRequestHandler: dataRequestHandler, completion: completion)
                    
                case .uploaded(bytes: let bytes):
                    guard let nextChunk = self?.chunker?.nextChunk(skipping: bytes) else { completion(.failed(CustomErrors.text(TextConstants.commonServiceError)))
                        return
                    }
                    
                    self?.uploadContiniously(item: item, interruptedId: interruptedId, chunk: nextChunk, dataRequestHandler: dataRequestHandler, completion: completion)
                    
                case .discontinuityError, .invalidUploadRequest:
                    self?.resumableUpload(dataRequestHandler: dataRequestHandler, completion: completion)
                }
            }
        }
    }
    
    private func uploadContiniously(item: SharedItem, interruptedId: String, chunk: DataChunk? = nil, dataRequestHandler: @escaping DataRequestHandler, completion: @escaping ResponseVoid) {
        
        guard let nextChunk = chunk != nil ? chunk : chunker?.nextChunk() else {
            completion(.failed(CustomErrors.text(TextConstants.commonServiceError)))
            return
        }
        
        uploadService.resumableUpload(interruptedId: interruptedId, data: nextChunk.data, range: nextChunk.range, name: item.name, contentType: item.contentType, fileSize: 0, dataRequestHandler: dataRequestHandler) { [weak self] result in
            switch result {
            case .failed(let error):
                completion(.failed(error))
                
            case .success(let status):
                switch status {
                case .completed:
                    completion(.success(()))
                    
                case .didntStart:
                    completion(.failed(CustomErrors.text(TextConstants.commonServiceError)))
                    
                case .uploaded(bytes: _):
                    self?.attempts = 0
                    self?.uploadContiniously(item: item, interruptedId: interruptedId, dataRequestHandler: dataRequestHandler, completion: completion)
                    
                case .discontinuityError, .invalidUploadRequest:
                    self?.resumableUpload(dataRequestHandler: dataRequestHandler, completion: completion)
                }
            }
        }
    }
    
}
