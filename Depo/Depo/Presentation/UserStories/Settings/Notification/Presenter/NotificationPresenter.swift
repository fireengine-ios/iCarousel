//
//  NotificationPresenter.swift
//  Depo
//
//  Created by yilmaz edis on 9.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class NotificationPresenter {
    weak var view: NotificationViewInput?
    var interactor: NotificationInteractorInput!
    var router: NotificationRouterInput!
    
    private var notifications: [NotificationServiceResponse] = [] {
        didSet {
            view?.setEmptyView(as: !notifications.isEmpty)
        }
    }
    
    var onlyRead: Bool = true
    var onlyShowAlerts: Bool = true
}

// MARK: PackagesViewOutput
extension NotificationPresenter: NotificationViewOutput {
    func viewIsReady() {
        view?.startActivityIndicator()
        interactor.viewIsReady()
    }
    
    func viewWillAppear() {
        view?.startActivityIndicator()
        interactor.viewWillAppear()
    }

    func notificationsCount() -> Int {
        notifications.count
    }
    
    func getNotification(at index: Int) -> NotificationServiceResponse {
        notifications[index]
    }
    
    func getNotifications(at indexs: [Int]) -> [NotificationServiceResponse] {
        indexs.map { notifications[$0] }
    }
    
    func deleteNotification(at index: Int) {
        notifications.remove(at: index)
    }
    
    func deleteAllNotification() {
        notifications.removeAll()
    }
    
    func deleteAllNotification(at indicesToRemove: [Int]) {
        for index in indicesToRemove.sorted(by: >) {
            notifications.remove(at: index)
        }
    }
}

// MARK: PackagesInteractorOutput
extension NotificationPresenter: NotificationInteractorOutput {
    func success(with notifications: [NotificationServiceResponse]) {
        view?.stopActivityIndicator()
        
        // self.notifications = notifications
        
        for i in 0...notifications.count * 10 {
            let item = NotificationServiceResponse()
            item.title = "\(i) - Yilmaz Edis"
            item.body =  "Lorem ıpsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod temp..Lorem ıpsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod temp..Lorem ıpsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod temp..Lorem ıpsum dolor sit amet"
            item.smallThumbnail = "https://avatars.githubusercontent.com/u/15719990?s=400&u=766c3d645df09b0c562e71affd899b296aa1d59b&v=4"
            self.notifications.append(item)
        }
        
        view?.reloadTableView()
    }

    
    func fail() {
        view?.stopActivityIndicator()
    }
    
}

extension NotificationPresenter: NotificationPresenterInput {

}
