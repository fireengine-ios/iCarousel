//
//  UploadQueueService.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/28/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Alamofire

typealias HandlerShareData = (_ shareData: ShareData) -> Void

final class UploadQueueService {
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private var error: Error?
    
    func cancelAll() {
        queue.cancelAllOperations()
    }
    
    func addShareData(_ shareDataArray: [ShareData],
                      progressHandler: @escaping Request.ProgressHandler,
                      finishedUpload: HandlerShareData? = nil,
                      didStartUpload: HandlerShareData? = nil,
                      complition: @escaping ResponseVoid) {
        
        let operations: [Operation] = shareDataArray.flatMap { shareData in
            
            return UploadOperation(url: shareData.url, contentType: shareData.contentType, progressHandler: progressHandler, didStartUpload: {
                didStartUpload?(shareData)
            }, complition: { [weak self] result in
                
                guard let `self` = self else {
                    return
                }
                
                switch result {
                case .success(_):
                    progressHandler(Progress(totalUnitCount: 1))
                    
                case .failed(let error):
                    self.error = error
                    self.queue.cancelAllOperations()
                }
                finishedUpload?(shareData)
            })
        }
        
        addOperations(operations, complition: complition)
    }
    
    func addOperations(_ operations: [Operation], complition: @escaping ResponseVoid) {
        queue.addOperations(operations, waitUntilFinished: true)
        
        if let error = error {
            complition(ResponseResult.failed(error))
            self.error = nil
        } else {
            complition(ResponseResult.success(()))
        }
    }
}
