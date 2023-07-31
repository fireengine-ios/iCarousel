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
    let parentFolderUuid: String
    
    init(fileName: String, documentType: String, parentFolderUuid: String) {
        self.fileName = fileName
        self.documentType = documentType
        self.parentFolderUuid = parentFolderUuid
    }
    
    override var requestParametrs: Any {
        let dict: [String: Any] = ["fileName": fileName,
                                   "documentType": documentType,
                                   "parentFolderUuid": parentFolderUuid]
        return dict
    }
    
    override var patch: URL {
        let path: String = String(format: OnlyOfficePath.createFile)
        return URL(string: getPath(path: path), relativeTo: super.patch)!
    }
    
    private func getPath(path: String) -> String {
        let projectId: String = StringConstants.onlyOfficeCreateFileProjectId
        if projectId == "" {
            return path
        } else {
            return "\(path)/\(projectId)"
        }
    }
}

class OnlyOfficeDocumentFilterParameters: BaseRequestParametrs {
    
    let parentFolderUuid: String
    let documentType: OnlyOfficeFilterType
    let sortBy: SearchContentType
    let sortOrder: SortOrder
    let page: Int
    let size: Int
    
    init(parentFolderUuid: String, page: Int, size: Int, sortBy: SearchContentType, sortOrder: SortOrder, documentType: OnlyOfficeFilterType) {
        self.parentFolderUuid = parentFolderUuid
        self.documentType = documentType
        self.sortBy = sortBy
        self.sortOrder = sortOrder
        self.page = page
        self.size = size
    }
    
    override var patch: URL {
        let filterGetParam = String(format: RouteRequests.onlyOfficeFilterDocument,
                                    parentFolderUuid,
                                    page.description,
                                    size.description,
                                    sortBy.description,
                                    sortOrder.description,
                                    documentType.filterType)
        
        return URL(string: filterGetParam, relativeTo: super.patch)!
    }
    
}
