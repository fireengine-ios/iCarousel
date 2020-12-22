//
//  PHPhotoLibrary+Extensions.swift
//  Depo
//
//  Created by Andrei Novikau on 7/23/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Photos

//TODO: uncomment for xcode 12
extension PHPhotoLibrary {
    
    static func isAccessibleAuthorizationStatus() -> Bool {
        return currentAuthorizationStatus().isAccessible
    }
    
    static func currentAuthorizationStatus() -> PHAuthorizationStatus {
        if #available(iOS 14, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            return PHPhotoLibrary.authorizationStatus()
        }
    }
    
    static func requestAuthorizationStatus(_ handler: @escaping (PHAuthorizationStatus) -> Void) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: handler)
        } else {
            PHPhotoLibrary.requestAuthorization(handler)
        }
    }
}

extension PHAuthorizationStatus {
    var isAccessible: Bool {
        if #available(iOS 14, *) {
            return isContained(in: [.authorized, .limited])
        } else {
            return self == .authorized
        }
    }
}
