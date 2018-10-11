//
//  ImageDownloadOperation.swift
//  Depo
//
//  Created by Konstantin on 10/4/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


final class ImageDownloadOperation: Operation, DataTransferrableOperation {
    
    var inputData: AnyObject?
    private (set) var outputData: AnyObject?
    
    private let semaphore = DispatchSemaphore(value: 0)
    private var url: URL?
    private let downloader = ImageDownloder()
    
    
    init(url: URL?) {
        self.url = url
        
        super.init()
    }
    
    
    override func cancel() {
        if let url = url {
            downloader.cancelRequest(path: url)
        }
        semaphore.signal()
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        downloader.getImage(patch: url) { [weak self] image in
            self?.outputData = image
            self?.semaphore.signal()
        }
        
        semaphore.wait()
    }
}
