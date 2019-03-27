//
//  ImageDownloadOperation.swift
//  Depo
//
//  Created by Konstantin on 10/4/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire


final class ImageDownloadOperation: Operation {
    
    var outputBlock: ((AnyObject?) -> Void)?
    
    private let semaphore = DispatchSemaphore(value: 0)
    private var url: URL?
    private var task: URLSessionTask?
    private let queue: DispatchQueue
    
    init(url: URL?, queue: DispatchQueue) {
        self.url = url
        self.queue = queue
        super.init()
    }
    
    override func cancel() {
        super.cancel()
        
        task?.cancel()
        task = nil
        outputBlock?(nil)
        semaphore.signal()
    }
    
    override func main() {
        guard !isCancelled else {
            return
        }
        
        guard let trimmedURL = url?.byTrimmingQuery else {
            outputBlock?(nil)
            return
        }
        
        task = SessionManager.customDefault.request(trimmedURL)
            .customValidate()
            .responseData(queue: queue, completionHandler: { [weak self] dataResponse in
                guard let self = self, !self.isCancelled else {
                    return
                }
                
                guard let data = dataResponse.value, let image = UIImage(data: data) else {
                    self.outputBlock?(nil)
                    self.semaphore.signal()
                    return
                }
                
                self.outputBlock?(image)
                self.semaphore.signal()
            })
            .task

        semaphore.wait()
    }
}
