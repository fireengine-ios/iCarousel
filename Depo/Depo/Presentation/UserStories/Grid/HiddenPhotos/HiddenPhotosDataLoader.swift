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
        loadPhotos(completion: completion)
        
        currentLoadingAlbumType = .people
        currentAlbumsPage = 0
        albumsTask?.cancel()
        albumsTask = nil
        loadAlbums()
    }
    
    func loadNextPhotoPage() {
        guard photoTask == nil else {
            return
        }
        
        photoPage += 1
        loadPhotos(completion: nil)
    }
    
    func loadNextAlbumsPage() {
        guard albumsTask == nil else {
            return
        }
        
        currentAlbumsPage += 1
        loadAlbums()
    }
    
    //MARK: - Private methods
    
    private func loadPhotos(completion: VoidHandler?) {
        photoTask = hiddenService.hiddenList(sortBy: sortedRule.sortingRules, sortOrder: sortedRule.sortOder, page: photoPage, size: photoPageSize) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.photoTask = nil
            
            switch result {
            case .success(let response):
                self.delegate?.didLoadPhoto(items: response.fileList)
            case .failed(let error):
                debugPrint(error.description)
            }
            
            completion?()
        }
    }
    
    private func loadAlbums() {
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
                }
                self.delegate?.didLoadAlbum(items: array)
                
                if self.currentLoadingAlbumType == .albums {
                    if array.isEmpty {
                        //finish loading albums
                        self.delegate?.didFinishLoadAlbums()
                    }
                } else if array.count < 4 {
                    //autoload next page
                    self.loadAlbums()
                }
            case .failed(let error):
                debugPrint(error.description)
            }
        }
    }
    
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
        debugPrint("loadPeopleAlbums")
        albumsTask = hiddenService.hiddenPeoplePage(page: currentAlbumsPage, size: albumPageSize, handler: { result in
            switch result {
            case .success(let response):
                let array = response.list.map { Item(peopleItemResponse: $0) }
                debugPrint("loadPeopleAlbums - \(array.count)")
                handler(.success(array))
            case .failed(let error):
                handler(.failed(error))
            }
        })
    }
    
    private func loadThingsAlbums(handler: @escaping ResponseArrayHandler<BaseDataSourceItem>) {
        debugPrint("loadThingsAlbums")
        albumsTask = hiddenService.hiddenThingsPage(page: currentAlbumsPage, size: albumPageSize, handler: { result in
            switch result {
            case .success(let response):
                let array = response.list.map { Item(thingsItemResponse: $0) }
                debugPrint("loadThingsAlbums - \(array.count)")
                handler(.success(array))
            case .failed(let error):
                handler(.failed(error))
            }
        })
    }
    
    private func loadPlacesAlbums(handler: @escaping ResponseArrayHandler<BaseDataSourceItem>) {
        debugPrint("loadPlacesAlbums")
        albumsTask = hiddenService.hiddenPlacesPage(page: currentAlbumsPage, size: albumPageSize, handler: { result in
            switch result {
            case .success(let response):
                let array = response.list.map { Item(placesItemResponse: $0) }
                debugPrint("loadPlacesAlbums - \(array.count)")
                handler(.success(array))
            case .failed(let error):
                handler(.failed(error))
            }
        })
    }
    
    private func loadCustomAlbums(handler: @escaping ResponseArrayHandler<BaseDataSourceItem>) {
        debugPrint("loadCustomAlbums")
        albumsTask = hiddenService.hiddenAlbums(sortBy: sortedRule.sortingRules,
                                                sortOrder: sortedRule.sortOder,
                                                page: currentAlbumsPage,
                                                size: albumPageSize,
                                                handler: { result in
            switch result {
            case .success(let response):
                let array = response.list.map { AlbumItem(remote: $0) }
                debugPrint("loadCustomAlbums - \(array.count)")
                handler(.success(array))
            case .failed(let error):
                handler(.failed(error))
            }
        })
    }
}
