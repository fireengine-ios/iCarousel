//
//  ImageManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Photos

typealias ResponseAsset = (ResponseResult<PHAsset>) -> Void

final class ImageManager: NSObject {
    
    func getLastImageAsset(handler: @escaping ResponseAsset) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            handler(ResponseResult.failed(ErrorResponse.string("")))
            return
        }
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if fetchResult.count > 0 {
            handler(ResponseResult.success(fetchResult[0]))
        } else {
            let error = CustomErrors.text("There is no photos")
            handler(ResponseResult.failed(error))
        }
    }
    
    func saveToDevice(image: UIImage, handler: @escaping ResponseVoid) {
        self.handler = handler
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saved(image:error:contextInfo:)), nil)
    }
    
    private var handler: ResponseVoid?
    
    @objc private func saved(image: UIImage, error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            self.handler?(ResponseResult.failed(error))
        } else {
            self.handler?(ResponseResult.success(()))
        }
    }
}
