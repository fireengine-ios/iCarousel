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
    
    private let uploadService = UploadService.shared
    private var isFavorites = false
    private var folderUUID = ""
    private var accountUuid = SingletonStorage.shared.accountInfo?.uuid
    private var isFromAlbum = false
    private var uploadType: UploadType = .regular
    
    
    func showViewController(type: UploadType, router: RouterVC, externalFileType: ExternalFileType) {
        uploadType = type
        
        switch type {
            case .regular:
                if let sharedFolderInfo = router.sharedFolderItem {
                    folderUUID = sharedFolderInfo.uuid
                }
                accountUuid = SingletonStorage.shared.accountInfo?.uuid
                
            case .sharedWithMe:
                if let sharedFolderInfo = router.sharedFolderItem {
                    accountUuid = sharedFolderInfo.accountUuid
                    folderUUID = sharedFolderInfo.uuid
                }
                
            case .sharedArea:
                if let sharedFolderInfo = router.sharedFolderItem {
                    folderUUID = sharedFolderInfo.uuid
                }
                accountUuid = SingletonStorage.shared.accountInfo?.parentAccountInfo.uuid
                
            default:
                assertionFailure()
                break
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
