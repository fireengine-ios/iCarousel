//
//  HiddenPhotosDataLoader.swift
//  Depo
//
//  Created by Andrei Novikau on 12/12/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

protocol HiddenPhotosDataLoaderDelegate: class {
    func didLoadPhoto(items: [Item])
    func didLoadAlbum(items: [AlbumItem])
}

final class HiddenPhotosDataLoader {
    
    private enum AlbumsOrder {
        case people
        case things
        case places
        case albums
    }
    
    private let albumPageSize = 50
    
    private weak var delegate: HiddenPhotosDataLoaderDelegate?
    
    private lazy var fileService = FileService.shared
    private lazy var albumService = AlbumService(requestSize: 100)
    private lazy var peopleService = PeopleService()
    private lazy var thingsService = ThingsService()
    private lazy var placesService = PlacesService()
    
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
    
    func reloadData() {
        photoPage = 0
        photoTask?.cancel()
        photoTask = nil
        loadPhotos()
        
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
        loadPhotos()
    }
    
    func loadNextAlbumsPage() {
        guard albumsTask == nil else {
            return
        }
        
        currentAlbumsPage += 1
        loadAlbums()
    }
    
    //MARK: - Private methods
    
    private func loadPhotos() {
        hiddenList(sortBy: sortedRule.sortingRules, sortOrder: sortedRule.sortOder, page: photoPage, size: 20) { [weak self] result in
            self?.photoTask = nil
            
            switch result {
            case .success(let response):
                self?.delegate?.didLoadPhoto(items: response.fileList)
            case .failed(let error):
                debugPrint(error.description)
            }
        }
    }
    
    private func loadAlbums() {
        switch currentLoadingAlbumType {
        case .people:
            loadPeopleAlbums()
        case .things:
            loadThingsAlbums()
        case .places:
            loadPlacesAlbums()
        case .albums:
            loadCustomAlbums()
        }
    }
    
    private func loadPeopleAlbums() {
        
    }
    
    private func loadThingsAlbums() {
        
    }
    
    private func loadPlacesAlbums() {
        
    }
    
    private func loadCustomAlbums() {
        
    }
    
    private func hiddenList(sortBy: SortType, sortOrder: SortOrder, page: Int,size: Int, handler: @escaping (ResponseResult<FileListResponse>) -> Void) {//-> URLSessionTask {
//        let url = RouteRequests.baseUrl +/ "filesystem/hidden?sortBy=\(sortBy.description)&sortOrder=\(sortOrder.description)&page=\(page)&size=\(size)&category=photos_and_videos"
        
        let hiddenList = RouteRequests.baseUrl.absoluteString + "filesystem/hidden?sortBy=%@&sortOrder=%@&page=%@&size=%@&category=photos_and_videos"
            
        let url = String(format: hiddenList, sortBy.description, sortOrder.description, page.description, size.description)
        
        debugPrint(url)
        
        SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseObject(handler)
    }
}
