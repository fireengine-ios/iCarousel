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
        let queue = DispatchQueue(label: DispatchQueueLabels.myStreamAlbums)

        group.enter()
        faceImageAllowed { [weak self] result in
            self?.getAlbums(group: group)
            self?.getStories(group: group)
            
            if result == true {
                self?.getFaceImageItems(group: group)
            }
            group.leave()
        }
        
        group.notify(queue: queue) { [weak self] in
            self?.operationSuccessed()
        }
    }
    
    func reload(type: MyStreamType) {
        guard type.isMyStreamSliderType() else {
            return
        }
        
        let group = DispatchGroup()
        let queue = DispatchQueue(label: DispatchQueueLabels.myStreamAlbums)
        
        switch type {
        case .story:
            getStories(group: group)
        case .albums:
            getAlbums(group: group)
        case .people:
            getThumbnails(forType: .people, group: group)
        case .things:
            getThumbnails(forType: .things, group: group)
        case .places:
            getThumbnails(forType: .places, group: group)
        default:
            break
        }
        
        group.notify(queue: queue) { [weak self] in
            self?.operationSuccessed()
        }
    }
    
    private func getAlbums(group: DispatchGroup) {
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
    }
    
    private func getStories(group: DispatchGroup) {
        group.enter()
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
    }
    
    private func faceImageAllowed(completion: @escaping (_ result: Bool) -> Void) {
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
    
    private func getThumbnails(forType type: FaceImageType, group: DispatchGroup) {
        group.enter()
        faceImageService.getThumbnails(param: FaceImageThumbnailsParameters(withType: type), success: { [weak self] response in
            debugLog("FaceImageService \(type.description) Thumbnails success")
            
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
                debugLog("FaceImageService \(type.description) Thumbnails fail")
                
                DispatchQueue.main.async {
                    self?.output.operationFailed()
                    group.leave()
                }
        })
    }
    
    private func getFaceImageItems(group: DispatchGroup) {
        getThumbnails(forType: .people, group: group)
        getThumbnails(forType: .things, group: group)
        getThumbnails(forType: .places, group: group)
    }
    
    private func updateFaceImageItems() {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: DispatchQueueLabels.faceImageItemsUpdate)
        
        queue.async { [weak self] in
            self?.getFaceImageItems(group: group)
        }
        
        group.notify(queue: queue) { [weak self] in
            self?.operationSuccessed()
        }
    }
    
    private func operationSuccessed() {
        let items = currentItems.sorted(by: { item1, item2 -> Bool in
            let type1 = item1.type ?? .album
            let type2 = item2.type ?? .album
            return type1.rawValue < type2.rawValue
        })
        
        DispatchQueue.main.async {
            self.output.operationSuccessed(withItems: items)
        }
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
    
    func finishedUploadFile(file: WrapData) {
        var needUpdate = false
        currentItems.forEach { item in
            if let type = item.type, type.isFaceImageType(),
                let previews = item.previewItems, previews.count < 4 {
                needUpdate = true
            }
        }
        if needUpdate {
            updateFaceImageItems()
        }
    }

    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        if let compairedView = object as? LBAlbumLikePreviewSliderInteractor {
            return compairedView == self
        }
        return false
    }
}
