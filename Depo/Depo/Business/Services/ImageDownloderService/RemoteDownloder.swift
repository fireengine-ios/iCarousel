//
//  RemoteDownloder.swift
//  Depo
//
//  Created by Alexander Gurin on 7/12/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SDWebImage

class ImageDownloder {
    
    static func removeImagesFromCache(urls: [URL?], completion: @escaping VoidHandler) {
        let existedUrls = urls.compactMap { $0 }
        
        guard !existedUrls.isEmpty else {
            completion()
            return
        }
        
        let group = DispatchGroup()
        existedUrls.forEach {
            group.enter()
            
            removeImageFromCache(url: $0) {
                group.leave()
            }
        }
        
        group.notify(queue: .main, execute: completion)
    }
    
    static func replaceImagesInCache(urls: [URL], images: [UIImage], completion: @escaping VoidHandler) {
        guard !urls.isEmpty, urls.count == images.count else {
            completion()
            return
        }
        
        removeImagesFromCache(urls: urls) {
            let group = DispatchGroup()
            
            for i in 0..<urls.count {
                group.enter()
                guard let cachePath = urls[i].byTrimmingQuery?.absoluteString else {
                    //TODO: check if it's possible that group will notify earlier
                    group.leave()
                    return
                }
                
                let image = images[i]
                SDWebImageManager.shared().imageCache?.store(image, forKey: cachePath, completion: {
                    group.leave()
                })
            }
            
            group.notify(queue: .main, execute: completion)
        }
    }
    
    static func removeImageFromCache(url: URL?, completion: @escaping VoidHandler) {
        guard
            let trimmedUrl = url?.byTrimmingQuery?.absoluteString,
            let imageCache = SDWebImageManager.shared().imageCache
        else {
            completion()
            return
        }
        
        imageCache.removeImage(forKey: trimmedUrl, withCompletion: completion)
    }
    
    
    
    private let downloder: SDWebImageDownloader
    
    private var tokenList = SynchronizedDictionary<URL,SDWebImageOperation>()
    
    var isErrorLogEnabled = false
    
    init() {
        downloder = SDWebImageManager.shared().imageDownloader!
    }
    
    func getImage(patch: URL?, completeImage:@escaping RemoteImage) {
        
        guard let path = patch, let cachePath = path.byTrimmingQuery?.absoluteString else {
            DispatchQueue.main.async {
                completeImage(nil)
            }
            return
        }
        
        
        if let image = SDWebImageManager.shared().imageCache?.imageFromCache(forKey: cachePath) {
            DispatchQueue.main.async {
                completeImage(image)
            }
            return
        }
        
        let item = downloder.downloadImage(with: patch,
                                           options: [.lowPriority/*,.useNSURLCache*/],
                                           progress: nil) { image, data, error, bool in
                                            if let image = image {
                                                SDWebImageManager.shared().imageCache?.store(image, forKey: cachePath, completion: nil)
                                            }
                                            
                                            completeImage(image)
        }
        
        guard let downloadItem = item else {
            return
        }
        
        tokenList = tokenList + [path : downloadItem]
    }
    
    func getImageData(url: URL?, completeData:@escaping RemoteData) {
        
        guard let path = url else {
            logError(message: "getImageData failed - invalid url")
            
            DispatchQueue.main.async {
                completeData(nil)
            }
            return
        }
        
        guard path.byTrimmingQuery?.absoluteString != nil else {
            logError(message: "getImageData failed - invalid trimmed url")
            
            DispatchQueue.main.async {
                completeData(nil)
            }
            return
        }
        
        let item = SDWebImageManager.shared().loadImage(with: path, options: [], progress: nil) { [weak self] _,data, error ,cacheType,_,imageUrl in
            DispatchQueue.main.async {
                completeData(data)
            }
            
            if let error = error {
                self?.logError(message: "getImageData failed - \(error.description)")
            }
        }
        
        guard let downloadItem = item else {
            return
        }
        
        tokenList = tokenList + [path : downloadItem]
        
    }
    
    func getImageDataByTrimming(url: URL?, completeImage:@escaping RemoteData) {
        guard let url = url else {
            logError(message: "getImageDataByTrimming failed - invalid url")
            
            DispatchQueue.main.async {
                completeImage(nil)
            }
            return
        }
        
        guard let trimmedUrl = url.byTrimmingQuery else {
            logError(message: "getImageDataByTrimming failed - invalid trimmed url")
            
            DispatchQueue.main.async {
                completeImage(nil)
            }
            return
        }
        
        let cachePath = trimmedUrl.absoluteString
        
        if let data = SDWebImageManager.shared().imageCache?.diskImageData(forKey: cachePath) {
            DispatchQueue.main.async {
                completeImage(data)
            }
            return
        }
        
        let operation = ImageDownloadOperation(url: trimmedUrl, queue: DispatchQueue.global(), isErrorLogEnabled: isErrorLogEnabled)
        operation.outputBlock = { [weak self] _, data in
            guard let self = self else {
                completeImage(nil)
                return
            }
            
            self.tokenList[trimmedUrl] = nil
            
            guard let data = data else {
                completeImage(nil)
                return
            }
            
            SDWebImageManager.shared().imageCache?.storeImageData(toDisk: data, forKey: cachePath)
            completeImage(data)
        }
        
        tokenList = tokenList + [trimmedUrl : operation]
        
        DispatchQueue.toBackground {
            operation.start()
        }
    }
    
    func getImageByTrimming(url: URL?, completeImage:@escaping RemoteImage) {
        guard let url = url else {
            logError(message: "getImageByTrimming failed - invalid url")
            
            DispatchQueue.main.async {
                completeImage(nil)
            }
            return
        }
        
        guard let trimmedUrl = url.byTrimmingQuery else {
            logError(message: "getImageByTrimming failed - invalid trimmed url")
            
            DispatchQueue.main.async {
                completeImage(nil)
            }
            return
        }
        
        let cachePath = trimmedUrl.absoluteString
        
        if let image = SDWebImageManager.shared().imageCache?.imageFromCache(forKey: cachePath) {
            DispatchQueue.main.async {
                completeImage(image)
            }
            return
        }
        
        let operation = ImageDownloadOperation(url: trimmedUrl, queue: DispatchQueue.global(), isErrorLogEnabled: isErrorLogEnabled)
        operation.outputBlock = { [weak self] image, _ in
            guard let self = self else {
                completeImage(nil)
                return
            }
            
            self.tokenList[trimmedUrl] = nil
            
            guard let image = image as? UIImage else {
                completeImage(nil)
                return
            }
            
            SDWebImageManager.shared().imageCache?.store(image, forKey: cachePath, completion: nil)
            completeImage(image)
        }
        
        tokenList = tokenList + [trimmedUrl : operation]
        
        DispatchQueue.toBackground {
            operation.start()
        }
    }
    
    func getImagesByImagesURLs(list: [ImageForDowload], images: @escaping ([URL]) -> Void) {
        if list.count > 0 {
            let imageObject = list.first
            getImage(patch: imageObject?.downloadURL, completeImage: {image in
                var urlsArray = [URL]()
                
                var url: URL? = nil
                if let imageName = imageObject?.imageName {
                    url = URL(fileURLWithPath: (NSTemporaryDirectory() + imageName))
                }
                if let im = image, let url_ = url {
                    let data = UIImagePNGRepresentation(im) as NSData?
                    data?.write(to: url_, atomically: false)
                    urlsArray.append(url_)
                } else {
                    url = nil
                }
                
                if (list.count == 1) {
                    images(urlsArray)
                } else {
                    let decreasedArray = Array(list.dropFirst())
                    let downloader = ImageDownloder()
                    downloader.getImagesByImagesURLs(list: decreasedArray, images: { array in
                        var urlsArray = [URL]()
                        if let url_ = url {
                            urlsArray.append(url_)
                        }
                        
                        urlsArray.append(contentsOf: array)
                        images(urlsArray)
                    })
                }
            })
        }
    }

    
    func cancelRequest(path: URL) {
        if let item = tokenList[path] {
            cancel(operation: item, url: path)
        } else if let trimmedUrl = path.byTrimmingQuery, let item = tokenList[trimmedUrl] {
            cancel(operation: item, url: trimmedUrl)
        }
        //        downloder.cancel(item)
    }
    
    private func cancel(operation: SDWebImageOperation, url: URL) {
        operation.cancel()
        tokenList[url] = nil
    }
}

extension ImageDownloder {
    private func logError(message: String) {
        if isErrorLogEnabled {
            debugLog(message)
        }
    }
}

typealias FilesDownloaderResponse = (_ fileURLs: [URL], _ directoryURL: URL) -> Void
typealias FilesDownloaderFail = (_ errorMessage: String) -> Void

class FilesDownloader {
    
    let fileManager = FileManager.default
    let requestService = BaseRequestService()
    
    var error: Error?
    
    func getFiles(filesForDownload: [FileForDownload], response: @escaping FilesDownloaderResponse, fail: @escaping FilesDownloaderFail) {
        guard filesForDownload.count > 0 else {
            fail(TextConstants.errorFileSystemAccessDenied)
            return
        }
        
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first  else {
            fail(TextConstants.errorNothingToDownload)
            return
        }
        
        let tmpDirectoryURL = documentsURL.appendingPathComponent(UUID().uuidString, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fail(error.description)
            return
        }
        
        let group = DispatchGroup()
        var localURLs = [URL]()
        for file in filesForDownload {
            group.enter()
            let params = BaseDownloadRequestParametrs(urlToFile: file.url, fileName: file.name, contentType: file.type)
            
            requestService.executeDownloadRequest(param: params) { [weak self] urlToTmpFile, response, error in
                if let urlToTmpFile = urlToTmpFile {
                    let destinationURL = tmpDirectoryURL.appendingPathComponent(file.name, isDirectory: false)
                    do {
                        try FileManager.default.moveItem(at: urlToTmpFile, to: destinationURL)
                        localURLs.append(destinationURL)
                    } catch {
                        self?.error = error
                    }
                } else {
                    self?.error = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            if let error = self.error, localURLs.isEmpty {
                fail(error.description)
            } else {
                response(localURLs, tmpDirectoryURL)
            }
        }
    }
}
