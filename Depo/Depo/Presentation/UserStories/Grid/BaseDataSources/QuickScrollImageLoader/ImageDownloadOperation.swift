//
//  ImageDownloadOperation.swift
//  Depo
//
//  Created by Konstantin on 10/4/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


final class ImageDownloadOperation: Operation {
    
    var outputBlock: ((AnyObject?) -> Void)?
    
    private let semaphore = DispatchSemaphore(value: 0)
    private var url: URL?
    private var task: URLSessionTask?
    
    
    init(url: URL?) {
        self.url = url
        
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
        guard !isCancelled else { return }
        
        guard let url = url else {
            outputBlock?(nil)
            return
        }
        
        task = URLSession.sharedCustom.dataTask(with: url) { [weak self] data, _, error in
            guard let `self` = self, !self.isCancelled else { return }
            
            if error == nil, let data = data, let image = UIImage(data: data) {
                self.outputBlock?(image)
            } else {
                self.outputBlock?(nil)
            }
            self.semaphore.signal()
        }
        
        task?.resume()
        
        semaphore.wait()
    }
}


private extension URLSession {
    static let sharedCustom: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        return URLSession(configuration: config)
    }()
}
