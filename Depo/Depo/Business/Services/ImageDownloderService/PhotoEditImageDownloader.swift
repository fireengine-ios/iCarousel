//
//  PhotoEditImageDownloader.swift
//  Depo
//
//  Created by Konstantin Studilin on 09.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


final class PhotoEditImageDownloader {
    
    private let imageDownloader: ImageDownloder = {
        let service = ImageDownloder()
        service.isErrorLogEnabled = true
        return service
    }()
    
    
    func download(url: URL?, attempts: Int, completion: @escaping RemoteImage) {
        guard let url = url else {
            debugLog("url is nil")
            completion(nil)
            return
        }
        
        guard attempts > 0 else {
            debugLog("no attempts left")
            completion(nil)
            return
        }
        
        debugLog("attempts left: \(attempts)")
        
        getImage(url: url) { [weak self] image in
            guard let self = self else {
                completion(nil)
                return
            }
            
            guard let image = image else {
                self.download(url: url, attempts: attempts - 1, completion: completion)
                return
            }
        
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    private func getImage(url: URL?, completion: @escaping RemoteImage) {
        imageDownloader.getImageResponseByTrimming(url: url) { imageResult in
            switch imageResult {
                case .success(let image):
                    completion(image)
                    
                case .failed(let error):
                    debugLog("error: \(error.description)")
                    completion(nil)
            }
        }
    }
}
