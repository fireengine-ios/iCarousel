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
    
    private let downloder: SDWebImageDownloader
    
    private var tokenList = [URL : SDWebImageDownloadToken]()
    
    init() {
        downloder = SDWebImageManager.shared().imageDownloader!
    }
    
    func getImage(patch: URL?, compliteImage:@escaping RemoteImage) {
        
        if (patch == nil){
            DispatchQueue.main.async {
                compliteImage(nil)
            }
        }
        
        let item = downloder.downloadImage(with: patch,
                                options: [.lowPriority,.useNSURLCache],
                                progress: nil) { (image, data, error, bool) in
                                    
                                    compliteImage(image)
        }
        guard let it = item else {
            return
        }
        tokenList = tokenList + [patch! : it]
        
    }
    
    func getImagesByImagesURLs(list:[ImageForDowload], images:@escaping ([URL]) -> Swift.Void){
        if list.count > 0{
            let imageObject = list.first
            getImage(patch: imageObject?.downloadURL, compliteImage: {(image) in
                var urlsArray = [URL]()
                
                var url: URL? = nil
                if let imageName = imageObject?.imageName {
                    url = URL(fileURLWithPath: (NSTemporaryDirectory() + imageName))
                }
                if let im = image, let url_ = url{
                    let data = UIImagePNGRepresentation(im) as NSData?
                    data?.write(to: url_, atomically: false)
                    urlsArray.append(url_)
                }else{
                    url = nil
                }
                
                if (list.count == 1){
                    images(urlsArray)
                }else{
                    let decreasedArray = Array(list.dropFirst())
                    let downloader = ImageDownloder()
                    downloader.getImagesByImagesURLs(list: decreasedArray, images: { (array) in
                        var urlsArray = [URL]()
                        if let url_ = url{
                            urlsArray.append(url_)
                        }
                        
                        urlsArray.append(contentsOf: array)
                        images(urlsArray)
                    })
                }
            })
        }
    }
    
    func cancelRequest(path: URL) -> Void {
        guard let item = tokenList[path] else {
            return
        }
        downloder.cancel(item)
    }
}



