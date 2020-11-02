//
//  DocumentDownloadOperation.swift
//  Depo
//
//  Created by Konstantin Studilin on 30.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


final class DocumentDownloadOperation: Operation {
    
    private let semaphore = DispatchSemaphore(value: 0)
    private var task: URLSessionTask?
    private let item: Item
    private let completion: ValueHandler<URL?>
    private var outputURL: URL?
    
    
    //MARK: - Init
    
    init(item: Item, completion: @escaping ValueHandler<URL?>) {
        self.item = item
        self.completion = completion
        
        super.init()
        
        qualityOfService = .userInteractive
    }
    
    
    //MARK: - Override
    
    override func cancel() {
        super.cancel()
        
        task?.cancel()
        
        semaphore.signal()
    }
    
    override func main() {
        SingletonStorage.shared.progressDelegates.add(self)
        
        download()
        semaphore.wait()
        
        SingletonStorage.shared.progressDelegates.remove(self)
        
        completion(outputURL)
    }
    
    
    //MARK: - Private
    
    private func download() {
        guard let url = item.urlToFile?.byTrimmingQuery, let name = item.name else {
            semaphore.signal()
            return
        }
        
        let parameters = BaseDownloadRequestParametrs(urlToFile: url, fileName: name, contentType: item.fileType)
        task = FileService.shared.executeDownloadRequest(param: parameters) { [weak self] localUrl, _, error in
            guard let self = self else {
                return
            }
            
            guard !self.isCancelled else {
                return
            }
            
            self.outputURL = localUrl
            
            self.semaphore.signal()
        }
    }
}

extension DocumentDownloadOperation: OperationProgressServiceDelegate {
    func didSend(ratio: Float, bytes: Int, for url: URL) {
        guard isExecuting else {
            return
        }
        
        if item.urlToFile?.byTrimmingQuery == url {
            CardsManager.default.setProgress(ratio: ratio, operationType: .download, object: item)
//            ItemOperationManager.default.setProgressForDownloadingFile(file: item, progress: ratio)
        }
    }
}
