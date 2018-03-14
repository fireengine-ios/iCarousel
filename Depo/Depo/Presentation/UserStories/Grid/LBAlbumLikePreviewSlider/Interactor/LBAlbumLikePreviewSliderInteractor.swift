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
    
    let faceImageService = FaceImageService()

    // MARK: - Interactor Input
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    var currentItems: [SliderItem] {
        set {
            dataStorage.currentItems = newValue
        }
        get {
            return dataStorage.currentItems.sorted(by: { item1, item2 -> Bool in
                if let type1 = item1.type?.rawValue, let type2 = item2.type?.rawValue {
                    return type1 < type2
                }
                return false
            })
        }
    }

    func requestAllItems() {
        currentItems = []
        
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "GetMyStreamData")
        
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        
        let albumService = AlbumService(requestSize: 4)
        albumService.allAlbums(sortBy: .date, sortOrder: .desc, success: { [weak self] albums in
            DispatchQueue.main.async {
                self?.dataStorage.addNew(item: SliderItem(withAlbumItems: albums))
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
                self?.dataStorage.addNew(item: SliderItem(withStoriesItems: stories))
                group.leave()
            }
        }, fail: { [weak self] in
            DispatchQueue.main.async {
                self?.output.operationFailed()
                group.leave()
            }
        })
        
        faceImageAllowed { [weak self] result in
            if result == true {
                self?.getThumbnails(forType: .people, group: group)
                self?.getThumbnails(forType: .things, group: group)
                self?.getThumbnails(forType: .places, group: group)
            } else {
                DispatchQueue.main.async {
                    group.leave()
                    group.leave()
                    group.leave()
                }
            }
        }
        
        group.notify(queue: queue) { [weak self] in
             DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }
                
                let items = self.currentItems.sorted(by: { item1, item2 -> Bool in
                    let type1 = item1.type ?? .album
                    let type2 = item2.type ?? .album
                    return type1.rawValue < type2.rawValue
                })
                
                self.output.operationSuccessed(withItems: items)
            }
        }
    }
    
    fileprivate func faceImageAllowed(completion: @escaping (_ result: Bool) -> Void) {
        let accountService = AccountService()
        accountService.faceImageAllowed(success: { response in
            if let response = response as? FaceImageAllowedResponse, let allowed = response.allowed {
                completion(allowed)
            } else {
                completion(false)
            }
            
        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.output.operationFailed()
                completion(false)
            }
        })
    }
    
    fileprivate func getThumbnails(forType type: FaceImageType, group: DispatchGroup) {
        faceImageService.getThumbnails(param: FaceImageThumbnailsParameters(withType: type), success: { [weak self] response in
            log.debug("FaceImageService \(type.description) Thumbnails success")
            
            let item: SliderItem
            if let thumbnails = (response as? FaceImageThumbnailsResponse)?.list {
                item = SliderItem(withThumbnails: thumbnails.map { URL(string: $0) }, type: type.myStreamType)
            } else {
                item = SliderItem(withThumbnails: [], type: type.myStreamType)
            }

            DispatchQueue.main.async {
                self?.dataStorage.addNew(item: item)
                group.leave()
            }
            
            }, fail: { [weak self] error in
                log.debug("FaceImageService \(type.description) Thumbnails fail")
                
                DispatchQueue.main.async {
                    self?.output.operationFailed()
                    group.leave()
                }
        })
    }
    
    //Protocol ItemOperationManagerViewProtocol
    
    func newAlbumCreated() {
        requestAllItems()
    }
    
    func newStoryCreated() {
        requestAllItems()
    }
    
    func updatedAlbumCoverPhoto(item: BaseDataSourceItem) {
        requestAllItems()
    }
    
    func albumsDeleted(albums: [AlbumItem]) {
        requestAllItems()
    }
    
    func deleteStories(items: [Item]) {
        requestAllItems()
    }
    
    func filesAddedToAlbum() {
        requestAllItems()
    }
    
    func filesRomovedFromAlbum(items: [Item], albumUUID: String) {
        requestAllItems()
    }

    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        if let compairedView = object as? LBAlbumLikePreviewSliderInteractor {
            return compairedView == self
        }
        return false
    }
}
