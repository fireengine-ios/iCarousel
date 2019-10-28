//
//  UploadQueueService.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/28/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Alamofire

typealias ShareDataHandler = (SharedItem2) -> Void

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
    
    func addShareData(_ shareDataArray: [SharedItem2],
                      progress: @escaping Request.ProgressHandler,
                      finishedUpload: ShareDataHandler? = nil,
                      didStartUpload: ShareDataHandler? = nil,
                      complition: @escaping ResponseVoid) {
        
        let operations: [Operation] = shareDataArray.flatMap { shareData in
            
            UploadOperation(url: shareData.url, contentType: shareData.contentType, progressHandler: progress, didStartUpload: {
                didStartUpload?(shareData)
            }, complition: { [weak self] result in
                
                guard let `self` = self else {
                    return
                }
                
                switch result {
                case .success(_):
                    progress(Progress(totalUnitCount: 1))
                    
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
