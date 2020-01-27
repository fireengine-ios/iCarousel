//
//  HiddenPhotosDataLoader.swift
//  Depo
//
//  Created by Andrei Novikau on 12/12/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol HiddenPhotosDataLoaderDelegate: class {
    func didLoadPhoto(items: [Item])
    func didLoadAlbum(items: [BaseDataSourceItem])
    func didFinishLoadAlbums()
    func failedLoadPhotoPage(error: Error)
    func failedLoadAlbumPage(error: Error)
}

final class HiddenPhotosDataLoader {
    
    private enum AlbumsOrder: Int {
        case people = 0
        case things
        case places
        case albums
    }
    
    private let photoPageSize = 50
    private let albumPageSize = 50
    private let albumsCountBeforeNextPage = 4
    
    private weak var delegate: HiddenPhotosDataLoaderDelegate?
    
    private lazy var hiddenService = HiddenService()
    private lazy var fileService = WrapItemFileService()
    private lazy var albumService = PhotosAlbumService()
    
    private var photoPage = 0
    private var currentAlbumsPage = 0
    private var currentLoadingAlbumType: AlbumsOrder = .people
    
    var sortedRule: SortedRules = .timeUp
    
    private var photoTask: URLSessionTask?
    private var albumsTask: URLSessionTask?
    
    private var photosIsFinishLoad = false
    private var albumsIsFinishLoad = false
    
    //MARK: - Init
    
    required init(delegate: HiddenPhotosDataLoaderDelegate?) {
        self.delegate = delegate
    }
    
    deinit {
        photoTask?.cancel()
    }
    
    //MARK: - Public methods
    
    func reloadData(completion: @escaping VoidHandler) {
        reloadPhotos(completion: completion)
        reloadAlbums()
    }
    
    func reloadPhotos(completion: @escaping VoidHandler) {
        photoPage = 0
        photoTask?.cancel()
        photoTask = nil
        photosIsFinishLoad = false
        loadNextPhotoPage(completion: completion)
    }
    
    func reloadAlbums() {
        currentLoadingAlbumType = .people
        currentAlbumsPage = 0
        albumsTask?.cancel()
        albumsTask = nil
        albumsIsFinishLoad = false
        loadNextAlbumsPage()
    }

    func loadNextPhotoPage(completion: VoidHandler? = nil) {
        guard photoTask == nil, !photosIsFinishLoad else {
            return
        }
        
        photoTask = hiddenService.hiddenList(sortBy: sortedRule.sortingRules, sortOrder: sortedRule.sortOder, page: photoPage, size: photoPageSize) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.photoTask = nil
            
            switch result {
            case .success(let response):
                self.photoPage += 1
                self.delegate?.didLoadPhoto(items: response.fileList)
                
                if response.fileList.isEmpty {
                    self.photosIsFinishLoad = true
                }
            case .failed(let error):
                self.delegate?.failedLoadPhotoPage(error: error)
            }
            
            completion?()
        }
    }
    
    func loadNextAlbumsPage() {
        guard albumsTask == nil, !albumsIsFinishLoad else {
            return
        }
        
        loadCurrentTypeAlbums { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.albumsTask = nil
            
            switch result {
            case .success(let array):
                if array.isEmpty, self.currentLoadingAlbumType == .albums {
                    //finish loading albums
                    self.albumsIsFinishLoad = true
                    self.delegate?.didFinishLoadAlbums()
                    return
                }
                
                if array.count < self.albumPageSize, let newAlbumType = AlbumsOrder(rawValue: self.currentLoadingAlbumType.rawValue + 1) {
                    self.currentLoadingAlbumType = newAlbumType
                    self.currentAlbumsPage = 0
                } else {
                    self.currentAlbumsPage += 1
                }
                
                self.delegate?.didLoadAlbum(items: array)
                
            case .failed(let error):
                self.delegate?.failedLoadAlbumPage(error: error)
            }
        }
    }
    
    func getAlbumDetails(item: Item, handler: @escaping ResponseHandler<AlbumItem>) {
        getAlbum(item: item) { result in
            switch result {
            case .success(let response):
                if let firstRemote = response.list.first {
                    let album = AlbumItem(remote: firstRemote)
                    handler(.success(album))
                } else {
                    let error = CustomErrors.text("Empty album list")
                    handler(.failed(error))
                }
            case .failed(let error):
                handler(.failed(error))
            }
        }
    }
    
    func unhide(selectedItems: HiddenPhotosDataSource.SelectedItems, handler: @escaping ResponseVoid) {
        recover(selectedItems: selectedItems, handler: handler)
    }
    
    func putBack(selectedItems: HiddenPhotosDataSource.SelectedItems, handler: @escaping ResponseVoid) {
        recover(selectedItems: selectedItems, handler: handler)
    }
    
    private func recover(selectedItems: HiddenPhotosDataSource.SelectedItems, handler: @escaping ResponseVoid) {
        let group = DispatchGroup()
        
        var unhideError: Error? = nil
        if !selectedItems.photos.isEmpty {
            group.enter()
            unhidePhotos(items: selectedItems.photos) { result in
                if case let .failed(error) = result {
                    unhideError = error
                }
                group.leave()
            }
        }
        
        if !selectedItems.albums.isEmpty {
            group.enter()
            recoverAlbums(items: selectedItems.albums) { result in
                if case let .failed(error) = result {
                    unhideError = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = unhideError {
                self.trackEvent(actionType: .unhide, status: .failure, items: selectedItems.photos + selectedItems.albums)
                handler(.failed(error))
            } else {
                self.trackEvent(actionType: .unhide, status: .success, items: selectedItems.photos + selectedItems.albums)
                handler(.success(()))
            }
        }
    }
    
    func moveToTrash(selectedItems: HiddenPhotosDataSource.SelectedItems, handler: @escaping ResponseVoid) {
        let group = DispatchGroup()

        var deleteError: Error? = nil
        if !selectedItems.photos.isEmpty {
            group.enter()
            moveToTrashPhotos(items: selectedItems.photos) { result in
                if case let .failed(error) = result {
                    deleteError = error
                }
                group.leave()
            }
        }
        
        if !selectedItems.albums.isEmpty {
            group.enter()
            moveToTrashAlbums(items: selectedItems.albums) { result in
                if case let .failed(error) = result {
                    deleteError = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = deleteError {
                self.trackEvent(actionType: .moveToTrash, status: .failure, items: selectedItems.photos + selectedItems.albums)
                handler(.failed(error))
            } else {
                self.trackEvent(actionType: .moveToTrash, status: .success, items: selectedItems.photos + selectedItems.albums)
                handler(.success(()))
            }
        }
    }
    
    //MARK: - Private methods
    
    private func loadCurrentTypeAlbums(handler: @escaping ResponseArrayHandler<BaseDataSourceItem>) {
        switch currentLoadingAlbumType {
        case .people:
            loadPeopleAlbums(handler: handler)
        case .things:
            loadThingsAlbums(handler: handler)
        case .places:
            loadPlacesAlbums(handler: handler)
        case .albums:
            loadCustomAlbums(handler: handler)
        }
    }
    
    private func loadPeopleAlbums(handler: @escaping ResponseArrayHandler<BaseDataSourceItem>) {
        albumsTask = hiddenService.hiddenPeoplePage(page: currentAlbumsPage, size: albumPageSize, handler: { result in
            switch result {
            case .success(let response):
                let array = response.list.map { PeopleItem(response: $0) }
                handler(.success(array))
            case .failed(let error):
                handler(.failed(error))
            }
        })
    }
    
    private func loadThingsAlbums(handler: @escaping ResponseArrayHandler<BaseDataSourceItem>) {
        albumsTask = hiddenService.hiddenThingsPage(page: currentAlbumsPage, size: albumPageSize, handler: { result in
            switch result {
            case .success(let response):
                let array = response.list.map { ThingsItem(response: $0) }
                handler(.success(array))
            case .failed(let error):
                handler(.failed(error))
            }
        })
    }
    
    private func loadPlacesAlbums(handler: @escaping ResponseArrayHandler<BaseDataSourceItem>) {
        albumsTask = hiddenService.hiddenPlacesPage(page: currentAlbumsPage, size: albumPageSize, handler: { result in
            switch result {
            case .success(let response):
                let array = response.list.map { PlacesItem(response: $0) }
                handler(.success(array))
            case .failed(let error):
                handler(.failed(error))
            }
        })
    }
    
    private func loadCustomAlbums(handler: @escaping ResponseArrayHandler<BaseDataSourceItem>) {
        albumsTask = hiddenService.hiddenAlbums(sortBy: .date,//sortedRule.sortingRules,
                                                sortOrder: .desc,//sortedRule.sortOder,
                                                page: currentAlbumsPage,
                                                size: albumPageSize,
                                                handler: { result in
            switch result {
            case .success(let response):
                let array = response.list.map { AlbumItem(remote: $0) }
                handler(.success(array))
            case .failed(let error):
                handler(.failed(error))
            }
        })
    }
    
    private func getAlbum(item: Item, handler: @escaping ResponseHandler<AlbumResponse>) {
        guard let id = item.id else {
            let error = CustomErrors.text("Can't open album")
            handler(.failed(error))
            return
        }
        
        if item is PeopleItem {
            hiddenService.hiddenPeopleAlbumDetail(id: Int(truncatingIfNeeded: id), handler: handler)
        } else if item is PlacesItem {
            hiddenService.hiddenPlacesAlbumDetail(id: Int(truncatingIfNeeded: id), handler: handler)
        } else if item is ThingsItem {
            hiddenService.hiddenThingsAlbumDetail(id: Int(truncatingIfNeeded: id), handler: handler)
        }
    }
    
    private func getAlbumItems(items: [BaseDataSourceItem], handler: @escaping (_ albums: [AlbumItem], _ firItems: [Item]) -> Void) {
        var albums = items.compactMap { $0 as? AlbumItem }
        
        let types: [FileType] = [.faceImage(.people), .faceImage(.places), .faceImage(.things)]
        
        let firItems = items.compactMap { baseItem -> Item? in
            if let item = baseItem as? Item, item.fileType.isContained(in: types) {
                return item
            }
            return nil
        }
        
        guard firItems.isEmpty else {
            handler(albums, firItems)
            return
        }
        
        //TODO: Need to refactoring after change API for send array of ids
        let group = DispatchGroup()
        firItems.forEach { item in
            group.enter()
            
            getAlbum(item: item) { result in
                switch result {
                case .success(let response):
                    let albumItems = response.list.map { AlbumItem(remote: $0) }
                    albums.append(contentsOf: albumItems)
                case .failed:
                    break
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            handler(albums, firItems)
        }
    }
    
    //MARK: - Unhide methods
    
    private func unhidePhotos(items: [Item], handler: @escaping ResponseVoid) {
        fileService.unhide(items: items, success: {
            handler(.success(()))
        }, fail: { error in
            handler(.failed(error))
        })
    }
    
    private func recoverAlbums(items: [BaseDataSourceItem], handler: @escaping ResponseVoid) {
        var peopleItems = [PeopleItem]()
        var placesItems = [PlacesItem]()
        var thingsItems = [ThingsItem]()
        var albumItems = [AlbumItem]()
        
        items.forEach {
            if let peopleItem = $0 as? PeopleItem {
                peopleItems.append(peopleItem)
            } else if let placeItem = $0 as? PlacesItem {
                placesItems.append(placeItem)
            } else if let thingItem = $0 as? ThingsItem {
                thingsItems.append(thingItem)
            } else if let albumItem = $0 as? AlbumItem {
                albumItems.append(albumItem)
            }
        }
    
        let group = DispatchGroup()
        
        var unhideError: Error? = nil
        
        if !peopleItems.isEmpty {
            group.enter()
            fileService.unhidePeople(items: peopleItems, success: {
                group.leave()
            }, fail: { error in
                unhideError = error
                group.leave()
            })
        }
        
        if !placesItems.isEmpty {
            group.enter()
            fileService.unhidePlaces(items: placesItems, success: {
                group.leave()
            }, fail: { error in
                unhideError = error
                group.leave()
            })
        }
        
        if !thingsItems.isEmpty {
            group.enter()
            fileService.unhideThings(items: thingsItems, success: {
                group.leave()
            }, fail: { error in
                unhideError = error
                group.leave()
            })
        }
        
        if !albumItems.isEmpty {
            group.enter()
            fileService.unhideAlbums(albumItems, success: {
                group.leave()
            }, fail: { error in
                unhideError = error
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            if let error = unhideError {
                handler(.failed(error))
            } else {
                handler(.success(()))
            }
        }
    }
    
    //MARK: - Move to trash methods

    private func moveToTrashPhotos(items: [Item], handler: @escaping ResponseVoid) {
        fileService.moveToTrash(files: items, success: {
            handler(.success(()))
        }, fail: { errorResponse in
            handler(.failed(errorResponse))
        })
    }
    
    private func moveToTrashAlbums(items: [BaseDataSourceItem], handler: @escaping ResponseVoid) {
        var peopleItems = [PeopleItem]()
        var placesItems = [PlacesItem]()
        var thingsItems = [ThingsItem]()
        var albumItems = [AlbumItem]()
        
        items.forEach {
            if let peopleItem = $0 as? PeopleItem {
                peopleItems.append(peopleItem)
            } else if let placeItem = $0 as? PlacesItem {
                placesItems.append(placeItem)
            } else if let thingItem = $0 as? ThingsItem {
                thingsItems.append(thingItem)
            } else if let albumItem = $0 as? AlbumItem {
                albumItems.append(albumItem)
            }
        }
    
        let group = DispatchGroup()
        
        var trashError: Error? = nil
        
        if !peopleItems.isEmpty {
            group.enter()
            fileService.moveToTrashPeople(items: peopleItems, success: {
                group.leave()
            }, fail: { error in
                trashError = error
                group.leave()
            })
        }
        
        if !placesItems.isEmpty {
            group.enter()
            fileService.moveToTrashPlaces(items: placesItems, success: {
                group.leave()
            }, fail: { error in
                trashError = error
                group.leave()
            })
        }
        
        if !thingsItems.isEmpty {
            group.enter()
            fileService.moveToTrashThings(items: thingsItems, success: {
                group.leave()
            }, fail: { error in
                trashError = error
                group.leave()
            })
        }
        
        if !albumItems.isEmpty {
            group.enter()
            albumService.moveToTrash(albums: albumItems, success: { trashedAlbums in
                group.leave()
            }, fail: { errorResponse in
                trashError = errorResponse
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            if let error = trashError {
                handler(.failed(error))
            } else {
                handler(.success(()))
            }
        }
    }
    
    //MARK: - Tracking
    
    private func trackEvent(actionType: ElementTypes, status: NetmeraEventValues.GeneralStatus, items: [BaseDataSourceItem]) {
        
        let typeToCountDictionary = NetmeraService.getItemsTypeToCount(items: items)

        switch actionType {
        case .restore, .unhide:
            typeToCountDictionary.keys.forEach {
                guard let count = typeToCountDictionary[$0], let event = NetmeraEvents.Actions.Unhide(status: status, type: $0, count: count) else {
                    return
                }
                AnalyticsService.sendNetmeraEvent(event: event)
            }
        case .moveToTrash:
            typeToCountDictionary.keys.forEach {
                guard let count = typeToCountDictionary[$0], let event = NetmeraEvents.Actions.Trash(status: status, type: $0, count: count) else {
                    return
                }
                AnalyticsService.sendNetmeraEvent(event: event)
            }
        default:
            break
        }
    }
}
