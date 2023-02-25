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
    
    var onlyRead: Bool = false
    var onlyShowAlerts: Bool = false
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
        // first delete remote
        delete(with: [index])
        notifications.remove(at: index)
    }
    
    func deleteAllNotification() {
        // first delete remote
        delete(with: Array(0..<notifications.count))
        notifications.removeAll()
    }
    
    func deleteAllNotification(at indicesToRemove: [Int]) {
        // first delete remote
        delete(with: indicesToRemove)
        for index in indicesToRemove.sorted(by: >) {
            notifications.remove(at: index)
        }
    }
    
    func delete(with rows: [Int]) {
        var idList = [Int]()
        
        rows.forEach { index in
            idList.append(notifications[index].communicationNotificationId)
        }
        print("yilmaz: \(idList) \(notifications.count)")
        interactor.delete(with: idList)
    }
    
    func read(with id: String) {
        interactor.read(with: id)
    }
}

// MARK: PackagesInteractorOutput
extension NotificationPresenter: NotificationInteractorOutput {
    
    func success(with notifications: [NotificationServiceResponse]) {
        view?.stopActivityIndicator()
        
        //self.notifications = notifications
        
        for el in notifications {
            el.status = Int.random(in: 0...1) == 0 ? "UNREAD" : "READ"
            el.priority = Int.random(in: 0...1) == 0 ? 1 : 2
            self.notifications.append(el)
        }
        print("yilmaz: All notifications \(notifications.count)")
        view?.reloadTableView()
    }
    
    func success(on type: String) {
        view?.stopActivityIndicator()
        print("yilmaz: \(type)")
    }
    
    func fail(errorResponse: ErrorResponse) {
        view?.stopActivityIndicator()
    }
    
}

extension NotificationPresenter: NotificationPresenterInput {

}
