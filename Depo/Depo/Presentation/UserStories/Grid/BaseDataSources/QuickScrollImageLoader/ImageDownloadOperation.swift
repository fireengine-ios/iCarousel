//
//  ImageDownloadOperation.swift
//  Depo
//
//  Created by Konstantin on 10/4/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import SDWebImage


final class ImageDownloadOperation: Operation, DataTransferrableOperation {
    
    var inputData: AnyObject?
    private (set) var outputData: AnyObject?
    
    private let semaphore = DispatchSemaphore(value: 0)
    private var url: URL?
    private var task: URLSessionTask?
    private var imageCache = SDWebImageManager.shared().imageCache
    
    
    init(url: URL?) {
        self.url = url
        
        super.init()
    }
    
    
    override func cancel() {
        super.cancel()
        
        task?.cancel()
        semaphore.signal()
    }
    
    override func main() {
        guard !isCancelled, let url = url, let cacheKey = url.byTrimmingQuery?.absoluteString else {
            return
        }

        if let image = imageCache?.imageFromCache(forKey: cacheKey) {
            outputData = image
            return
        }
        
        guard !isCancelled else {
            return
        }
        
        task = URLSession.sharedCustom.dataTask(with: url) { [weak self] data, response, error in
            if let data = data, let image = UIImage(data: data), let `self` = self {
                self.outputData = image
                
                self.imageCache?.store(image, forKey: cacheKey, completion: nil)
            }
            
            self?.semaphore.signal()
        }
        
        task?.resume()
        
        semaphore.wait()
    }
}


extension URLSession {
    static let sharedCustom: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        return URLSession(configuration: config)
    }()
}
