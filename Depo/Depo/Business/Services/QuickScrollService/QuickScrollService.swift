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
    
    let sessionManager: SessionManager
    
    init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }
    
    func requestGroups(handler: @escaping ResponseArrayHandler<QuickScrollGroupItem>) {
        guard let requestURL = URL(string: RouteRequests.quickScrollGroups, relativeTo: RouteRequests.BaseUrl) else {
            handler(ResponseResult.failed(CustomErrors.unknown))
            return
        }
        sessionManager
            .request(requestURL)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    handler(ResponseResult.success(JSON(data: data).arrayValue.map {
                        QuickScrollGroupItem(json: $0)
                    }))
                case .failure(let error):
                    handler(ResponseResult.failed(error))
                }
        }
    }
    
    func requestListOfGroups(reuststListGroupItems: [GroupsListRequestItem], handler: @escaping ResponseArrayHandler<QuickScrollGroupsListItem>) {
        guard let requestURL = URL(string: RouteRequests.quickScrollGroupsList, relativeTo: RouteRequests.BaseUrl) else {
            handler(ResponseResult.failed(CustomErrors.unknown))
            return
        }
//        RouteRequests.quickScrollGroupsList
//        //    curl -X POST -H "Accept: application/json" -H "X-Auth-Token: {X-Auth-Token}" -d '[
//        //    {"group": "2017-4", "start": 13, "end": 15},
//        //    {"group": "2014-6", "start": 0, "end": 4}
//        //    ]' "https://adepo.turkcell.com.tr/api/scroll/groups/list"
        
        //TODO: ADD PARMETRS AS DATA
        sessionManager
            .request(requestURL,
                     method: .post,
                     parameters:[:])//"data":])
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    handler(ResponseResult.success(JSON(data: data).arrayValue.map { QuickScrollGroupsListItem(json: $0) }))
                case .failure(let error):
                    handler(ResponseResult.failed(error))
                }
        }
    }

    func requestListOfDateRange(startDate: Date, endDate: Date?,
                                category: QuickScrollCategory, size: Int,
                                handler: @escaping ResponseArrayHandler<QuickScrollRangeListItem>) {
        guard let requestURL = URL(string: RouteRequests.quickScrollRangeList, relativeTo: RouteRequests.BaseUrl) else {
            handler(ResponseResult.failed(CustomErrors.unknown))
            return
        }

        var body: [String: Any] = [startDateBodyKey: "\(startDate.millisecondsSince1970)",
                                    endDateBodyKey: "",
                                    categoryBodyKey: category.text,
                                    sizeBodyKey: "\(size)"]
        if let unwrapedEndDate = endDate {
            body[endDateBodyKey] = "\(unwrapedEndDate.millisecondsSince1970)"
        }
        
        sessionManager
                .request(requestURL,
                         method: .post,
                         parameters: body)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    handler(ResponseResult.success(JSON(data: data).arrayValue.map { QuickScrollRangeListItem(json: $0) }))
                case .failure(let error):
                    handler(ResponseResult.failed(error))
                }
        }
    }
}
