//
//  DragAndDropItemType.swift
//  Depo
//
//  Created by Burak Donat on 27.12.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import MobileCoreServices

class DragAndDropMediaType : NSObject, NSItemProviderReading {
    let fileData: Data?
    let fileExtension: String?

    required init(data:Data, typeIdentifier:String) {
        fileData = data
        let cfExtensionName = UTTypeCopyPreferredTagWithClass(typeIdentifier as CFString, kUTTagClassFilenameExtension)
        self.fileExtension = cfExtensionName?.takeRetainedValue() as String?
    }

    static var readableTypeIdentifiersForItemProvider: [String] {
        var documentTypeArray: [String] = []

        for ext in ["png", "jpeg", "heic", "mov", "mp4", "gif"] {
            let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)
            if let documentType = UTI?.takeRetainedValue() as String? {
                documentTypeArray.append(documentType)
            }
        }
        return documentTypeArray
    }

    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(data: data, typeIdentifier: typeIdentifier)
    }
}
