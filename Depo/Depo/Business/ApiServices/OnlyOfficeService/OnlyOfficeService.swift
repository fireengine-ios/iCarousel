//
//  OnlyOfficeService.swift
//  Depo
//
//  Created by Ozan Salman on 31.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

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
    
    @discardableResult
    func getOnlyOfficeFileHtml(fileUrl: String, handler: @escaping ResponseHandler<String>) -> URLSessionTask? {
        return SessionManager
            .customDefault
            .request(fileUrl)
            .customValidate()
            .responseString { response in
                switch response.result {
                case .success(let string):
                    handler(.success(string))
                case .failure(let error):
                    handler(.failed(error))
                }
            }
            .task
    }

}
