//
//  ImageDownloadOperation.swift
//  Depo
//
//  Created by Konstantin on 10/4/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire
import SDWebImage


final class ImageDownloadOperation: Operation, SDWebImageOperation {
    typealias ImageDownloadOperationCallback = ((AnyObject?, Data?) -> Void)
    var outputBlock: ImageDownloadOperationCallback?
    
    private let semaphore = DispatchSemaphore(value: 0)
    private var url: URL?
    ///It is possible that when we use Alamofire Request and then directly cancel task it might cause bug for Alamofire.
    private var task: URLSessionTask?
    private let queue: DispatchQueue
    private let logErrors: Bool
    
    init(url: URL?, queue: DispatchQueue, logErrors: Bool = false) {
        self.url = url
        self.queue = queue
        self.logErrors = logErrors
        super.init()
    }
    
    init(url: URL?, queue: DispatchQueue, completion: ImageDownloadOperationCallback?, logErrors: Bool = false) {
        self.url = url
        self.queue = queue
        self.outputBlock = completion
        self.logErrors = logErrors
        super.init()
    }
    
    override func cancel() {
        super.cancel()
        
        DispatchQueue.main.async {
            self.task?.cancel()
            self.task = nil
        }
//        semaphore.signal()
    }
    
    override func main() {
        guard !isCancelled else {
            return
        }
        
        guard let trimmedURL = url?.byTrimmingQuery else {
            outputBlock?(nil, nil)
            return
        }
        
        var outputImage: UIImage?
        var outputData: Data?
        
        task = SessionManager.customDefault.request(trimmedURL)
            .customValidate()
            .responseData(queue: queue, completionHandler: { [weak self] dataResponse in
                guard let self = self else {
                    return
                }
                guard !self.isCancelled else {
                    self.semaphore.signal()
                    return
                }
                
                if self.logErrors, let error = dataResponse.error {
                    debugLog("Load image error - \(error.description)")
                }
                
                guard
                    let data = dataResponse.value,
                    let image = self.formattedImage(data: data)
                else {
                    self.semaphore.signal()
                    return
                }
                
                outputImage = image
                outputData = data
                self.semaphore.signal()
            })
            .task
        
        task?.priority = URLSessionTask.lowPriority
        
        semaphore.wait()
        
        defer {
            task?.cancel()
            outputBlock?(outputImage, outputData)
            semaphore.signal()
        }
    }
    
    private func formattedImage(data: Data?) -> UIImage? {
        var image: UIImage?
        if let data = data {
            let format = ImageFormat.get(from: data)
            switch format {
            case .gif:
                image = UIImage(gifData: data)
            default:
                image = UIImage(data: data)
            }
        }
        
        return image
    }
}
