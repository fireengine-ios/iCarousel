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
    
    func filesUploadToFolder()
    
    func filesRomovedFromAlbum(items: [Item], albumUUID: String)
    
    func filesMoved(items: [Item], toFolder folderUUID: String)
    
    func syncFinished()

    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool
    
}

extension ItemOperationManagerViewProtocol {
    func startUploadFile(file: WrapData) {}
    
    func startUploadFilesToAlbum(files: [WrapData]) {}
    
    func setProgressForUploadingFile(file: WrapData, progress: Float) {}
    
    func finishedUploadFile(file: WrapData) {}
    
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
    
    func filesUploadToFolder() {}
    
    func filesRomovedFromAlbum(items: [Item], albumUUID: String) {}
    
    func filesMoved(items: [Item], toFolder folderUUID: String) {}
    
    func syncFinished() {}
    
}


class ItemOperationManager: NSObject {
    
    static let `default` = ItemOperationManager()
    private var views = [ItemOperationManagerViewProtocol]()
    
    private var currentUploadingObject: WrapData?
    private var currentUploadProgress: Float = 0
    
    private var currentDownloadingObject: WrapData?
    private var currentDownloadingProgress: Float = 0
    
    func startUpdateView(view: ItemOperationManagerViewProtocol){
        if views.index(where: {$0.isEqual(object: view)}) == nil{
            views.append(view)
        }
        
        if currentUploadingObject != nil{
            view.startUploadFile(file: currentUploadingObject!)
            view.setProgressForUploadingFile(file: currentUploadingObject!, progress: currentUploadProgress)
        }
    }
    
    func stopUpdateView(view: ItemOperationManagerViewProtocol){
        if let index = views.index(where: {$0.isEqual(object: view)}){
            views.remove(at: index)
        }
    }
    
    func startUploadFile(file: WrapData){
        currentUploadingObject = file
        
        DispatchQueue.main.async {
            for view in self.views{
                view.startUploadFile(file: file)
            }
        }
    }
    
    func startUploadFilesToAlbum(files: [WrapData]) {
        DispatchQueue.main.async {
            for view in self.views {
                view.startUploadFilesToAlbum(files: files)
            }
        }
    }
    
    func setProgressForUploadingFile(file: WrapData, progress: Float){
        DispatchQueue.main.async {
            for view in self.views{
                view.setProgressForUploadingFile(file: file, progress: progress)
            }
        }
        
        currentUploadingObject = file
        currentUploadProgress = progress
    }
    
    
    
    func finishedUploadFile(file: WrapData){
        DispatchQueue.main.async {
            for view in self.views{
                view.finishedUploadFile(file: file)
            }
        }
        
        MenloworksAppEvents.onFileUploadedWithType(file.fileType)
        
        currentUploadingObject = nil
        currentUploadProgress = 0
    }
    
    func setProgressForDownloadingFile(file: WrapData, progress: Float) {
        DispatchQueue.main.async {
            for view in self.views{
                view.setProgressForDownloadingFile(file: file, progress: progress)
            }
        }
        
        currentDownloadingObject = file
        currentDownloadingProgress = progress
    }
    
    func finishedDowloadFile(file: WrapData) {
        DispatchQueue.main.async {
            for view in self.views{
                view.finishedDownloadFile(file: file)
            }
        }
        
        currentUploadingObject = nil
        currentUploadProgress = 0
    }
    
    func addFilesToFavorites(items: [Item]){
        DispatchQueue.main.async {
            for view in self.views{
                view.addFilesToFavorites(items: items)
            }
        }
    }
    
    func removeFileFromFavorites(items: [Item]){
        DispatchQueue.main.async {
            for view in self.views{
                view.removeFileFromFavorites(items: items)
            }
        }
    }
    
    func deleteItems(items: [Item]){
        if items.count == 0{
            return
        }
        
        DispatchQueue.main.async {
            for view in self.views{
                view.deleteItems(items: items)
            }
        }
    }
    
    func deleteStories(items: [Item]) {
        if items.count == 0 {
            return
        }
        
        DispatchQueue.main.async {
            for view in self.views {
                view.deleteStories(items: items)
            }
        }
    }
    
    func addedLocalFiles(items: [Item]){
        if items.count == 0{
            return
        }
        
        DispatchQueue.main.async {
            for view in self.views{
                view.addedLocalFiles(items: items)
            }
        }
    }
    
    func newFolderCreated(){
        DispatchQueue.main.async {
            for view in self.views{
                view.newFolderCreated()
            }
        }
    }
    
    func newAlbumCreated(){
        DispatchQueue.main.async {
            for view in self.views{
                view.newAlbumCreated()
            }
        }
    }
    
    func updatedAlbumCoverPhoto(item: BaseDataSourceItem) {
        DispatchQueue.main.async {
            for view in self.views{
                view.updatedAlbumCoverPhoto(item: item)
            }
        }
    }
    
    func albumsDeleted(albums: [AlbumItem]){
        DispatchQueue.main.async {
            for view in self.views{
                view.albumsDeleted(albums: albums)
            }
        }
    }
    
    func filesAddedToAlbum() {
        DispatchQueue.main.async {
            for view in self.views {
                view.filesAddedToAlbum()
            }
        }
    }
    
    func fileAddedToAlbum(item: WrapData, error: Bool = false) {
        DispatchQueue.main.async {
            for view in self.views {
                view.fileAddedToAlbum(item: item, error: error)
            }
        }
    }
    
    func filesUploadToFolder() {
        DispatchQueue.main.async {
            for view in self.views {
                view.filesUploadToFolder()
            }
        }
    }
    
    func filesRomovedFromAlbum(items: [Item], albumUUID: String){
        DispatchQueue.main.async {
            for view in self.views{
                view.filesRomovedFromAlbum(items: items, albumUUID: albumUUID)
            }
        }
    }
    
    func filesMoved(items: [Item], toFolder folderUUID: String){
        DispatchQueue.main.async {
            for view in self.views{
                view.filesMoved(items: items, toFolder: folderUUID)
            }
        }
    }
    
    func syncFinished(){
        DispatchQueue.main.async {
            for view in self.views{
                view.syncFinished()
            }
        }
    }
    
    func newStoryCreated() {
        DispatchQueue.main.async {
            for view in self.views {
                view.newStoryCreated()
            }
        }
    }
    
}

