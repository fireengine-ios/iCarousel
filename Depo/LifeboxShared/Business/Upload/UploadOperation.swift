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
    
    private let url: URL
    private let contentType: String
    private let progressHandler: Request.ProgressHandler
    private let didStartUpload: VoidHandler?
    private let complition: ResponseVoid
    private var dataRequest: DataRequest?
    
    private let semaphore = DispatchSemaphore(value: 0)
    private let attemptWaitSeconds = 5
    private let attemptsMax = 5
    private var attempts = 0
    
    init(url: URL,
         contentType: String,
         progressHandler: @escaping Request.ProgressHandler,
         didStartUpload: VoidHandler?,
         complition: @escaping ResponseVoid) {
        self.url = url
        self.contentType = contentType
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
        uploadService.upload(url: url, contentType: contentType, progressHandler: progressHandler, dataRequestHandler: { [weak self] dataRequest in
            self?.dataRequest = dataRequest
        }, completion: { [weak self] result in
            
            guard let `self` = self else {
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
        })
        semaphore.wait()
    }
    
    override func cancel() {
        super.cancel()
        dataRequest?.cancel()
    }
}
