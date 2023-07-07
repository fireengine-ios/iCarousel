//
//  QuickScrollService.swift
//  Depo
//
//  Created by Aleksandr on 9/7/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Alamofire
import SwiftyJSON

final class QuickScrollService {
    
    private let startDateBodyKey = "startDate"
    private let endDateBodyKey = "endDate"
    private let categoryBodyKey = "category"
    private let sizeBodyKey = "size"
    private let startFileIdKey = "startFileId"
    private let endFileIdKey = "endFileId"
    
    let sessionManager: SessionManager
    
    init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }

    private var currentDataRequest: DataRequest?
    func requestListOfDateRange(startDate: Date, endDate: Date,
                                startID: Int64? = nil, endID: Int64? = nil,
                                category: QuickScrollCategory, pageSize: Int,
                                handler: @escaping ResponseHandler<QuickScrollRangeListItem>) {
        
        guard let requestURL = URL(string: RouteRequests.quickScrollRangeList, relativeTo: RouteRequests.baseUrl) else {
            //handler(ResponseResult.failed(CustomErrors.unknown))
            return
        }

        currentDataRequest?.cancel()
        
        var body: [String: Any] = [startDateBodyKey: "\(startDate.millisecondsSince1970)",
                                    endDateBodyKey: "\(endDate.millisecondsSince1970)",
                                    categoryBodyKey: category.text,
                                    sizeBodyKey: "\(pageSize)",
                                    startFileIdKey: "",
                                    endFileIdKey: ""]
        if let unwrapedStartId = startID {
            body[startFileIdKey] = unwrapedStartId
        }
        if let unwrapedEndId = endID {
            body[endFileIdKey] = unwrapedEndId
        }
        currentDataRequest = sessionManager
                .request(requestURL,
                         method: .get,
                         parameters: body)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    handler(ResponseResult.success(QuickScrollRangeListItem(json: JSON(data))))
                case .failure(let error):
                    handler(ResponseResult.failed(error))
                }
        }
    }
}
