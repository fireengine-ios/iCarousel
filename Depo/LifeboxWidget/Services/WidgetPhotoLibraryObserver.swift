//
//  WidgetPhotoLibraryObserver.swift
//  Depo
//
//  Created by Konstantin Studilin on 18.09.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Photos

enum PhotoLibraryChangeType: String {
    case added = "added"
    case removed = "removed"
    case changed = "changed"
}

typealias PhotoLibraryItemsChanges = [PhotoLibraryChangeType: [PHAsset]]


final class WidgetPhotoLibraryObserver {
    
    static let shared = WidgetPhotoLibraryObserver()
    
    
    private var assetFetchResult: PHFetchResult<PHAsset>?
    private let photoLibrary = PHPhotoLibrary.shared()
    
    private let coreDataStack = SharedGroupCoreDataStack.shared
    
    
    private init() {
        //TODO: Somehow wait for CoreData to load
        coreDataStack.setup { }
    }
    
    
    func hasUnsynced(completion: @escaping (Bool)->()) {
        guard PHPhotoLibrary.isAccessibleAuthorizationStatus() else {
            completion(false)
            return
        }
        
        var allLocalIdentifiers = [String]()
        PHAsset.fetchAllAssets().enumerateObjects { (asset, _, _) in
            allLocalIdentifiers.append(asset.localIdentifier)
        }
        coreDataStack.unsynced(from: allLocalIdentifiers) { [weak self] unsynced in
            completion(!unsynced.isEmpty)
        }
    }
}

//If we need to observe changes

//extension WidgetPhotoLibraryObserver: NSObject, PHPhotoLibraryChangeObserver {
//
//    override init() {
//        super.init()
//
//        registerIfAvailable()
//    }
//
//    func registerIfAvailable() {
//        guard PHPhotoLibrary.isAccessibleAuthorizationStatus(), assetFetchResult == nil else {
//            return
//        }
//        photoLibrary.register(self)
//        assetFetchResult = PHAsset.fetchAllAssets()
//    }
//
//
//    func photoLibraryDidChange(_ changeInstance: PHChange) {
//        guard let fetchResult = assetFetchResult else {
//            return
//        }
//
//        guard let changes = changeInstance.changeDetails(for: fetchResult) else {
//            return
//        }
//
//        assetFetchResult = changes.fetchResultAfterChanges
//
//        guard changes.hasIncrementalChanges else {
//            return
//        }
//
//        let insertedAssets = changes.insertedObjects
//
//        guard !insertedAssets.isEmpty else {
//            return
//        }
//
//        var phChanges = PhotoLibraryItemsChanges()
//
//        phChanges[.added] = insertedAssets
//
//        NotificationCenter.default.post(name: .notificationPhotoLibraryDidChange, object: nil, userInfo: phChanges)
//    }
//}



//TODO: move extensions into separate files or add some of them into the target, together with the main app

extension Notification.Name {
    public static let notificationPhotoLibraryDidChange = Notification.Name("notificationPhotoLibraryDidChange")
}


extension PHAsset {
    static func fetchAllAssets() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        return PHAsset.fetchAssets(with: options)
    }
}

