//
//  OverlayStickerDownloadManager.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class OverlayStickerDownloadManager: NSObject {
    
    private let optimizingGifService = OptimizingGifService()
    private let downloader = ImageDownloder()
    
    private let gifOptimizationQueue: OperationQueue =  {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        return queue
    }()
    
    private var stickers = SynchronizedDictionary<URL, UIImage>()
    
    func prepareGifForCell(url: URL, completion: @escaping (UIImage) -> Void) {
        
        if let image = stickers[url] {
            completion(image)
        } else {
            downloadSticker(url: url) { [weak self] gifData in
                self?.optimazeGifData(gifData: gifData, completion: { [weak self] gifImage in
                    self?.stickers[url] = gifImage
                    completion(gifImage)
                })
            }
        }
    }
    
    private func downloadSticker(url: URL, completion: @escaping RemoteData) {
        downloader.getImageData(url: url, completeData: completion)
    }
    
    private func optimazeGifData(gifData: Data?, completion: @escaping (UIImage) -> Void) {
        gifOptimizationQueue.addOperation {
            guard
                let imageData = gifData,
                let image = self.optimizingGifService.optimizeImage(data: imageData, optimizeFor: .cell)
            else {
                return
            }
            completion(image)
        }
    }
}
