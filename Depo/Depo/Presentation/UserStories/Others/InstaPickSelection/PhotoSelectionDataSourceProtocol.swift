import Foundation

protocol PhotoSelectionDataSourceProtocol {
    var isPaginationFinished: Bool { get }
    func reset()
    func getNext(handler: @escaping (ResponseResult<[SearchItemResponse]>) -> Void)
}

final class AllPhotosSelectionDataSource: PhotoSelectionDataSourceProtocol {
    
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
                filteredItems.append(contentsOf: items.filter { $0.metadata?.smalURl != nil })
                
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
}

final class AlbumPhotosSelectionDataSource: PhotoSelectionDataSourceProtocol {
    
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
                    $0.metadata?.smalURl != nil &&
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
}

final class FavoritePhotosSelectionDataSource: PhotoSelectionDataSourceProtocol {
    
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
                    $0.metadata?.smalURl != nil &&
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
}
