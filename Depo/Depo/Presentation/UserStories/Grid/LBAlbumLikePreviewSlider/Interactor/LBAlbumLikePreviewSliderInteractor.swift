//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderInteractor.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LBAlbumLikePreviewSliderInteractor: LBAlbumLikePreviewSliderInteractorInput {

    weak var output: LBAlbumLikePreviewSliderInteractorOutput!

    let dataStorage = LBAlbumLikePreviewSliderDataStorage()

    //MARK: - Interactor Input
    
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
        albumService.allAlbums(sortBy: .albumName, sortOrder: .asc, success: { albums in
            DispatchQueue.main.async { [weak self] in
                self?.albumItems = albums
                group.leave()
            }
        }, fail: {
            DispatchQueue.main.async { [weak self] in
                self?.output.operationFailed()
                group.leave()
            }
        })

        let storiesService = StoryService(requestSize: 4)
        storiesService.allStories(success: { stories in
            DispatchQueue.main.async { [weak self] in
                self?.storyItems = stories
                group.leave()
            }
        }, fail: {
            DispatchQueue.main.async { [weak self] in
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
}
