//
//  OnlyOfficeService.swift
//  Depo
//
//  Created by Ozan Salman on 31.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class OnlyOfficeService: BaseRequestService {
    func create(fileName: String, documentType: String, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("OnlyOfficeService createFile")
        let param = OnlyOfficeCreateFileParameters(fileName: fileName, documentType: documentType)
        let handler = BaseResponseHandler<OnlyOfficeResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
}
