//
//  ActivityTimelineActivityTimelineInteractor.swift
//  Depo
//
//  Created by Yaroslav Bondar on 13/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class ActivityTimelineInteractor {
    
    weak var output: ActivityTimelineInteractorOutput!
    
    private let activityTimelineService: ActivityTimelineService
    private var page = 0
    private let size: Int
    
    init(activityTimelineService: ActivityTimelineService = ActivityTimelineServiceIml()) {
        self.activityTimelineService = activityTimelineService
        size = Device.isIpad ? 40 : 20
    }
}
extension ActivityTimelineInteractor: ActivityTimelineInteractorInput {
    func refreshTimelineActivities() {
        page = 0
        loadActivities { [weak self] response in
            self?.output.refreshTimelineActivities(with: response.list)
        }
    }
    
    func loadMoreActivities() {
        loadActivities { [weak self] response in
            self?.output.successedTimelineActivities(with: response.list)
        }
    }
    
    private func loadActivities(with successBlock: @escaping (ActivityTimelineResponse) -> Void) {
        activityTimelineService.timelineActivities(page: page, size: size,
           success: { [weak self] response in
            guard let response = response as? ActivityTimelineResponse else { return }
                DispatchQueue.toMain {
                    successBlock(response)
                    self?.page += 1
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.toMain {
                    self?.output.failedTimelineActivities(with: errorResponse)
                }
        })
    }
}
