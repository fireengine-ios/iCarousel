//
//  SmartAlbumsManager.swift
//  Depo
//
//  Created by Andrei Novikau on 11/28/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol SmartAlbumsManagerDelegate: class {
    func loadItemsComplete(items: [SliderItem])
    func loadItemsFailed()
}

protocol SmartAlbumsManager: class {
    var currentItems: [SliderItem] { get set }
    var delegates: MulticastDelegate<SmartAlbumsManagerDelegate> { get }
    func requestAllItems()
    func reload(types: [MyStreamType])
}

class SmartAlbumsManagerImpl: SmartAlbumsManager {

    let delegates = MulticastDelegate<SmartAlbumsManagerDelegate>()
    
    private lazy var reloadQueue = DispatchQueue(label: DispatchQueueLabels.myStreamAlbums)
    private let dataStorage = SmartAlbumsDataStorage()
    private let faceImageService = FaceImageService(transIdLogging: true)
    private let instaPickService: InstapickService = factory.resolve()
    
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
    
    private var isLoading = false
    
    //MARK: - Init
    
    
    init() {
        instaPickService.delegates.add(self)
        ItemOperationManager.default.startUpdateView(view: self)
    }
    
    deinit {
        instaPickService.delegates.remove(self)
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    //MARK: -
    
    func requestAllItems() {
        guard !isLoading else {
            return
        }
        isLoading = true
        
        let firstLaunch = currentItems.isEmpty
                
        currentItems = [SliderItem(withThumbnails: [], type: .hidden)]
    
        let group = DispatchGroup()

        group.enter()
        faceImageAllowed { [weak self] result in
            guard let self = self else {
                return
            }
                    
            if firstLaunch {
                self.currentItems.append(contentsOf: [SliderItem(withThumbnails: [], type: .instaPick),
                                                      SliderItem(withThumbnails: [], type: .albums),
                                                      SliderItem(withThumbnails: [], type: .story)])

                if result {
                    self.currentItems.append(contentsOf: [SliderItem(withThumbnails: [], type: .people),
                                                          SliderItem(withThumbnails: [], type: .places),
                                                          SliderItem(withThumbnails: [], type: .things)])
                }

                self.operationSuccessed()
            }

            self.getAlbums(group: group)
            self.getStories(group: group)
            self.getInstaPickThumbnails(group: group)
            
            if result == true {
                self.getFaceImageItems(group: group)
            }
            group.leave()
        }
        
        group.notify(queue: reloadQueue) { [weak self] in
            self?.operationSuccessed()
            self?.isLoading = false
        }
    }
    
    func reload(types: [MyStreamType]) {
        let myStreamTypes = types.filter {$0.isMyStreamSliderType()}
        guard !myStreamTypes.isEmpty else {
            return
        }
        
        let group = DispatchGroup()
        
        myStreamTypes.forEach { type in
            switch type {
            case .instaPick:
                getInstaPickThumbnails(group: group)
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
        }
        
        group.notify(queue: reloadQueue) { [weak self] in
            self?.operationSuccessed()
        }
    }
    
    //MARK: -
    
    private func operationSuccessed() {
        currentItems.sort(by: { item1, item2 -> Bool in
            let type1 = item1.type ?? .album
            let type2 = item2.type ?? .album
            return type1.rawValue < type2.rawValue
        })
        
        DispatchQueue.main.async {
            self.delegates.invoke(invocation: { $0.loadItemsComplete(items: self.currentItems) })
        }
    }
    
    private func operationFailed() {
        DispatchQueue.main.async {
            self.delegates.invoke(invocation: { $0.loadItemsFailed() })
        }
    }
    
    //MARK: - Private methods
    
    private func getAlbums(group: DispatchGroup) {
        group.enter()
        let albumService = AlbumService(requestSize: NumericConstants.myStreamSliderThumbnailsCount)
        albumService.allAlbums(sortBy: .date, sortOrder: .desc, success: { [weak self] albums in
            self?.dataStorage.addNew(item: SliderItem(withAlbumItems: albums))
            group.leave()
        }, fail: { [weak self] in
            self?.operationFailed()
            group.leave()
        })
    }
    
    private func getStories(group: DispatchGroup) {
        group.enter()
        let storiesService = StoryService(requestSize: NumericConstants.myStreamSliderThumbnailsCount)
        storiesService.allStories(success: { [weak self] stories in
            self?.dataStorage.addNew(item: SliderItem(withStoriesItems: stories))
            group.leave()
        }, fail: { [weak self] in
            self?.operationFailed()
            group.leave()
        })
    }
    
    private func faceImageAllowed(completion: @escaping (_ result: Bool) -> Void) {
        let accountService = AccountService()
        accountService.getSettingsInfoPermissions(handler: { [weak self] response in
            switch response {
            case .success(let result):
                guard let allowed = result.isFaceImageAllowed else {
                    completion(false)
                    return
                }
                
                completion(allowed)
            case .failed(_):
                self?.operationFailed()
                completion(false)
            }
        })
    }
    
    private func getThumbnails(forType type: FaceImageType, group: DispatchGroup) {
        group.enter()
        faceImageService.getThumbnails(param: FaceImageThumbnailsParameters(withType: type), success: { [weak self] response in
            debugLog("FaceImageService \(type.description) Thumbnails success")
            
            self?.faceImageService.debugLogTransIdIfNeeded(headers: (response as? ObjectRequestResponse)?.response?.allHeaderFields, method: "getThumbnails")
            
            let item: SliderItem
            if let thumbnails = (response as? FaceImageThumbnailsResponse)?.list {
                item = SliderItem(withThumbnails: thumbnails.map { URL(string: $0) }, type: type.myStreamType)
            } else {
                item = SliderItem(withThumbnails: [], type: type.myStreamType)
            }

            self?.dataStorage.addNew(item: item)
            group.leave()
            
        }, fail: { [weak self] error in
            debugLog("FaceImageService \(type.description) Thumbnails fail")
            self?.faceImageService.debugLogTransIdIfNeeded(errorResponse: error, method: "getThumbnails")
            self?.operationFailed()
            group.leave()
        })
    }
    
    private func getInstaPickThumbnails(group: DispatchGroup) {
        group.enter()
        instaPickService.getThumbnails { [weak self] result in
            guard let self = self else {
                group.leave()
                return
            }
            
            switch result {
            case .success(let urls):
                let item = SliderItem(withThumbnails: urls, type: .instaPick)

                self.dataStorage.addNew(item: item)
                group.leave()
                
            case .failed(_):
                self.operationFailed()
                group.leave()
            }
        }
    }
    
    private func getFaceImageItems(group: DispatchGroup) {
        getThumbnails(forType: .people, group: group)
        getThumbnails(forType: .things, group: group)
        getThumbnails(forType: .places, group: group)
    }
    
    private func updateFaceImageItems() {
        let group = DispatchGroup()
        
        reloadQueue.async { [weak self] in
            self?.getFaceImageItems(group: group)
        }
        
        group.notify(queue: reloadQueue) { [weak self] in
            self?.operationSuccessed()
        }
    }
    
    //MARK: - Overrided methods
    
    func newStoryCreated() {
        requestAllItems()
    }
    
    func finishUploadFiles() {
        var needUpdate = false
        currentItems.forEach { item in
            if let type = item.type, type.isFaceImageType(),
                let previews = item.previewItems, previews.count < NumericConstants.myStreamSliderThumbnailsCount {
                needUpdate = true
            }
        }
        if needUpdate {
            updateFaceImageItems()
        }
    }
}

//MARK: - InstaPickServiceDelegate

extension SmartAlbumsManagerImpl: InstaPickServiceDelegate {
    func didFinishAnalysis(_ analyses: [InstapickAnalyze]) {
        reload(types: [.instaPick])
    }
    
    func didRemoveAnalysis() {
        reload(types: [.instaPick])
    }
}

//MARK: - ItemOperationManagerViewProtocol

extension SmartAlbumsManagerImpl: ItemOperationManagerViewProtocol {
    
    func newAlbumCreated() {
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
        return object === self
    }
}
