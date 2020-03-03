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
    
    private lazy var uploadService = UploadService()
    
    private let sharedItem: SharedItemSource
    private let progressHandler: Request.ProgressHandler
    private let didStartUpload: VoidHandler?
    private let complition: ResponseVoid
    private var dataRequest: DataRequest?
    private var chunker: DataChunkProvider?
    
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
    
    // TODO: add with right handlers
//    if isCancelled {
//        return
//    }
    override func main() {
        didStartUpload?()
        upload()
    }
    
    private func upload() {
        
        let completion: ResponseVoid = { [weak self] result in
            
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(_):
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
        
        semaphore.wait()
    }
    
    override func cancel() {
        super.cancel()
        dataRequest?.cancel()
    }
    
}
