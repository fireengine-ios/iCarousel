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
    
    func cancelRequest(path: URL) -> Void {
        guard let item = tokenList[path] else {
            return
        }
        downloder.cancel(item)
    }
}



