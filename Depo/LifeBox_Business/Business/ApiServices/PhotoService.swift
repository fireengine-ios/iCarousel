import Foundation

final class PhotoService {
    
    private var requestTask: URLSessionTask?
    private let searchService = SearchService()
    
    func loadPhotos(isFavorites: Bool, page: Int, size: Int, handler: @escaping (ResponseResult<[SearchItemResponse]>) -> Void) {
        
        let requestParam = SearchByFieldParameters(fieldName: isFavorites ? .favorite : .content_type,
                                                   fieldValue: isFavorites ? .favorite : .image,
                                                   sortBy: .imageDate,
                                                   sortOrder: .desc,
                                                   page: page,
                                                   size: size,
                                                   minified: false,
                                                   hidden: false)
        
        requestTask = searchService.searchByField(param: requestParam, success: { response  in
            
            guard let result = (response as? SearchResponse)?.list else {
                assertionFailure()
                let error = CustomErrors.serverError("failed parsing searchService.searchByField")
                handler(.failed(error))
                return
            }
            
            handler(.success(result))
        }, fail: { errorResponse in
            handler(.failed(errorResponse))
        })
    }
    
    func cancelCurrentTask() {
        requestTask?.cancel()
    }
}
