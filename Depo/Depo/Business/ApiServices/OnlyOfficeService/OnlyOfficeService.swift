//
//  OnlyOfficeService.swift
//  Depo
//
//  Created by Ozan Salman on 31.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class OnlyOfficeService: BaseRequestService {
    func create(fileName: String, documentType: String, parentFolderUuid: String, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("OnlyOfficeService createFile")
        let param = OnlyOfficeCreateFileParameters(fileName: fileName, documentType: documentType, parentFolderUuid: parentFolderUuid)
        let handler = BaseResponseHandler<OnlyOfficeResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
    
    func filterDocument(parentFolderUuid: String? = "", page: Int? = 0, size: Int? = 100, sortBy: SearchContentType? = .content_type, sortOrder: SortOrder? = .asc, documentType: OnlyOfficeFilterType, success:@escaping SuccessResponse, fail:@escaping FailResponse) {
        debugLog("OnlyOfficeService filter")
        
        let param = OnlyOfficeDocumentFilterParameters(parentFolderUuid: parentFolderUuid!, page: page!, size: size!, sortBy: sortBy!, sortOrder: sortOrder!, documentType: documentType)
        let handler = BaseResponseHandler<SearchResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }

}
