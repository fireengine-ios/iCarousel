//
//  ActivityTimelineActivityTimelinePresenter.swift
//  Depo
//
//  Created by Yaroslav Bondar on 13/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class ActivityTimelinePresenter: BasePresenter, ActivityTimelineModuleInput {

    weak var view: ActivityTimelineViewInput!
    var interactor: ActivityTimelineInteractorInput!
    var router: ActivityTimelineRouterInput!
    
    //MARK : BasePresenter
    override func outputView() -> Waiting? {
        return view
    }
}
extension ActivityTimelinePresenter: ActivityTimelineViewOutput {
    func viewIsReady() {
        startAsyncOperation()
        updateForPullToRefresh()
    }
    func updateForPullToRefresh() {
        interactor.refreshTimelineActivities()
    }
    func loadMoreActivities() {
        interactor.loadMoreActivities()
    }
}
extension ActivityTimelinePresenter: ActivityTimelineInteractorOutput {
    func successedTimelineActivities(with array: [ActivityTimelineServiceResponse]) {
        view.displayTimelineActivities(with: array)
    }
    func refreshTimelineActivities(with array: [ActivityTimelineServiceResponse]) {
        view.refreshTimelineActivities(with: array)
        asyncOperationSucces()
    }
    func failedTimelineActivities(with error: ErrorResponse) {
        view.endInfinityScrollWithNoMoreData()
        asyncOperationSucces()
    }
}
