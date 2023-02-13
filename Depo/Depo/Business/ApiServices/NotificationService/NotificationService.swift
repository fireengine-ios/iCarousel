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
        debugLog("AccountService usage")

        let param = NotificationFetchParameters()
        let handler = BaseResponseHandler<NotificationResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
}
