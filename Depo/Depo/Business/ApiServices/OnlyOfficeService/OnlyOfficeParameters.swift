//
//  OnlyOfficeParameters.swift
//  Depo
//
//  Created by Ozan Salman on 31.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

struct OnlyOfficePath {
    static let createFile = "office/files"
}

class OnlyOfficeCreateFileParameters: BaseRequestParametrs {
    
    let fileName: String
    let documentType: String
    let parentFolderUuid: String = ""
    
    init(fileName: String, documentType: String) {
        self.fileName = fileName
        self.documentType = documentType
    }
    
    override var requestParametrs: Any {
        let dict: [String: Any] = ["fileName": fileName,
                                   "documentType": documentType,
                                   "parentFolderUuid": parentFolderUuid]
        return dict
    }
    
    override var patch: URL {
        let path: String = String(format: OnlyOfficePath.createFile)
        return URL(string: path, relativeTo: super.patch)!
    }
}
