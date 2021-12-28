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
    
    func uploadItems(with data: [WrapData], isCustomAlbum: Bool? = false, albumUUID: String? = "") {
        DispatchQueue.main.async {
            UploadService.default.uploadFileList(items: data, uploadType: .upload, uploadStategy: .WithoutConflictControl,uploadTo: .MOBILE_UPLOAD,
                                                 folder: albumUUID ?? "", isFavorites: false, isFromAlbum: isCustomAlbum ?? false, isFromCamera: false,
                                                 projectId: nil, success: {}, fail: { _ in }, returnedUploadOperation: { _ in})
        }
    }
    
    func getFileType(with ext: String) -> FileType? {
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
