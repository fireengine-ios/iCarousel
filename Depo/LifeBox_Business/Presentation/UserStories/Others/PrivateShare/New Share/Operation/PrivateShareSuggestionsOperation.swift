//
//  PrivateShareSuggestionsOperation.swift
//  Depo
//
//  Created by Alex Developer on 03.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

class PrivateShareSuggestionsOperation: Operation {
    
    private lazy var shareApiService = PrivateShareApiServiceImpl()
    private let semaphore = DispatchSemaphore(value: 0)
    private var task: URLSessionTask?
    private let suggestionsPageSize: Int = 10
    private let searchText: String
    
    
    var callback: ResponseArrayHandler<SuggestedApiContact>?
    
    init(searchText: String, callback: @escaping ResponseArrayHandler<SuggestedApiContact>) {
        self.callback = callback
        self.searchText = searchText
    }
    
    override func main() {
        guard !isCancelled else {
            callback?(.failed(CustomOperationErrors.cancelled))
            return
        }

        shareApiService.getSuggestedSubjects(searchText: searchText, size: suggestionsPageSize) { [weak self] result in
            
            guard let self = self else {
                return
            }
            guard !self.isCancelled else {
                self.callback?(.failed(CustomOperationErrors.cancelled))
                self.semaphore.signal()
                return
            }
            
            self.callback?(result)
            
        }
        
        semaphore.wait()
    }
    
    override func cancel() {
        super.cancel()
        
        task?.cancel()
        
        semaphore.signal()
    }

}
