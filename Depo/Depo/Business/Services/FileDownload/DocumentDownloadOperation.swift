//
//  DocumentDownloadOperation.swift
//  Depo
//
//  Created by Konstantin Studilin on 30.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//



typealias DocumentDownloadHandler = (_ isSaved: Bool, _ error: Error?) -> ()


final class DocumentDownloadOperation: Operation {

    private let semaphore = DispatchSemaphore(value: 0)
    private var task: URLSessionTask?
    private var items: [Item]
    private var currentItem: Item?
    private let onCompletion: DocumentDownloadHandler
    private let onDownload: VoidHandler
    private var outputURLs = [URL]()
    private var isSaved = false
    private var lastError: Error?
    
    
    //MARK: - Init
    
    init(items: [Item], onDownload: @escaping VoidHandler, onCompletion: @escaping DocumentDownloadHandler) {
        self.items = items
        self.onCompletion = onCompletion
        self.onDownload = onDownload
        
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
        
        downloadNext()
        semaphore.wait()

        SingletonStorage.shared.progressDelegates.remove(self)
        
        onCompletion(isSaved, lastError)
    }
    
    
    //MARK: - Private
    
    private func downloadNext() {
        guard !isCancelled else {
            return
        }
        
        guard !items.isEmpty else {
            saveDownloadedUrls()
            return
        }
        
        currentItem = items.removeFirst()
        
        
        guard let nextItem = currentItem, let urlToFile = nextItem.urlToFile, let name = nextItem.name else {
            downloadNext()
            return
        }
        
        let urlToDownload = urlToFile.isExpired ? urlToFile.byTrimmingQuery : urlToFile
        
        guard let url = urlToDownload else {
            downloadNext()
            return
        }
        
        let parameters = BaseDownloadRequestParametrs(urlToFile: url, fileName: name, contentType: nextItem.fileType)
        task = FileService.shared.executeDownloadRequest(param: parameters) { [weak self] localUrl, _, error in
            defer {
                self?.currentItem = nil
                self?.downloadNext()
            }
            
            guard let self = self else {
                return
            }
            
            guard !self.isCancelled else {
                return
            }
            
            if let error = error {
                self.lastError = error
            }
            
            self.onDownload()
            self.outputURLs.append(localUrl)
        }

    }
    
    private func saveDownloadedUrls() {
        let router = RouterVC()
        let picker = UIDocumentPickerViewController(urls: outputURLs, in: .exportToService)
        picker.delegate = self
        router.presentViewController(controller: picker)
    }
}

extension DocumentDownloadOperation: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        isSaved = true
        semaphore.signal()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        semaphore.signal()
    }
}

extension DocumentDownloadOperation: OperationProgressServiceDelegate {
    func didSend(ratio: Float, bytes: Int, for url: URL) {
        guard isExecuting, let item = currentItem, item.urlToFile?.byTrimmingQuery == url else {
            return
        }

        CardsManager.default.setProgress(ratio: ratio, operationType: .download, object: item)
        //            ItemOperationManager.default.setProgressForDownloadingFile(file: item, progress: ratio)
    }
}
