//
//  DragAndDropUploader.swift
//  Depo
//
//  Created by Burak Donat on 23.12.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class DragAndDropHelper {
    static let shared = DragAndDropHelper()
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.dragAndDropUploadQueue)

    func performDrop<T: DragAndDropItemType>(with session: UIDropSession, itemType: T.Type, albumUUID: String? = nil) {
        session.loadObjects(ofClass: itemType) { objects in
            self.dispatchQueue.async {
                self.uploadDroppedItems(objects.compactMap { $0 as? DragAndDropItemType }, albumUUID: albumUUID)
            }
        }
    }

    private func uploadDroppedItems(_ objects: [DragAndDropItemType], albumUUID: String? = nil) {
        let items: [WrapData] = objects.compactMap { object in
            if let data = object.fileData, let fileExtension = object.fileExtension {
                let wrapData = WrapData(mediaData: data, fileExtension: fileExtension)
                return wrapData
            }

            return nil
        }

        guard items.count > 0 else {
            debugLog("No items to drop")
            return
        }
        
        ItemOperationManager.default.startUploadDragAndDrop()

        UploadService.default.uploadFileList(
            items: items, uploadType: .upload, uploadStategy: .WithoutConflictControl,
            uploadTo: .MOBILE_UPLOAD, folder: albumUUID ?? "", isFavorites: false,
            isFromAlbum: albumUUID != nil, isFromCamera: false, projectId: nil,
            success: {
                ItemOperationManager.default.didUploadDragAndDropItem()
            }, fail: { _ in
                debugLog("Drag and drop item upload operation failed")
            }, returnedUploadOperation: { _ in }
        )
    }
}
