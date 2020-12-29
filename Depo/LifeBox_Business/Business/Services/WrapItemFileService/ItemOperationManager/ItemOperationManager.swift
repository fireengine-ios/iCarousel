//
//  UploadNotificationManager.swift
//  Depo
//
//  Created by Oleg on 27.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol ItemOperationManagerViewProtocol: class {
    
    func startUploadFile(file: WrapData)
    
    func startUploadFilesToAlbum(files: [WrapData])
    
    func setProgressForUploadingFile(file: WrapData, progress: Float)
    
    func finishedUploadFile(file: WrapData)
    
    func failedUploadFile(file: WrapData, error: Error?)
    
    ///cancelled by user
    func cancelledUpload(file: WrapData)
    
    func setProgressForDownloadingFile(file: WrapData, progress: Float)
    
    func finishedDownloadFile(file: WrapData)
    
    func addFilesToFavorites(items: [Item])
    
    func addedLocalFiles(items: [Item])
    
    func removeFileFromFavorites(items: [Item])
    
    func deleteItems(items: [Item])
    
    func newFolderCreated()
    
    func filesUpload(count: Int, toFolder folderUUID: String)
    
    func filesMoved(items: [Item], toFolder folderUUID: String)
    
    func didRenameItem(_ item: BaseDataSourceItem)
    
    func syncFinished()
    
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool
    
    func finishUploadFiles()
    
    func didMoveToTrashItems(_ items: [Item])
    func putBackFromTrashItems(_ items: [Item])
    func didEmptyTrashBin()
    
    func didShare(items: [BaseDataSourceItem])
    func didEndShareItem(uuid: String)
    func didLeaveShareItem(uuid: String)
    func didChangeRole(_ role: PrivateShareUserRole, contact: SharedContact, uuid: String)
    func didRemove(contact: SharedContact, fromItem uuid: String)
}

extension ItemOperationManagerViewProtocol {
    func startUploadFile(file: WrapData) {
        UIApplication.setIdleTimerDisabled(true)
    }
    
    func startUploadFilesToAlbum(files: [WrapData]) {
        UIApplication.setIdleTimerDisabled(true)
    }
    
    func setProgressForUploadingFile(file: WrapData, progress: Float) {}
    
    func finishedUploadFile(file: WrapData) {}
    
    func failedUploadFile(file: WrapData, error: Error?) {}
    
    func cancelledUpload(file: WrapData) {
        UIApplication.setIdleTimerDisabled(true)
    }
    
    func setProgressForDownloadingFile(file: WrapData, progress: Float) {}
    
    func finishedDownloadFile(file: WrapData) {}
    
    func addFilesToFavorites(items: [Item]) {}
    
    func addedLocalFiles(items: [Item]) {}
    
    func removeFileFromFavorites(items: [Item]) {}
    
    func deleteItems(items: [Item]) {}
    
    func newFolderCreated() {}
    
    func filesUpload(count: Int, toFolder folderUUID: String) {}
    
    func filesMoved(items: [Item], toFolder folderUUID: String) {}
    
    func didRenameItem(_ item: BaseDataSourceItem) {}
    
    func syncFinished() {
        UIApplication.setIdleTimerDisabled(false)
    }
    
    func finishUploadFiles() {
        UIApplication.setIdleTimerDisabled(false)
    }
    
    func didMoveToTrashItems(_ items: [Item]) {}
    func putBackFromTrashItems(_ items: [Item]) {}
    func didEmptyTrashBin() {}
    
    func didShare(items: [BaseDataSourceItem]) {}
    func didEndShareItem(uuid: String) {}
    func didLeaveShareItem(uuid: String) {}
    func didChangeRole(_ role: PrivateShareUserRole, contact: SharedContact, uuid: String) {}
    func didRemove(contact: SharedContact, fromItem uuid: String) {}
}


class ItemOperationManager: NSObject {
    
    static let `default` = ItemOperationManager()
    private var views = MulticastDelegate<ItemOperationManagerViewProtocol>()
    
    private var currentUploadingObject: WrapData?
    private var currentUploadProgress: Float = 0
    
    private var currentDownloadingObject: WrapData?
    private var currentDownloadingProgress: Float = 0
    
    private let serialItemOperationQueue = DispatchQueue(label: DispatchQueueLabels.serialStopUpdateItemManager)
    
    func startUpdateView(view: ItemOperationManagerViewProtocol) {
        views.add(view)
        
        if let object = currentUploadingObject {
            view.startUploadFile(file: object)
            view.setProgressForUploadingFile(file: object, progress: currentUploadProgress)
        }
    }
    
    func stopUpdateView(view: ItemOperationManagerViewProtocol) {
        serialItemOperationQueue.sync {
            views.remove(view)
        }
    }
    
    func clear() {
        views.removeAll()
    }
    
    func startUploadFile(file: WrapData) {
        currentUploadingObject = file
        
        //        DispatchQueue.main.async {
        views.invoke { $0.startUploadFile(file: file) }
        //        }
    }
    
    func startUploadFilesToAlbum(files: [WrapData]) {
        //        DispatchQueue.main.async {
        views.invoke { $0.startUploadFilesToAlbum(files: files) }
        //        }
    }
    
    func setProgressForUploadingFile(file: WrapData, progress: Float) {
        //        DispatchQueue.main.async {
        views.invoke { $0.setProgressForUploadingFile(file: file, progress: progress) }
        //        }
        
        currentUploadingObject = file
        currentUploadProgress = progress
    }
    
    
    func finishedUploadFile(file: WrapData) {
        //        DispatchQueue.main.async {
        views.invoke { $0.finishedUploadFile(file: file) }
        //        }
        
        currentUploadingObject = nil
        currentUploadProgress = 0
    }
    
    func failedUploadFile(file: WrapData, error: Error?) {
        views.invoke { $0.failedUploadFile(file: file, error: error) }
        
        currentUploadingObject = nil
        currentUploadProgress = 0
    }
    
    func cancelledUpload(file: WrapData) {
        views.invoke { $0.cancelledUpload(file: file) }
        
        currentUploadingObject = nil
        currentUploadProgress = 0
    }

    func setProgressForDownloadingFile(file: WrapData, progress: Float) {
        DispatchQueue.main.async {
            self.views.invoke { $0.setProgressForDownloadingFile(file: file, progress: progress) }
        }
        
        currentDownloadingObject = file
        currentDownloadingProgress = progress
    }
    
    func finishedDowloadFile(file: WrapData) {
        DispatchQueue.main.async {
            self.views.invoke { $0.finishedDownloadFile(file: file) }
        }
        
        currentUploadingObject = nil
        currentUploadProgress = 0
    }
    
    func addFilesToFavorites(items: [Item]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.addFilesToFavorites(items: items) }
        }
    }
    
    func removeFileFromFavorites(items: [Item]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.removeFileFromFavorites(items: items) }
        }
    }
    
    func deleteItems(items: [Item]) {
        if items.isEmpty {
            return
        }
        
        DispatchQueue.main.async {
            self.views.invoke { $0.deleteItems(items: items) }
        }
    }
    
    func addedLocalFiles(items: [Item]) {
        if items.count == 0 {
            return
        }
        
        DispatchQueue.main.async {
            self.views.invoke { $0.addedLocalFiles(items: items) }
        }
    }
    
    func newFolderCreated() {
        DispatchQueue.main.async {
            self.views.invoke { $0.newFolderCreated() }
        }
    }
    
    func filesUpload(count: Int, toFolder folderUUID: String) {
        DispatchQueue.main.async {
            self.views.invoke { $0.filesUpload(count: count, toFolder: folderUUID) }
        }
    }
    
    func filesMoved(items: [Item], toFolder folderUUID: String) {
        DispatchQueue.main.async {
            self.views.invoke { $0.filesMoved(items: items, toFolder: folderUUID) }
        }
    }
    
    func didRenameItem(_ item: BaseDataSourceItem) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didRenameItem(item) }
        }
    }
    
    func syncFinished() {
//        DispatchQueue.main.async {
        currentUploadingObject = nil
        views.invoke { $0.syncFinished() }
//        }
    }

    func finishUploadFiles() {
        DispatchQueue.main.async {
            self.views.invoke { $0.finishUploadFiles() }
        }
    }
       
    func didMoveToTrashItems(_ items: [Item]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didMoveToTrashItems(items) }
        }
    }
            
    func putBackFromTrashItems(_ items: [Item]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.putBackFromTrashItems(items) }
        }
    }
    
    func didEmptyTrashBin() {
        DispatchQueue.main.async {
            self.views.invoke { $0.didEmptyTrashBin() }
        }
    }
    
    func didShare(items: [BaseDataSourceItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didShare(items: items) }
        }
    }
    
    func didEndShareItem(uuid: String) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didEndShareItem(uuid: uuid) }
        }
    }
    
    func didLeaveShareItem(uuid: String) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didLeaveShareItem(uuid: uuid) }
        }
    }
    
    func didChangeRole(_ role: PrivateShareUserRole, contact: SharedContact, uuid: String) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didChangeRole(role, contact: contact, uuid: uuid) }
        }
    }
    
    func didRemove(contact: SharedContact, fromItem uuid: String) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didRemove(contact: contact, fromItem: uuid) }
        }
    }
}
