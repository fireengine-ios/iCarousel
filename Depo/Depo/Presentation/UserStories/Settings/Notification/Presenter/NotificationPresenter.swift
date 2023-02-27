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
    
    private var notificationsForDisplay: [NotificationServiceResponse] = [] {
        didSet {
            view?.setEmptyView(as: !notificationsForDisplay.isEmpty)
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
        notificationsForDisplay.count
    }
    
    func getNotification(at index: Int) -> NotificationServiceResponse {
        notificationsForDisplay[index]
    }
    
    // MARK: - Three dot actions
    func showOnlyWarning() {
        notificationsForDisplay = notifications.filter({$0.priority == 1})
        view?.reloadTableView()
    }
    
    func showOnlyUnread() {
        notificationsForDisplay = notifications.filter({$0.status == "UNREAD"})
        view?.reloadTableView()
    }
    
    func showOnlyWarningAndUnread() {
        notificationsForDisplay = notifications.filter({$0.priority == 1 && $0.status == "UNREAD"})
        view?.reloadTableView()
    }
    
    func showAll() {
        /// Make sure it copies the array
        notificationsForDisplay = Array(notifications)
        view?.reloadTableView()
    }
    
    func getNotifications(at indexs: [Int]) -> [NotificationServiceResponse] {
        indexs.map { notificationsForDisplay[$0] }
    }
    
    func deleteNotification(at index: Int) {
        // first delete remote
        let idList = getIdList(with: [index])
        delete(with: idList)
        
        // Second delete from notificationsForDisplay
        notificationsForDisplay.remove(at: index)
        
        // Third delete from notifications
        deleteFromNotifications(with: idList)
    }
    
    func deleteAllNotification() {
        // first delete remote
        let idList = getIdList(with: Array(0..<notificationsForDisplay.count))
        delete(with: idList)

        // Second delete from notificationsForDisplay
        notificationsForDisplay.removeAll()
        
        // Third delete from notifications
        deleteFromNotifications(with: idList)
    }
    
    func deleteAllNotification(at indicesToRemove: [Int]) {
        // first delete remote
        let idList = getIdList(with: indicesToRemove)
        delete(with: idList)
        
        // Second delete from notificationsForDisplay
        for index in indicesToRemove.sorted(by: >) {
            notificationsForDisplay.remove(at: index)
        }
        
        // Third delete from notifications
        deleteFromNotifications(with: idList)
    }
    
    private func delete(with idList: [Int]) {
        print("yilmaz: \(idList) \(notificationsForDisplay.count)")
        interactor.delete(with: idList)
    }
    
    private func getIdList(with rows: [Int]) -> [Int] {
        var idList = [Int]()
        rows.forEach { index in
            idList.append(notificationsForDisplay[index].communicationNotificationId)
        }
        return idList
    }
    
    private func deleteFromNotifications(with idList: [Int]) {
        let indexes = idList.compactMap({id in
            notifications.firstIndex (where: { el in
                el.communicationNotificationId == id
            }
        )})
        
        for index in indexes.sorted(by: >) {
            notifications.remove(at: index)
        }
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
        //self.notifications = notifications
        
        for (index, el) in notifications.enumerated() {
            el.title! += " \(index)"
            el.status = Int.random(in: 0...1) == 0 ? "UNREAD" : "READ"
            el.priority = Int.random(in: 0...1) == 0 ? 1 : 2
            self.notificationsForDisplay.append(el)
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
