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

    func requestListOfDateRange(startDate: Date, endDate: Date? = nil,
                                startID: Int64, endID: Int64? = nil,
                                category: QuickScrollCategory, pageSize: Int,
                                handler: @escaping ResponseHandler<QuickScrollRangeListItem>) {
        
        guard let requestURL = URL(string: RouteRequests.quickScrollRangeList, relativeTo: RouteRequests.BaseUrl) else {
            handler(ResponseResult.failed(CustomErrors.unknown))
            return
        }

        var body: [String: Any] = [startDateBodyKey: "\(startDate.millisecondsSince1970)",
                                    endDateBodyKey: "",
                                    categoryBodyKey: category.text,
                                    sizeBodyKey: "\(pageSize)",
                                    startFileIdKey: startID,
                                    endFileIdKey: ""]
        if let unwrapedEndDate = endDate {
            body[endDateBodyKey] = "\(unwrapedEndDate.millisecondsSince1970)"
        }
        if let unwrapedEndId = endID {
            body[endFileIdKey] = unwrapedEndId
        }
        sessionManager
                .request(requestURL,
                         method: .get,
                         parameters: body)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
//                    ///Not the best thing, that we call core date from this service, but its the only way to get media Items
//                    let context = CoreDataStack.default.newChildBackgroundContext
//                    context.perform {
                    handler(ResponseResult.success(QuickScrollRangeListItem(json: JSON(data: data)))
//                    }
                case .failure(let error):
                    handler(ResponseResult.failed(error))
                }
        }
    }
}
