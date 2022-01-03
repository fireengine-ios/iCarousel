//
//  DragAndDropItemType.swift
//  Depo
//
//  Created by Burak Donat on 27.12.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import MobileCoreServices

class DragAndDropItemType: NSObject, NSItemProviderReading {
    let fileData: Data?
    let fileExtension: String?
    
    class var readableTypeIdentifiersForItemProvider: [String] {
        return []
    }
    
    required init(data:Data, typeIdentifier:String) {
        fileData = data
        let cfExtensionName = UTTypeCopyPreferredTagWithClass(typeIdentifier as CFString, kUTTagClassFilenameExtension)
        self.fileExtension = cfExtensionName?.takeRetainedValue() as String?
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(data: data, typeIdentifier: typeIdentifier)
    }
}

class DragAndDropMediaType: DragAndDropItemType {

    override class var readableTypeIdentifiersForItemProvider: [String] {
        var documentTypeArray: [String] = []

        for ext in DragAndDropFileExtensions.allCases where ext.isPhotoVideoType == true {
            let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext.rawValue as CFString, nil)
            if let documentType = UTI?.takeRetainedValue() as String? {
                documentTypeArray.append(documentType)
            }
        }
        return documentTypeArray
    }
}

class DragAndDropAllFilesType: DragAndDropItemType {

    override class var readableTypeIdentifiersForItemProvider: [String] {
        var documentTypeArray: [String] = []

        for ext in DragAndDropFileExtensions.allCases {
            let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext.rawValue as CFString, nil)
            if let documentType = UTI?.takeRetainedValue() as String? {
                documentTypeArray.append(documentType)
            }
        }
        return documentTypeArray
    }
}
