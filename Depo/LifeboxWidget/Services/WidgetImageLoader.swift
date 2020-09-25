//
//  WidgetImageLoader.swift
//  LifeboxWidgetExtension
//
//  Created by Andrei Novikau on 9/21/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import Alamofire
import WidgetKit
import SDWebImage

protocol ImageCache {
    subscript(_ url: URL?) -> UIImage? { get set }
}

struct WidgetImageCache: ImageCache {
    static let shared = WidgetImageCache()
    private let cache = SDWebImageManager.shared().imageCache

    subscript(_ key: URL?) -> UIImage? {
        get { getImage(for: key) }
        set { save(image: newValue, url: key) }
    }
    
    private func getImage(for url: URL?) -> UIImage? {
        guard let path = url?.byTrimmingQuery?.absoluteString else {
            return nil
        }
        
        return cache?.imageFromCache(forKey: path)
    }
    
    private func save(image: UIImage?, url: URL?) {
        guard let path = url?.byTrimmingQuery?.absoluteString  else {
            return
        }
        
        if let image = image {
            cache?.store(image, forKey: path, completion: nil)
        } else {
            cache?.removeImage(forKey: path, withCompletion: nil)
        }
    }
}

final class WidgetImageLoader {
    
    private let cache = WidgetImageCache.shared
    private let imageProcessingQueue = DispatchQueue(label: DispatchQueueLabels.widgetImageLoaderQueue)
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .default
        queue.underlyingQueue = imageProcessingQueue
        return queue
    }()
    private var operations = [WidgetImageOperation]()
    
    func loadImage(urls: [URL?], completion: @escaping ValueHandler<[UIImage?]>) {
        var images = [UIImage?]()
        urls.forEach { url in
            if let url = url?.byTrimmingQuery {
                if let image = cache[url] {
                    images.append(image)
                } else {
                    images.append(nil)
                    let operation = WidgetImageOperation(url: url) { [weak self] operation in
                        guard let self = self else {
                            return
                        }
                        
                        if let index = self.operations.firstIndex(of: operation) {
                            self.operations.remove(at: index)
                        }
                        
                        if self.operations.isEmpty {
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }
                    operations.append(operation)
                    operationQueue.addOperation(operation)
                }
            } else {
                images.append(nil)
            }
        }
        completion(images)
    }
}

final class WidgetImageOperation: Operation {
    
    private let serverService = WidgetServerService.shared
    private var cache = WidgetImageCache.shared
    private let semaphore = DispatchSemaphore(value: 0)
    
    private var url: URL?
    private var task: URLSessionTask?
    private(set) var outputImage: UIImage?
    private var outputBlock: ValueHandler<WidgetImageOperation>?
    
    init(url: URL?, outputBlock: ValueHandler<WidgetImageOperation>?) {
        self.url = url
        self.outputBlock = outputBlock
        super.init()
    }
    
    override func cancel() {
        super.cancel()
    
        task?.cancel()
        outputBlock?(self)
    }
    
    override func main() {
        if let image = cache[url] {
            outputImage = image
            outputBlock?(self)
            return
        }
        
        guard let url = url?.byTrimmingQuery else {
            outputBlock?(self)
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
            
            self.outputImage = image
            self.cache[url] = image
            self.semaphore.signal()
        })
        
        semaphore.wait()
        outputBlock?(self)
    }
    
    private func cache(_ image: UIImage?) {
        guard let url = url?.byTrimmingQuery else {
            return
        }

        image.map { cache[url] = $0 }
    }
}
