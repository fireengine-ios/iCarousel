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
    
    private var updatedCells = Set<Int>()
    private let mutex = DispatchSemaphore(value: 1)
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
            
            // it is about read state.
            deleteUpdatedCells(with: index)
        }
    }
    
    func deleteUpdatedCells(with index: Int) {
        mutex.wait()
        updatedCells.remove(index)
        mutex.signal()
    }
    
    func insertUpdatedCells(member: Int) {
        mutex.wait()
        updatedCells.insert(member)
        mutex.signal()
    }
    
    func updatedCellsCount() -> Int {
        var count = 0
        mutex.wait()
        count = updatedCells.count
        mutex.signal()
        return count
    }
    
    func updatedCellsDiff(_ other: [Int]) -> Set<Int> {
        var diff = Set<Int>()
        mutex.wait()
        diff = updatedCells.symmetricDifference(other)
        mutex.signal()
        return diff
    }
    
    func read(with id: String) {
        interactor.read(with: id)
    }
}

// MARK: PackagesInteractorOutput
extension NotificationPresenter: NotificationInteractorOutput {
    
    func success(with notifications: [NotificationServiceResponse]) {
        view?.stopActivityIndicator()

        for (index, el) in notifications.enumerated() {
            self.notificationsForDisplay.append(el)
            self.notifications.append(el)
            
            if el.status == "READ" {
                self.updatedCells.insert(index)
            }
        }
        view?.reloadTableView()
        view?.reloadTimer()
    }
    
    func success(on type: String) {
        view?.stopActivityIndicator()
    }
    
    func fail(errorResponse: ErrorResponse) {
        view?.stopActivityIndicator()
    }
    
}

extension NotificationPresenter: NotificationPresenterInput {

}
