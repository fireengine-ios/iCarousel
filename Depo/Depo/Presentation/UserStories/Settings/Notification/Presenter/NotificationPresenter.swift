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
    
    private var notifications: [NotificationServiceResponse] = []
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
    
    func deleteNotification(at index: Int) {
        notifications.remove(at: index)
    }
}

// MARK: PackagesInteractorOutput
extension NotificationPresenter: NotificationInteractorOutput {
    func success(with notifications: [NotificationServiceResponse]) {
        view?.stopActivityIndicator()
        
        // self.notifications = notifications
        
        for i in 0...20 {
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
