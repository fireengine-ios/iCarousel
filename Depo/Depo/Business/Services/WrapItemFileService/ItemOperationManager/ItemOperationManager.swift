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
    
    ///cancelled by user
    func cancelledUpload(file: WrapData)
    
    func setProgressForDownloadingFile(file: WrapData, progress: Float)
    
    func finishedDownloadFile(file: WrapData)
    
    func addFilesToFavorites(items: [Item])
    
    func addedLocalFiles(items: [Item])
    
    func removeFileFromFavorites(items: [Item])
    
    func deleteItems(items: [Item])
    
    func deleteStories(items: [Item])
    
    func newFolderCreated()
    
    func newAlbumCreated()
    
    func newStoryCreated()
    
    func updatedAlbumCoverPhoto(item: BaseDataSourceItem)
    
    func albumsDeleted(albums: [AlbumItem])
    
    func fileAddedToAlbum(item: WrapData, error: Bool)
    
    func filesAddedToAlbum()
    
    func filesUpload(count: Int, toFolder folderUUID: String)
    
    func filesRomovedFromAlbum(items: [Item], albumUUID: String)
    
    func filesMoved(items: [Item], toFolder folderUUID: String)
    
    func didRenameItem(_ item: BaseDataSourceItem)
    
    func syncFinished()
    
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool
    
    func finishUploadFiles()
    
    func didHideItems(_ items: [WrapData])
    func didHideAlbums(_ albums: [AlbumItem])
    func didHidePeople(items: [PeopleItem])
    func didHidePlaces(items: [PlacesItem])
    func didHideThings(items: [ThingsItem])
    
    func didUnhideItems(_ items: [WrapData])
    func didUnhideAlbums(_ albums: [AlbumItem])
    func didUnhidePeople(items: [PeopleItem])
    func didUnhidePlaces(items: [PlacesItem])
    func didUnhideThings(items: [ThingsItem])
    
    func didMoveToTrashItems(_ items: [Item])
    func didMoveToTrashAlbums(_ albums: [AlbumItem])
    func didMoveToTrashPeople(items: [PeopleItem])
    func didMoveToTrashPlaces(items: [PlacesItem])
    func didMoveToTrashThings(items: [ThingsItem])
    
    func putBackFromTrashItems(_ items: [Item])
    func putBackFromTrashAlbums(_ albums: [AlbumItem])
    func putBackFromTrashPeople(items: [PeopleItem])
    func putBackFromTrashPlaces(items: [PlacesItem])
    func putBackFromTrashThings(items: [ThingsItem])
}

extension ItemOperationManagerViewProtocol {
    func startUploadFile(file: WrapData) {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    func startUploadFilesToAlbum(files: [WrapData]) {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    func setProgressForUploadingFile(file: WrapData, progress: Float) {}
    
    func finishedUploadFile(file: WrapData) {}
    
    func cancelledUpload(file: WrapData) {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    func setProgressForDownloadingFile(file: WrapData, progress: Float) {}
    
    func finishedDownloadFile(file: WrapData) {}
    
    func addFilesToFavorites(items: [Item]) {}
    
    func addedLocalFiles(items: [Item]) {}
    
    func removeFileFromFavorites(items: [Item]) {}
    
    func deleteItems(items: [Item]) {}
    
    func deleteStories(items: [Item]) {}
    
    func newFolderCreated() {}
    
    func newAlbumCreated() {}
    
    func newStoryCreated() {}
    
    func updatedAlbumCoverPhoto(item: BaseDataSourceItem) {}
    
    func albumsDeleted(albums: [AlbumItem]) {}
    
    func fileAddedToAlbum(item: WrapData, error: Bool) {}
    
    func filesAddedToAlbum() {}
    
    func filesUpload(count: Int, toFolder folderUUID: String) {}
    
    func filesRomovedFromAlbum(items: [Item], albumUUID: String) {}
    
    func filesMoved(items: [Item], toFolder folderUUID: String) {}
    
    func didRenameItem(_ item: BaseDataSourceItem) {}
    
    func syncFinished() {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    func finishUploadFiles() {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    func didHideItems(_ items: [WrapData]) {}
    func didHideAlbums(_ albums: [AlbumItem]) {}
    func didHidePeople(items: [PeopleItem]) {}
    func didHidePlaces(items: [PlacesItem]) {}
    func didHideThings(items: [ThingsItem]) {}
    
    func didUnhideItems(_ items: [WrapData]) {}
    func didUnhideAlbums(_ albums: [AlbumItem]) {}
    func didUnhidePeople(items: [PeopleItem]) {}
    func didUnhidePlaces(items: [PlacesItem]) {}
    func didUnhideThings(items: [ThingsItem]) {}
    
    func didMoveToTrashItems(_ items: [Item]) {}
    func didMoveToTrashAlbums(_ albums: [AlbumItem]) {}
    func didMoveToTrashPeople(items: [PeopleItem]) {}
    func didMoveToTrashPlaces(items: [PlacesItem]) {}
    func didMoveToTrashThings(items: [ThingsItem]) {}
    
    func putBackFromTrashItems(_ items: [Item]) {}
    func putBackFromTrashAlbums(_ albums: [AlbumItem]) {}
    func putBackFromTrashPeople(items: [PeopleItem]) {}
    func putBackFromTrashPlaces(items: [PlacesItem]) {}
    func putBackFromTrashThings(items: [ThingsItem]) {}
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
        
        if currentUploadingObject != nil {
            view.startUploadFile(file: currentUploadingObject!)
            view.setProgressForUploadingFile(file: currentUploadingObject!, progress: currentUploadProgress)
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
    
    
    func finishedUploadFile(file: WrapData, isAutoSync: Bool) {
        //        DispatchQueue.main.async {
        views.invoke { $0.finishedUploadFile(file: file) }
        //        }
        
        MenloworksAppEvents.onFileUploadedWithType(file.fileType, isAutosync: isAutoSync)
        
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
    
    func deleteStories(items: [Item]) {
        if items.isEmpty {
            return
        }
        
        DispatchQueue.main.async {
            self.views.invoke { $0.deleteStories(items: items) }
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
    
    func newAlbumCreated() {
        DispatchQueue.main.async {
            self.views.invoke { $0.newAlbumCreated() }
        }
    }
    
    func updatedAlbumCoverPhoto(item: BaseDataSourceItem) {
        DispatchQueue.main.async {
            self.views.invoke { $0.updatedAlbumCoverPhoto(item: item) }
        }
    }
    
    func albumsDeleted(albums: [AlbumItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.albumsDeleted(albums: albums) }
        }
    }
    
    func filesAddedToAlbum() {
        DispatchQueue.main.async {
            self.views.invoke { $0.filesAddedToAlbum() }
        }
    }
    
    func fileAddedToAlbum(item: WrapData, error: Bool = false) {
        DispatchQueue.main.async {
            self.views.invoke { $0.fileAddedToAlbum(item: item, error: error) }
        }
    }
    
    func filesUpload(count: Int, toFolder folderUUID: String) {
        DispatchQueue.main.async {
            self.views.invoke { $0.filesUpload(count: count, toFolder: folderUUID) }
        }
    }
    
    func filesRomovedFromAlbum(items: [Item], albumUUID: String) {
        DispatchQueue.main.async {
            self.views.invoke { $0.filesRomovedFromAlbum(items: items, albumUUID: albumUUID) }
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
        views.invoke { $0.syncFinished() }
//        }
    }
    
    func newStoryCreated() {
        DispatchQueue.main.async {
            self.views.invoke { $0.newStoryCreated() }
        }
    }
    
    func finishUploadFiles() {
        DispatchQueue.main.async {
            self.views.invoke { $0.finishUploadFiles() }
        }
    }

    func didHideItems(_ items: [WrapData]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didHideItems(items) }
        }
    }
    
    func didHideAlbums(_ albums: [AlbumItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didHideAlbums(albums) }
        }
    }
    
    func didHidePeople(items: [PeopleItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didHidePeople(items: items) }
        }
    }
    
    func didHidePlaces(items: [PlacesItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didHidePlaces(items: items) }
        }
    }
    
    func didHideThings(items: [ThingsItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didHideThings(items: items) }
        }
    }
       
    func didUnhideItems(_ items: [WrapData]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didUnhideItems(items) }
        }
    }
    
    func didUnhideAlbums(_ albums: [AlbumItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didUnhideAlbums(albums) }
        }
    }
    
    func didUnhidePeople(items: [PeopleItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didUnhidePeople(items: items) }
        }
    }
    
    func didUnhidePlaces(items: [PlacesItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didUnhidePlaces(items: items) }
        }
    }
    
    func didUnhideThings(items: [ThingsItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didUnhideThings(items: items) }
        }
    }
       
    func didMoveToTrashItems(_ items: [Item]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didMoveToTrashItems(items) }
        }
    }
    
    func didMoveToTrashAlbums(_ albums: [AlbumItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didMoveToTrashAlbums(albums) }
        }
    }
    
    func didMoveToTrashPeople(items: [PeopleItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didMoveToTrashPeople(items: items) }
        }
    }
    
    func didMoveToTrashPlaces(items: [PlacesItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didMoveToTrashPlaces(items: items) }
        }
    }
    
    func didMoveToTrashThings(items: [ThingsItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.didMoveToTrashThings(items: items) }
        }
    }
       
    func putBackFromTrashItems(_ items: [Item]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.putBackFromTrashItems(items) }
        }
    }
    
    func putBackFromTrashAlbums(_ albums: [AlbumItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.putBackFromTrashAlbums(albums) }
        }
    }
    
    func putBackFromTrashPeople(items: [PeopleItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.putBackFromTrashPeople(items: items) }
        }
    }
    
    func putBackFromTrashPlaces(items: [PlacesItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.putBackFromTrashPlaces(items: items) }
        }
    }
    
    func putBackFromTrashThings(items: [ThingsItem]) {
        DispatchQueue.main.async {
            self.views.invoke { $0.putBackFromTrashThings(items: items) }
        }
    }
}
