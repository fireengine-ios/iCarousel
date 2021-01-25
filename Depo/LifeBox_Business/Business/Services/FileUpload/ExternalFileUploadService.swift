//
//  ExternalFileUploadService.swift
//  Depo
//
//  Created by Konstantin Studilin on 21.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


import UIKit
import CoreServices


enum ExternalFileType {
    case any
    case documents
    case audio
    
    var allowedUTITypes: [String] {
        switch self {
            case .any:
                return [kUTTypeItem]  as [String]
                
            case .documents:
                return [kUTTypeCompositeContent, kUTTypeText, kUTTypeArchive] as [String]
                
            case .audio:
                return [kUTTypeAudio] as [String]
        }
    }
}


final class ExternalFileUploadService: NSObject {
    
    private let uploadService = UploadService.default
    private var isFavorites = false
    private var folderUUID = ""
    private var accountUuid: String?
    private var isFromAlbum = false
    
    
    func showViewController(router: RouterVC, externalFileType: ExternalFileType) {
        
        isFavorites = router.isOnFavoritesView()
        
        if let sharedFolderInfo = router.sharedFolderItem {
            folderUUID = sharedFolderInfo.uuid
            accountUuid = sharedFolderInfo.accountUuid
        } else {
            folderUUID = router.getParentUUID()
            accountUuid = nil
        }
        
        let utTypes = externalFileType.allowedUTITypes
        
        let controller = UIDocumentPickerViewController(documentTypes: utTypes, in: .import)
        controller.delegate = self
        controller.allowsMultipleSelection = true
        
        router.presentViewController(controller: controller, animated: true, completion: nil)
    }
}


extension ExternalFileUploadService: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        printLog("process is cancelled")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        printLog("picked \(urls.count) url(s)")
        
        let wrapDataItems = urls.compactMap { WrapData(importedDocumentURL: $0) }
        
        upload(items: wrapDataItems)
    }
    
    private func upload(items: [WrapData]) {
        guard !items.isEmpty else {
            return
        }
        
        let uploadType: UploadType
        if accountUuid != nil {
            uploadType = accountUuid == SingletonStorage.shared.accountInfo?.uuid ? .regular : .sharedWithMe
        } else {
            uploadType = .regular
        }
        
        
        uploadService.uploadFileList(items: items,
                                     uploadType: uploadType,
                                     uploadStategy: .WithoutConflictControl,
                                     uploadTo: .ROOT,
                                     folder: folderUUID,
                                     isFavorites: isFavorites,
                                     isFromAlbum: isFromAlbum,
                                     isFromCamera: false,
                                     projectId: accountUuid,
                                     success: {},
                                     fail: { _ in },
                                     returnedUploadOperation: { _ in})
    }
}
