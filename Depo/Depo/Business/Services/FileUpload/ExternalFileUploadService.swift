//
//  ExternalFileUploadService.swift
//  Depo
//
//  Created by Konstantin Studilin on 21.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


import UIKit
import CoreServices


final class ExternalFileUploadService: NSObject {
    
    private let uploadService = UploadService.default
    private var isFavorites = false
    private var folderUUID = ""
    private var isFromAlbum = false
    
    
    func showViewController(router: RouterVC) {
        
        isFavorites = router.isOnFavoritesView()
        folderUUID = router.getParentUUID()
        isFromAlbum = router.isRootViewControllerAlbumDetail()
        
        let utTypes = [kUTTypeContent as String]
        
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
                                     uploadType: .upload,
                                     uploadStategy: .WithoutConflictControl,
                                     uploadTo: .MOBILE_UPLOAD,
                                     folder: folderUUID,
                                     isFavorites: isFavorites,
                                     isFromAlbum: isFromAlbum,
                                     isFromCamera: false,
                                     success: {},
                                     fail: { _ in },
                                     returnedUploadOperation: { _ in})
    }
}
