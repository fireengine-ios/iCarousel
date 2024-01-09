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
    typealias ImageDownloadOperationCallback = ((UIImage?, Data?) -> Void)
    var outputBlock: ImageDownloadOperationCallback?
    
    private let semaphore = DispatchSemaphore(value: 0)
    private var url: URL?
    ///It is possible that when we use Alamofire Request and then directly cancel task it might causecurrentServerEnvironment bug for Alamofire.
    private var task: URLSessionTask?
    private let queue: DispatchQueue
    private let isErrorLogEnabled: Bool
    
    init?(url: URL?, queue: DispatchQueue, isErrorLogEnabled: Bool = false) {
        guard let safeUrl = url else {
            print("Error: URL nil")
            return nil
        }
        self.url = safeUrl
        self.queue = queue
        self.isErrorLogEnabled = isErrorLogEnabled
        super.init()
        
    }
    
    init?(url: URL?, queue: DispatchQueue, completion: ImageDownloadOperationCallback?, isErrorLogEnabled: Bool = false) {
        guard let safeUrl = url else {
            print("Error: URL nil")
            return nil
        }
        self.url = safeUrl
        self.queue = queue
        self.outputBlock = completion
        self.isErrorLogEnabled = isErrorLogEnabled
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
        // Potential crash-fix (DE-12449)
        defer { outputBlock = nil }

        guard !isCancelled else {
            return
        }
        
        guard let url = url else {
            outputBlock?(nil, nil)
            return
        }
        
        var outputImage: UIImage?
        var outputData: Data?
        
        task = SessionManager.customDefault.request(url)
            .customValidate()
            .responseData(queue: queue, completionHandler: { [weak self] dataResponse in
                guard let self = self else {
                    return
                }
                guard !self.isCancelled else {
                    self.semaphore.signal()
                    return
                }
            
                if dataResponse.result.isFailure {
                    self.logError(dataResponse)
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
        
        outputBlock?(outputImage, outputData)
    }
    
    private func formattedImage(data: Data?) -> UIImage? {
        var image: UIImage?
        if let data = data {
            let format = ImageFormat.get(from: data)
            switch format {
            case .gif:
                image = try? UIImage(gifData: data)
            default:
                image = UIImage(data: data)
            }
        }
        
        return image
    }
}

extension ImageDownloadOperation {
    private func logError(_ response: DataResponse<Data>) {
        guard isErrorLogEnabled else {
            return
        }
        
        guard let code = response.response?.statusCode,
              let url = response.response?.url,
              let error = response.error else {
            return
        }
    
        debugLog("Load image error [\(url.absoluteString)] - \(code): \(error.description)")
    }
}
