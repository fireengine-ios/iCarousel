//
//  ExternalFileUploadService.swift
//  Depo
//
//  Created by Konstantin Studilin on 21.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


import UIKit
import CoreServices


enum ExternalUploadFileType {
    case document
    case music
    case any
}

final class ExternalFileUploadService: NSObject {
    
    private let uploadService = UploadService.default
    
    
    func viewController(fileType: ExternalUploadFileType) -> UIDocumentPickerViewController {
        let utTypes: [String]
        
        switch fileType {
            case .document:
                utTypes = [kUTTypeCompositeContent as String]
            case .music:
                utTypes = [kUTTypeAudio as String]
            default:
                utTypes = [kUTTypeContent as String]
        }
        
        let controller = UIDocumentPickerViewController(documentTypes: utTypes, in: .import)
        controller.delegate = self
        controller.allowsMultipleSelection = true
        
        return controller
    }
}


extension ExternalFileUploadService: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        printLog("process is cancelled")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        printLog("picked \(urls.count) url(s)")
        
        let wrapDataItems = urls.compactMap { WrapData(importedDocumentURL: $0) }
        
        //TODO: replace with the real parameters
        uploadService.uploadFileList(items: wrapDataItems, uploadType: .upload, uploadStategy: .WithoutConflictControl, uploadTo: .MOBILE_UPLOAD, folder: "", isFavorites: false, isFromAlbum: false, isFromCamera: false) {
            
        } fail: { (error) in
            
        } returnedUploadOperation: { operations in
            
        }

    }
}
