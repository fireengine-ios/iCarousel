//
//  DragAndDropUploader.swift
//  Depo
//
//  Created by Burak Donat on 23.12.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import UIKit

class DragAndDropHelper {
    static let shared = DragAndDropHelper()
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.dragAndDropUploadQueue)

    func performDrop(with session: UIDropSession, albumUUID: String? = nil) {
        session.loadObjects(ofClass: DragAndDropMediaType.self) { objects in
            self.dispatchQueue.async {
                self.uploadDroppedItems(objects.compactMap { $0 as? DragAndDropMediaType })
            }
        }
    }

    private func uploadDroppedItems(_ objects: [DragAndDropMediaType], albumUUID: String? = nil) {
        let items: [WrapData] = objects.compactMap { object in
            if let data = object.fileData,
               let fileExtension = object.fileExtension,
               let fileType = getFileType(with: fileExtension) {
                let wrapData = WrapData(mediaData: data, isLocal: false, fileType: fileType)
                if let wrapDataName = wrapData.name, let dataExtension = object.fileExtension {
                    wrapData.name = wrapDataName + "." + dataExtension
                    return wrapData
                }

                // skipping items with no name?
                return nil
            }

            return nil
        }

        guard items.count > 0 else {
            debugLog("No items to drop")
            return
        }

        UploadService.default.uploadFileList(
            items: items, uploadType: .upload, uploadStategy: .WithoutConflictControl,
            uploadTo: .MOBILE_UPLOAD, folder: albumUUID ?? "", isFavorites: false,
            isFromAlbum: albumUUID != nil, isFromCamera: false, projectId: nil,
            success: {}, fail: { _ in }, returnedUploadOperation: { _ in}
        )
    }

    private func getFileType(with ext: String) -> FileType? {
        guard let name = DragAndDropFileExtensions(rawValue: ext) else { return .unknown}
        if name.isImageType {
            return .image
        } else if name.isVideoType {
            return .video
        } else {
            return .unknown
        }
    }
}
