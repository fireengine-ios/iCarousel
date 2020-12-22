//
//  ActivityTimelineService.swift
//  Depo
//
//  Created by user on 9/14/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol ActivityTimelineService {
    func timelineActivities(page: Int, size: Int, success: @escaping SuccessResponse, fail: @escaping FailResponse)
}

class ActivityTimelineServiceIml: BaseRequestService, ActivityTimelineService {
    func timelineActivities(page: Int, size: Int, success: @escaping SuccessResponse, fail: @escaping FailResponse) {
        debugLog("ActivityTimelineServiceIml timelineActivities")

        let params = ActivityTimelineParameters(sortBy: .name, sortOrder: .asc, page: page, size: size)
        let handler = BaseResponseHandler<ActivityTimelineResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: params, handler: handler)
    }
}
