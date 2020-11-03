//
//  DocumentDownloadOperation.swift
//  Depo
//
//  Created by Konstantin Studilin on 30.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//



/*
 * tasks and items are arrays, but only one download task is supported for now
 */

final class DocumentDownloadOperation: Operation {

    private let semaphore = DispatchSemaphore(value: 0)
    private var tasks = [URLSessionTask?]()
    private let items: [Item]
    private let completion: VoidHandler
    private var outputURLs = [URL]()
    
    
    //MARK: - Init
    
    init(items: [Item], completion: @escaping VoidHandler) {
        self.items = items
        self.completion = completion
        
        super.init()
        
        qualityOfService = .userInteractive
    }
    
    
    //MARK: - Override
    
    override func cancel() {
        super.cancel()
        
        tasks.forEach { $0?.cancel() }
        
        semaphore.signal()
    }
    
    override func main() {
        SingletonStorage.shared.progressDelegates.add(self)
        
        download()
        semaphore.wait()

        SingletonStorage.shared.progressDelegates.remove(self)
        
        completion()
    }
    
    
    //MARK: - Private
    
    private func download() {
        let group = DispatchGroup()
        items.forEach {
            guard let url = $0.urlToFile?.byTrimmingQuery, let name = $0.name else {
                return
            }
            
            group.enter()
            
            let parameters = BaseDownloadRequestParametrs(urlToFile: url, fileName: name, contentType: $0.fileType)
            let task = FileService.shared.executeDownloadRequest(param: parameters) { [weak self] localUrl, _, error in
                defer {
                    group.leave()
                }
                
                guard let self = self else {
                    return
                }
                
                guard !self.isCancelled else {
                    return
                }
                
                self.outputURLs.append(localUrl)
            }
            tasks.append(task)
        }
        
        group.notify(queue: .main) {
            guard !self.isCancelled else {
                //semaphore.signal() is in func cancel()
                return
            }
            
            self.saveDownloaded(urls: self.outputURLs)
        }
    }
    
    private func saveDownloaded(urls: [URL]) {
        let router = RouterVC()
        let picker = UIDocumentPickerViewController(urls: urls, in: .exportToService)
        picker.delegate = self
        router.presentViewController(controller: picker)
    }
}

extension DocumentDownloadOperation: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        semaphore.signal()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        semaphore.signal()
    }
}

extension DocumentDownloadOperation: OperationProgressServiceDelegate {
    func didSend(ratio: Float, bytes: Int, for url: URL) {
        guard isExecuting, let item = items.first else {
            return
        }

        if item.urlToFile?.byTrimmingQuery == url {
            CardsManager.default.setProgress(ratio: ratio, operationType: .download, object: item)
//            ItemOperationManager.default.setProgressForDownloadingFile(file: item, progress: ratio)
        }
    }
}
