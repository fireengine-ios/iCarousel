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
    
    private func isActivitiesEnded(in array: [ActivityTimelineServiceResponse]) -> Bool {
        return (array.count == 1) && (array.first?.activityType == .welcome)
    }
}
extension ActivityTimelinePresenter: ActivityTimelineViewOutput {
    func viewIsReady() {
        interactor.trackScreen()
        startAsyncOperation()
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
        if isActivitiesEnded(in: array) {
            view.endInfinityScrollWithNoMoreData()
        } else {
            view.displayTimelineActivities(with: array)
        }
    }
    func refreshTimelineActivities(with array: [ActivityTimelineServiceResponse]) {
        view.refreshTimelineActivities(with: array)
        asyncOperationSuccess()
    }
    func failedTimelineActivities(with error: ErrorResponse) {
        UIApplication.showErrorAlert(message: error.description)
        view.endInfinityScrollWithNoMoreData()
        asyncOperationSuccess()
    }
}
