//
//  CreateCollagePhotoSelectionDataSourceProtocol.swift
//  Lifebox
//
//  Created by Ozan Salman on 6.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

protocol CreateCollagePhotoSelectionDataSourceProtocol {
    var isPaginationFinished: Bool { get }
    func reset()
    func getNext(handler: @escaping (ResponseResult<[SearchItemResponse]>) -> Void)
    func getNoFilesMessage() -> String?
    func getNoFilesPhoto() -> UIImage
}

final class CreateCollageAllPhotosSelectionDataSource: CreateCollagePhotoSelectionDataSourceProtocol {
    
    var isPaginationFinished = false
    private let photoService = PhotoService()
    private var paginationPage: Int = 0
    private let paginationPageSize: Int
    
    required init(pageSize: Int) {
        self.paginationPageSize = pageSize
    }
    
    func reset() {
        paginationPage = 0
        isPaginationFinished = false
    }
    
    func getNext(handler: @escaping (ResponseResult<[SearchItemResponse]>) -> Void) {
        let filteredItems = [SearchItemResponse]()
        
        loadNext(filteredItems: filteredItems, handler: handler)
    }
    
    private func loadNext(filteredItems: [SearchItemResponse], handler: @escaping (ResponseResult<[SearchItemResponse]>) -> Void) {
        
        photoService.loadPhotos(isFavorites: false,
                                page: paginationPage,
                                size: paginationPageSize) { [weak self] result in
            guard let `self` = self else {
                return
            }
            
            switch result {
            case .success(let items):
                self.paginationPage += 1
                
                if items.isEmpty {
                    self.isPaginationFinished = true
                    handler(ResponseResult.success(filteredItems))
                    return
                }
                
                var filteredItems = filteredItems
                /// filter missing dates
                filteredItems.append(contentsOf: items.filter {
                    guard
                        $0.metadata?.takenDate != nil,
                        let name = $0.name,
                        !name.isPathExtensionGif()
                    else {
                        return false
                    }
                        return true
                    })
                
                let isSomethingFiltered = (filteredItems.count != items.count)
                let isEnoughForPaginationSize = (filteredItems.count >= self.paginationPageSize)
                
                if isSomethingFiltered, isEnoughForPaginationSize {
                    self.loadNext(filteredItems: filteredItems, handler: handler)
                } else {
                    self.isPaginationFinished = (filteredItems.count < self.paginationPageSize)
                    handler(ResponseResult.success(filteredItems))
                }
                
            case .failed(let error):
                handler(ResponseResult.failed(error))
            }
        }
    }
    
    func getNoFilesMessage() -> String? {
        return TextConstants.thereAreNoPhotosAll
    }
    
    func getNoFilesPhoto() -> UIImage {
        return Image.iconPickNoPhotos.image
    }
}

final class CreateCollageAlbumPhotosSelectionDataSource: CreateCollagePhotoSelectionDataSourceProtocol {
    
    var isPaginationFinished = false
    private let photoService = PhotoService()
    private let albumUuid: String
    private var paginationPage: Int = 0
    private let paginationPageSize: Int
    
    required init(pageSize: Int, albumUuid: String) {
        self.paginationPageSize = pageSize
        self.albumUuid = albumUuid
    }
    
    func reset() {
        paginationPage = 0
        isPaginationFinished = false
    }
    
    func getNext(handler: @escaping (ResponseResult<[SearchItemResponse]>) -> Void) {
        let filteredItems = [SearchItemResponse]()
        
        loadNext(filteredItems: filteredItems, handler: handler)
    }
    
    private func loadNext(filteredItems: [SearchItemResponse], handler: @escaping (ResponseResult<[SearchItemResponse]>) -> Void) {
        photoService.loadAlbumPhotos(albumUuid: albumUuid, page: paginationPage, size: paginationPageSize) { [weak self] result in
            guard let `self` = self else {
                return
            }
            
            switch result {
            case .success(let items):
                self.paginationPage += 1
                
                if items.isEmpty {
                    self.isPaginationFinished = true
                    handler(ResponseResult.success(filteredItems))
                    return
                }
                
                var filteredItems = filteredItems
                /// filter missing dates and leave only images
                filteredItems.append(contentsOf: items.filter {
                    $0.metadata?.takenDate != nil &&
                    $0.contentType?.hasPrefix("image") ?? false
                })
                
                let isSomethingFiltered = (filteredItems.count != items.count)
                let isEnoughForPaginationSize = (filteredItems.count >= self.paginationPageSize)
                
                if isSomethingFiltered, isEnoughForPaginationSize {
                    self.loadNext(filteredItems: filteredItems, handler: handler)
                } else {
                    self.isPaginationFinished = (filteredItems.count < self.paginationPageSize)
                    handler(ResponseResult.success(filteredItems))
                }
                
            case .failed(let error):
                handler(ResponseResult.failed(error))
            }
        }
    }
    
    func getNoFilesMessage() -> String? {
        return "Henüz hiç Albüm oluşturulmamış"
    }
    
    func getNoFilesPhoto() -> UIImage {
        return Image.iconPickNoAlbums.image
    }
}

final class CreateCollageFavoritePhotosSelectionDataSource: CreateCollagePhotoSelectionDataSourceProtocol {
    
    var isPaginationFinished = false
    private let photoService = PhotoService()
    private var paginationPage: Int = 0
    private let paginationPageSize: Int
    
    required init(pageSize: Int) {
        self.paginationPageSize = pageSize
    }
    
    func reset() {
        paginationPage = 0
        isPaginationFinished = false
    }
    
    func getNext(handler: @escaping (ResponseResult<[SearchItemResponse]>) -> Void) {
        let filteredItems = [SearchItemResponse]()
        
        loadNext(filteredItems: filteredItems, handler: handler)
    }
    
    private func loadNext(filteredItems: [SearchItemResponse], handler: @escaping (ResponseResult<[SearchItemResponse]>) -> Void) {
        photoService.loadPhotos(isFavorites: true, page: paginationPage, size: paginationPageSize) { [weak self] result in
            guard let `self` = self else {
                return
            }
            
            switch result {
            case .success(let items):
                self.paginationPage += 1
                
                if items.isEmpty {
                    self.isPaginationFinished = true
                    handler(ResponseResult.success(filteredItems))
                    return
                }
                
                var filteredItems = filteredItems
                /// filter missing dates and leave only images
                filteredItems.append(contentsOf: items.filter {
                    $0.metadata?.takenDate != nil &&
                    $0.contentType?.hasPrefix("image") ?? false
                })
                
                let isSomethingFiltered = (filteredItems.count != items.count)
                let isEnoughForPaginationSize = (filteredItems.count >= self.paginationPageSize)
                
                if isSomethingFiltered, isEnoughForPaginationSize {
                    self.loadNext(filteredItems: filteredItems, handler: handler)
                } else {
                    self.isPaginationFinished = (filteredItems.count < self.paginationPageSize)
                    handler(ResponseResult.success(filteredItems))
                }
                
            case .failed(let error):
                handler(ResponseResult.failed(error))
            }
        }
    }

    func getNoFilesMessage() -> String? {
        return TextConstants.thereAreNoPhotosFavorites
    }
    
    func getNoFilesPhoto() -> UIImage {
        return Image.iconPickNoFavorites.image
    }
}

