//
//  WidgetImageLoader.swift
//  LifeboxWidgetExtension
//
//  Created by Andrei Novikau on 9/21/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import Alamofire

protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

struct WidgetImageCache: ImageCache {
    static let shared = WidgetImageCache()
    private let cache = NSCache<NSURL, UIImage>()

    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

final class WidgetImageLoader {
    
    private let imageProcessingQueue = DispatchQueue(label: DispatchQueueLabels.widgetImageLoaderQueue)
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .default
        queue.underlyingQueue = imageProcessingQueue
        return queue
    }()
    
    func loadImage(urls: [URL?], completion: @escaping ValueHandler<[UIImage?]>) {
        var images = [UIImage?]()
        urls.forEach { url in
            let operation = WidgetImageOperation(url: url) { [weak self] image in
                images.append(image)
                if self?.operationQueue.operationCount == 0 {
                    completion(images)
                }
            }
            operationQueue.addOperation(operation)
        }
    }
}

final class WidgetImageOperation: Operation {
    
    private let serverService = WidgetServerService.shared
    private var cache = WidgetImageCache.shared
    private let semaphore = DispatchSemaphore(value: 0)
    
    private var url: URL?
    private var task: URLSessionTask?
    private var outputBlock: ValueHandler<UIImage?>?
    
    init(url: URL?, outputBlock: ValueHandler<UIImage?>?) {
        self.url = url
        self.outputBlock = outputBlock
        super.init()
    }
    
    override func cancel() {
        super.cancel()
    
        task?.cancel()
        outputBlock?(nil)
    }
    
    override func main() {
        guard let url = url?.byTrimmingQuery else {
            outputBlock?(nil)
            return
        }
        
        var outputImage: UIImage?
        
        if let image = cache[url] {
            outputImage = image
            outputBlock?(outputImage)
            return
        }
        
        task = serverService.loadImage(url: url, completion: { [weak self] image in
            guard let self = self else {
                return
            }
            guard !self.isCancelled else {
                self.semaphore.signal()
                return
            }
            
            outputImage = image
            if let image = image {
                self.cache(image)
            }

            self.semaphore.signal()
        })
        
        semaphore.wait()
        outputBlock?(outputImage)
    }
    
    private func cache(_ image: UIImage?) {
        guard let url = url?.byTrimmingQuery else {
            return
        }

        image.map { cache[url] = $0 }
    }
}
