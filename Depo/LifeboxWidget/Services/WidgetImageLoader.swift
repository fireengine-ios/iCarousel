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

final class WidgetImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private static let imageProcessingQueue = DispatchQueue(label: DispatchQueueLabels.widgetImageLoaderQueue)
    private let serverService = WidgetServerService.shared
    private var cache = WidgetImageCache.shared
    
    private let url: URL?
    private var cancellable: URLSessionTask?
    
    private(set) var isLoading = false

    init(url: URL?) {
        self.url = url
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    func load() {
        guard !isLoading, let url = url else { return }
        
        if let image = cache[url] {
            self.image = image
            return
        }
        
        isLoading = true
        cancellable = serverService.loadImage(url: url, completion: { [weak self] image in
            guard let image = image else {
                return
            }
            self?.isLoading = false
            self?.cache(image)
            self?.image = image
        })
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    private func cache(_ image: UIImage?) {
        guard let url = url else {
            return
        }
        
        image.map { cache[url] = $0 }
    }
}
