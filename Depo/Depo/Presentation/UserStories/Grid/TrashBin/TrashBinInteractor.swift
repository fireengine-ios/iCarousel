//
//  TrashBinInteractor.swift
//  Depo
//
//  Created by Andrei Novikau on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol TrashBinInteractorDelegate: class {
    func didLoad(items: [Item])
    func didLoad(albums: [BaseDataSourceItem])
    func didFinishLoadAlbums()
    func failedLoadItemsPage(error: Error)
    func failedLoadAlbumPage(error: Error)
}

final class TrashBinInteractor {

    private enum AlbumsOrder: Int {
        case people = 0
        case things
        case places
        case albums
    }

    private let itemsPageSize = 50
    private let albumPageSize = 50
    private let albumsCountBeforeNextPage = 4

    private weak var delegate: TrashBinInteractorDelegate?

    private lazy var hiddenService = HiddenService()
    private lazy var fileService = WrapItemFileService()
    private lazy var albumService = PhotosAlbumService()

    private var itemsPage = 0
    private var currentAlbumsPage = 0
    private var currentLoadingAlbumType: AlbumsOrder = .people

    var sortedRule: SortedRules = .timeUp

    private var itemsTask: URLSessionTask?
    private var albumsTask: URLSessionTask?

    private var itemsIsFinishLoad = false
    private var albumsIsFinishLoad = false

    //MARK: - Init

    required init(delegate: TrashBinInteractorDelegate?) {
        self.delegate = delegate
    }

    deinit {
        itemsTask?.cancel()
    }

    //MARK: - Public methods

    func reloadData(completion: @escaping VoidHandler) {
        reloadItems(completion: completion)
        reloadAlbums()
    }

    func reloadItems(completion: @escaping VoidHandler) {
        itemsPage = 0
        itemsTask?.cancel()
        itemsTask = nil
        itemsIsFinishLoad = false
        loadNextItemsPage(completion: completion)
    }

    func reloadAlbums() {
        currentLoadingAlbumType = .people
        currentAlbumsPage = 0
        albumsTask?.cancel()
        albumsTask = nil
        albumsIsFinishLoad = false
        loadNextAlbumsPage()
    }

    func loadNextItemsPage(completion: VoidHandler? = nil) {
        guard itemsTask == nil, !itemsIsFinishLoad else {
            return
        }
        
        itemsTask = hiddenService.trashedList(sortBy: sortedRule.sortingRules, sortOrder: sortedRule.sortOder, page: itemsPage, size: itemsPageSize, folderOnly: false, handler: {  [weak self] result in
            guard let self = self else {
                return
            }
            
            self.itemsTask = nil
            
            switch result {
            case .success(let response):
                self.itemsPage += 1
                self.delegate?.didLoad(items: response.fileList)
                
                if response.fileList.isEmpty {
                    self.itemsIsFinishLoad = true
                }
            case .failed(let error):
                self.delegate?.failedLoadItemsPage(error: error)
            }
            
            completion?()
        })
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
                
                self.delegate?.didLoad(albums: array)
                
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
        albumsTask = hiddenService.trashedPeoplePage(page: currentAlbumsPage, size: albumPageSize, handler: { result in
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
        albumsTask = hiddenService.trashedThingsPage(page: currentAlbumsPage, size: albumPageSize, handler: { result in
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
        albumsTask = hiddenService.trashedPlacesPage(page: currentAlbumsPage, size: albumPageSize, handler: { result in
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
        albumsTask = hiddenService.trashedAlbums(sortBy: .date,//sortedRule.sortingRules,
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
            hiddenService.trashedPeopleAlbumDetail(id: Int(truncatingIfNeeded: id), handler: handler)
        } else if item is PlacesItem {
            hiddenService.trashedPlacesAlbumDetail(id: Int(truncatingIfNeeded: id), handler: handler)
        } else if item is ThingsItem {
            hiddenService.trashedThingsAlbumDetail(id: Int(truncatingIfNeeded: id), handler: handler)
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
}
