//
//  NotificationService.swift
//  Depo
//
//  Created by yilmaz edis on 13.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class NotificationService: BaseRequestService {
    func fetch(success: SuccessResponse?, fail: @escaping FailResponse) {
        let param = NotificationFetchParameters()
        let handler = BaseResponseHandler<NotificationResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func delete(with idList: [Int], success: SuccessResponse?, fail: @escaping FailResponse) {
        let param = NotificationDeleteParameters(with: idList)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeDeleteRequest(param: param, handler: handler)
    }
    
    func read(with id: String, success: SuccessResponse?, fail: @escaping FailResponse) {
        let param = NotificationReadParameters(with: id)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
}
