//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderInteractor.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LBAlbumLikePreviewSliderInteractor: NSObject, LBAlbumLikePreviewSliderInteractorInput, ItemOperationManagerViewProtocol {

    weak var output: LBAlbumLikePreviewSliderInteractorOutput!

    let dataStorage = LBAlbumLikePreviewSliderDataStorage()

    //MARK: - Interactor Input
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    var albumItems: [AlbumItem] {
        set {
            dataStorage.albumItems = newValue
        }
        get {
            return dataStorage.albumItems
        }
    }
    var storyItems: [Item] {
        set {
            dataStorage.storyItems = newValue
        }
        get {
            return dataStorage.storyItems
        }
    }
    var peopleItems: [Item] {
        set {
            dataStorage.peopleItems = newValue
        }
        get {
            return dataStorage.peopleItems
        }
    }
    var thingItems: [Item] {
        set {
            dataStorage.thingItems = newValue
        }
        get {
            return dataStorage.thingItems
        }
    }
    var placeItems: [Item] {
        set {
            dataStorage.placeItems = newValue
        }
        get {
            return dataStorage.placeItems
        }
    }
    
    func requestAllItems() {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "GetMyStreamData")
        
        group.enter()
        group.enter()
        
        let albumService = AlbumService(requestSize: 4)
        albumService.allAlbums(sortBy: .albumName, sortOrder: .asc, success: { [weak self] albums in
            DispatchQueue.main.async {
                self?.albumItems = albums
                group.leave()
            }
        }, fail: { [weak self] in
            DispatchQueue.main.async {
                self?.output.operationFailed()
                group.leave()
            }
        })

        let storiesService = StoryService(requestSize: 4)
        storiesService.allStories(success: { [weak self] stories in
            DispatchQueue.main.async {
                self?.storyItems = stories
                group.leave()
            }
        }, fail: { [weak self] in
            DispatchQueue.main.async {
                self?.output.operationFailed()
                group.leave()
            }
        })
        
        group.notify(queue: queue) { [weak self] in
             DispatchQueue.main.async { 
                self?.output.operationSuccessed()
            }
        }
    }
    
    //Protocol ItemOperationManagerViewProtocol
    
//    func newAlbumCreated() {
//        requestAllItems()
//    }
//
//    func albumsDeleted(albums: [AlbumItem]) {
//        if !albums.isEmpty, !albumItems.isEmpty {
//            var newArray = [AlbumItem]()
//            let albumsUUIDS = albums.map { $0.uuid }
//            for object in albumItems {
//                if !albumsUUIDS.contains(object.uuid) {
//                    newArray.append(object)
//                }
//            }
//            albumItems = newArray
//            output.preparedAlbumbs(albumbs: albumItems)
//        }
//    }

    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        if let compairedView = object as? LBAlbumLikePreviewSliderInteractor {
            return compairedView == self
        }
        return false
    }
}
