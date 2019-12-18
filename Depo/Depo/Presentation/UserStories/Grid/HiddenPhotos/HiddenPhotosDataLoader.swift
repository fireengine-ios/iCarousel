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
    
    private weak var delegate: HiddenPhotosDataLoaderDelegate?
    
    private lazy var hiddenService = HiddenService()
    
    private var photoPage = 0
    private var currentAlbumsPage = 0
    private var currentLoadingAlbumType: AlbumsOrder = .people
    
    var sortedRule: SortedRules = .timeDown
    
    private var photoTask: URLSessionTask?
    private var albumsTask: URLSessionTask?
    
    //MARK: - Init
    
    required init(delegate: HiddenPhotosDataLoaderDelegate?) {
        self.delegate = delegate
    }
    
    deinit {
        photoTask?.cancel()
    }
    
    //MARK: - Public methods
    
    func reloadData(completion: @escaping VoidHandler) {
        photoPage = 0
        photoTask?.cancel()
        photoTask = nil
        loadNextPhotoPage(completion: completion)
        
        currentLoadingAlbumType = .people
        currentAlbumsPage = 0
        albumsTask?.cancel()
        albumsTask = nil
        loadNextAlbumsPage()
    }

    func loadNextPhotoPage(completion: VoidHandler? = nil) {
        guard photoTask == nil else {
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
            case .failed(let error):
                debugPrint(error.description)
            }
            
            completion?()
        }
    }
    
    func loadNextAlbumsPage() {
        guard albumsTask == nil else {
            return
        }
        
        loadCurrentTypeAlbums { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.albumsTask = nil
            
            switch result {
            case .success(let array):
                if array.count < self.albumPageSize, let newAlbumType = AlbumsOrder(rawValue: self.currentLoadingAlbumType.rawValue + 1) {
                    self.currentLoadingAlbumType = newAlbumType
                    self.currentAlbumsPage = 0
                } else {
                    self.currentAlbumsPage += 1
                }
                self.delegate?.didLoadAlbum(items: array)
                
                if self.currentLoadingAlbumType == .albums {
                    if array.isEmpty {
                        //finish loading albums
                        self.delegate?.didFinishLoadAlbums()
                    }
                } else if array.count < 4 {
                    //autoload next page
                    self.loadNextAlbumsPage()
                }
            case .failed(let error):
                debugPrint(error.description)
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
    
    //MARK: - Unhide methods
    
    func unhidePhotos(items: [Item], handler: @escaping ResponseVoid) {
        _ = hiddenService.recoverItems(items, handler: handler)
    }
    
    func unhideAlbums(items: [BaseDataSourceItem], handler: @escaping ResponseVoid) {
        getAlbumItems(items: items) { [weak self] albums in
            _ = self?.hiddenService.recoverAlbums(albums, handler: handler)
        }
    }
    
    //MARK: - Delete methods
    
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
        albumsTask = hiddenService.hiddenAlbums(sortBy: sortedRule.sortingRules,
                                                sortOrder: sortedRule.sortOder,
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
            _ = hiddenService.hiddenPeopleAlbumDetail(id: Int(truncatingIfNeeded: id), handler: handler)
        } else if item is PlacesItem {
            _ = hiddenService.hiddenPlacesAlbumDetail(id: Int(truncatingIfNeeded: id), handler: handler)
        } else if item is ThingsItem {
            _ = hiddenService.hiddenThingsAlbumDetail(id: Int(truncatingIfNeeded: id), handler: handler)
        }
    }
    
    private func getAlbumItems(items: [BaseDataSourceItem], handler: @escaping ([AlbumItem]) -> Void) {
        var albums = items.compactMap { $0 as? AlbumItem }
        
        let types: [FileType] = [.faceImage(.people), .faceImage(.places), .faceImage(.things)]
        let firItems = items.filter { ($0 as? Item)?.fileType.isContained(in: types) == true } as! [Item]
        
        if firItems.isEmpty {
            handler(albums)
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
            handler(albums)
        }
    }
}
