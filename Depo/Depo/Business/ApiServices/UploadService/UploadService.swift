//
//  UploadService.swift
//  Depo
//
//  Created by Alexander Gurin on 1/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON

final class UploadService: BaseRequestService {
    
    static let `default` = UploadService()
    
    static let notificatioUploadServiceDidUpload = "notificatioUploadServiceDidUpload"
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.upload)
    
    private var uploadQueue = OperationQueue()
    private var uploadOperations = SynchronizedArray<UploadOperations>()
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var autoSyncStorage = AutoSyncDataStorage()
    private lazy var reachabilityService = ReachabilityService()
    
    private var allSyncOperationsCount: Int {
        return uploadOperations.filter({ $0.uploadType == .autoSync && !$0.isCancelled }).count + finishedSyncOperationsCount
    }
    private var finishedSyncOperationsCount: Int {
        return finishedPhotoSyncOperationsCount + finishedVideoSyncOperationsCount
    }
    private var finishedPhotoSyncOperationsCount = 0
    private var finishedVideoSyncOperationsCount = 0
    
    
    private var allUploadOperationsCount: Int {
        return uploadOperations.filter({ $0.uploadType == .fromHomePage && !$0.isCancelled }).count + finishedUploadOperationsCount
    }
    private var finishedUploadOperationsCount = 0
    
    
    private var allSyncToUseOperationsCount: Int {
        return uploadOperations.filter({ $0.uploadType == .syncToUse && !$0.isCancelled }).count + finishedSyncToUseOperationsCount
    }
    private var finishedSyncToUseOperationsCount = 0
    
    //specific UI counters
    
    private var currentSyncOperationNumber: Int {
        return finishedSyncOperationsCount + 1
    }
    
    private var currentUploadOperationNumber: Int {
        return finishedUploadOperationsCount + finishedSyncToUseOperationsCount + 1
    }
    
    
    override init() {
        uploadQueue.maxConcurrentOperationCount = 1
        uploadQueue.qualityOfService = .userInteractive
        uploadQueue.underlyingQueue = dispatchQueue
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSyncSettings), name: autoSyncStatusDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: -
    class func convertUploadType(uploadType: UploadType) -> OperationType {
        switch uploadType {
        case .autoSync:
            return .sync
        case .syncToUse, .fromHomePage:
            return .upload
        case .other:
            return .upload
        }
    }
    
    func uploadFileList(items: [WrapData], uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, isFromCamera: Bool = false, success: @escaping FileOperationSucces, fail: @escaping FailResponse, returnedUploadOperation: @escaping ([UploadOperations]?) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                returnedUploadOperation(nil)
                return
            }
            self.trackAnalyticsFor(items: items, isFromCamera: isFromCamera)
            
            guard let filteredItems = self.filter(items: items) else {
                success()
                return
            }
            
            switch uploadType {
            case .autoSync:
                self.syncFileList(items: filteredItems, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, success: success, fail: fail, syncOperationsListCallBack: { syncOperations in
                    returnedUploadOperation(syncOperations)
                })
            case .syncToUse:
                
                self.syncToUseFileList(items: filteredItems, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, success: { [weak self] in
                    self?.clearSyncToUseCounters()
                    self?.hideUploadCardIfNeeded()
                    success()
                    }, fail: { [weak self] errorResponse in
                        self?.clearSyncToUseCounters()
                        self?.hideUploadCardIfNeeded()
                        
                        if errorResponse.isOutOfSpaceError {
                            self?.cancelSyncToUseOperations()
                            self?.showOutOfSpaceAlert()
                        }
                        
                        fail(errorResponse)
                    }, syncToUseFileListOperationsCallBack: { seyncOperations in
                        returnedUploadOperation(seyncOperations)
                })
            default:
                self.uploadFileList(items: filteredItems, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, success: { [weak self] in
                    self?.clearUploadCounters()
                    self?.hideUploadCardIfNeeded()
                    success()
                    }, fail: { [weak self] errorResponse in
                        self?.clearUploadCounters()
                        self?.hideUploadCardIfNeeded()
                        
                        if errorResponse.isOutOfSpaceError {
                            self?.cancelUploadOperations()
                            self?.showOutOfSpaceAlert()
                        }
                        
                        fail(errorResponse)
                    }, returnedOprations: { roperations in
                        returnedUploadOperation(roperations)
                })
            }
        }
        
    }
    
    private func hideUploadCardIfNeeded() {
        if uploadOperations.filter({ $0.uploadType?.isContained(in: [.fromHomePage, .syncToUse]) ?? false }).count == 0 {
            CardsManager.default.stopOperationWithType(type: .upload)
        }
    }
    
    private func showSyncCardProgress() {
        WidgetService.shared.notifyWidgetAbout(currentSyncOperationNumber, of: allSyncOperationsCount)
        
        guard allSyncOperationsCount != 0, allSyncOperationsCount != finishedSyncOperationsCount else {
            clearSyncCounters()
            return
        }
        
        CardsManager.default.setProgressForOperationWith(type: .sync,
                                                         object: nil,
                                                         allOperations: allSyncOperationsCount,
                                                         completedOperations: currentSyncOperationNumber)
    }
    
    private func showUploadCardProgress() {
        let allOperations = allSyncToUseOperationsCount + allUploadOperationsCount
        guard allOperations != 0, currentUploadOperationNumber <= allOperations else {
            return
        }
        
        CardsManager.default.setProgressForOperationWith(type: .upload,
                                                         object: nil,
                                                         allOperations: allOperations,
                                                         completedOperations: currentUploadOperationNumber)
    }
    
    private func syncToUseFileList(items: [WrapData], uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, success: @escaping FileOperationSucces, fail: @escaping FailResponse, syncToUseFileListOperationsCallBack:
        @escaping ([UploadOperations]?)-> Void ) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                syncToUseFileListOperationsCallBack(nil)
                return
            }
            
            // filter all items which md5's are not in the uploadOperations
            let itemsToUpload = items.filter { item -> Bool in
                (self.uploadOperations.first(where: { operation -> Bool in
                    if operation.item.md5 == item.md5 && operation.uploadType?.isContained(in: [.autoSync, .fromHomePage]) ?? false {
                        operation.cancel()
                        self.uploadOperations.removeIfExists(operation)
                        return false
                    }
                    return operation.item.md5 == item.md5
                }) == nil)
            }
            
            guard !itemsToUpload.isEmpty, let firstObject = itemsToUpload.first else {
                syncToUseFileListOperationsCallBack(nil)
                return
            }
            
            CardsManager.default.setProgressForOperationWith(type: .upload,
                                                             object: firstObject,
                                                             allOperations: self.allSyncToUseOperationsCount + self.allUploadOperationsCount + itemsToUpload.count,
                                                             completedOperations: self.currentUploadOperationNumber)
            
            ItemOperationManager.default.startUploadFile(file: firstObject)
            
            self.logSyncSettings(state: "StartSyncToUseFileList")
            
            let operations: [UploadOperations] = itemsToUpload.flatMap {
                
                let operation = UploadOperations(item: $0, uploadType: .syncToUse, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, handler: { [weak self] finishedOperation, error in
                    self?.dispatchQueue.async { [weak self] in
                        guard let `self` = self else {
                            syncToUseFileListOperationsCallBack(nil)
                            return
                        }
                        
                        let checkIfFinished = {
                            if self.uploadOperations.filter({ $0.uploadType == .syncToUse }).isEmpty {
                                success()
                                self.logSyncSettings(state: "FinishedSyncToUseFileList")
                                return
                            }
                        }
                        
                        if let error = error {
                            print("AUTOSYNC: \(error.description)")
                            if !finishedOperation.isCancelled {
                                self.uploadOperations.removeIfExists(finishedOperation)
                            }
                            //                        //operation was cancelled - not an actual error
                            //                        self.showUploadCardProgress()
                            //                        checkIfFinished()
                            //                    } else {
                            //sync failed
                            fail(.error(error))
                            //                    }
                            return
                        }
                        
                        if let fileName = finishedOperation.item.name {
                            self.logEvent("FinishUpload \(fileName)")
                        }
                        
                        self.uploadOperations.removeIfExists(finishedOperation)
                        
                        self.finishedSyncToUseOperationsCount += 1
                        
                        self.showUploadCardProgress()
                        
                        finishedOperation.item.syncStatus = .synced
                        finishedOperation.item.setSyncStatusesAsSyncedForCurrentUser()
                        
                        CoreDataStack.default.updateLocalItemSyncStatus(item: finishedOperation.item)
                        
                        ItemOperationManager.default.finishedUploadFile(file: finishedOperation.item)
                        
                        checkIfFinished()
                    }
                })
                operation.queuePriority = .veryHigh
                return operation
            }
            self.uploadOperations.append(operations)
            
            self.uploadQueue.addOperations(operations, waitUntilFinished: false)
            log.debug("UPLOADING upload: \(operations.count) have been added to the upload queue")
            print("UPLOADING upload: \(operations.count) have been added to the upload queue")
            
            syncToUseFileListOperationsCallBack(self.uploadOperations.filter({ $0.uploadType == .syncToUse }))
        }
    }
    
    private func uploadFileList(items: [WrapData], uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, success: @escaping FileOperationSucces, fail: @escaping FailResponse, returnedOprations: @escaping ([UploadOperations]?) -> Void) {
        
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                returnedOprations(nil)
                return
            }
            // filter all items which md5's are not in the uploadOperations
            let itemsToUpload = items.filter { item -> Bool in
                (self.uploadOperations.first(where: { operation -> Bool in
                    if operation.item.md5 == item.md5 && operation.uploadType == .autoSync && !operation.isExecuting {
                        operation.cancel()
                        self.uploadOperations.removeIfExists(operation)
                        return false
                    }
                    return operation.item.md5 == item.md5
                }) == nil)
            }
            
            guard !itemsToUpload.isEmpty, let firstObject = itemsToUpload.first else {
                returnedOprations(nil)
                return
            }
            
            
            CardsManager.default.setProgressForOperationWith(type: .upload,
                                                             object: firstObject,
                                                             allOperations: self.allSyncToUseOperationsCount + self.allUploadOperationsCount + itemsToUpload.count,
                                                             completedOperations: self.currentUploadOperationNumber)
            
            ItemOperationManager.default.startUploadFile(file: firstObject)
            
            self.logSyncSettings(state: "StartUploadFileList")
            
            let operations: [UploadOperations] = itemsToUpload.flatMap {
                let operation = UploadOperations(item: $0, uploadType: .fromHomePage, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, handler: { [weak self] finishedOperation, error in
                    self?.dispatchQueue.async { [weak self] in
                        guard let `self` = self else {
                            returnedOprations(nil)
                            return
                        }
                        
                        let checkIfFinished = {
                            if self.uploadOperations.filter({ $0.uploadType == .fromHomePage }).isEmpty {
                                success()
                                ItemOperationManager.default.syncFinished()
                                self.logSyncSettings(state: "FinishedUploadFileList")
                                return
                            }
                        }
                        
                        if let error = error {
                            print("AUTOSYNC: \(error.description)")
                            if finishedOperation.isCancelled {
                                //operation was cancelled - not an actual error
                                self.showUploadCardProgress()
                                checkIfFinished()
                            } else {
                                self.uploadOperations.removeIfExists(finishedOperation)
                                if let fileName = finishedOperation.item.name {
                                    self.logEvent("FinishUpload \(fileName) FAIL: \(error.errorDescription ?? error.description)")
                                }
                                fail(error)
                            }
                            return
                        }
                        
                        if let fileName = finishedOperation.item.name {
                            self.logEvent("FinishUpload \(fileName)")
                        }
                        
                        self.uploadOperations.removeIfExists(finishedOperation)
                        
                        self.finishedUploadOperationsCount += 1
                        
                        self.showUploadCardProgress()
                        
                        finishedOperation.item.syncStatus = .synced
                        finishedOperation.item.setSyncStatusesAsSyncedForCurrentUser()
                        
                        CoreDataStack.default.updateLocalItemSyncStatus(item: finishedOperation.item)
                        
                        ItemOperationManager.default.finishedUploadFile(file: finishedOperation.item)
                        
                        checkIfFinished()
                    }
                })
                operation.queuePriority = .high
                return operation
            }
            self.uploadOperations.append(operations)
            
            self.uploadQueue.addOperations(operations, waitUntilFinished: false)
            log.debug("UPLOADING upload: \(operations.count) have been added to the upload queue")
            print("UPLOADING upload: \(operations.count) have been added to the upload queue")
            let oretiontoReturn = self.uploadOperations.filter({ $0.uploadType == .fromHomePage })
            returnedOprations(oretiontoReturn)
        }
    }
    
    private func syncFileList(items: [WrapData], uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, success: @escaping FileOperationSucces, fail: @escaping FailResponse, syncOperationsListCallBack: @escaping ([UploadOperations]?) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                syncOperationsListCallBack(nil)
                return
            }
            // filter all items which md5's are not in the uploadOperations
            let itemsToSync = items.filter { item -> Bool in
                (self.uploadOperations.first(where: { operation -> Bool in
                    return operation.item.md5 == item.md5
                }) == nil)
            }
            
            guard !itemsToSync.isEmpty, let firstObject = itemsToSync.first else {
                syncOperationsListCallBack(nil)
                return
            }
            
            print("AUTOSYNC: trying to add \(itemsToSync.count) item(s) of \(firstObject.fileType) type")
            CardsManager.default.setProgressForOperationWith(type: .sync,
                                                             object: firstObject,
                                                             allOperations: self.allSyncOperationsCount + itemsToSync.count,
                                                             completedOperations: self.currentSyncOperationNumber)
            WidgetService.shared.notifyWidgetAbout(self.currentSyncOperationNumber, of: self.allSyncOperationsCount + itemsToSync.count)
            
            ItemOperationManager.default.startUploadFile(file: firstObject)
            
            self.logSyncSettings(state: "StartSyncFileList")
            
            var successHandled = false
            
            let operations: [UploadOperations] = itemsToSync.flatMap {
                
                let operation = UploadOperations(item: $0, uploadType: .autoSync, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, handler: { [weak self] finishedOperation, error in
                    self?.dispatchQueue.async { [weak self] in
                        guard let `self` = self else {
                            syncOperationsListCallBack(nil)
                            return
                        }
                        
                        let checkIfFinished = {
                            if !successHandled, self.uploadOperations.filter({ $0.uploadType == .autoSync && $0.item.fileType == finishedOperation.item.fileType }).isEmpty {
                                successHandled = true
                                success()
                                self.logSyncSettings(state: "FinishedSyncFileList")
                                return
                            }
                        }
                        
                        if let error = error {
                            if finishedOperation.isCancelled {
                                if let fileName = finishedOperation.item.name {
                                    self.logEvent("FinishUpload \(fileName) Cancelled")
                                }
                                
                                checkIfFinished()
                            } else {
                                if let fileName = finishedOperation.item.name {
                                    self.logEvent("FinishUpload \(fileName) FAIL: \(error.errorDescription ?? "")")
                                }
                                self.uploadOperations.removeIfExists(finishedOperation)
                                fail(error)
                            }
                            return
                        }
                        
                        if let fileName = finishedOperation.item.name {
                            self.logEvent("FinishUpload \(fileName)")
                        }
                        self.uploadOperations.removeIfExists(finishedOperation)
                        
                        if finishedOperation.item.fileType == .image { self.finishedPhotoSyncOperationsCount += 1 } else if finishedOperation.item.fileType == .video { self.finishedVideoSyncOperationsCount += 1 }
                        
                        self.showSyncCardProgress()
                        
                        finishedOperation.item.syncStatus = .synced
                        finishedOperation.item.setSyncStatusesAsSyncedForCurrentUser()
                        
                        CoreDataStack.default.updateLocalItemSyncStatus(item: finishedOperation.item)
                        
                        ItemOperationManager.default.finishedUploadFile(file: finishedOperation.item)
                        
                        checkIfFinished()
                    }
                })
                
                operation.queuePriority = firstObject.fileType == .image ? .normal : .low // start images sync first
                return operation
            }
            self.uploadOperations.append(operations)
            
            self.uploadQueue.addOperations(operations, waitUntilFinished: false)
            log.debug("AUTOSYNC: \(operations.count) \(firstObject.fileType)(s) have been added to the sync queue")
            print("AUTOSYNC: \(operations.count) \(firstObject.fileType)(s) have been added to the sync queue")
            
            syncOperationsListCallBack(self.uploadOperations.filter({ $0.uploadType == .autoSync }))
        }
    }
    
    func cancelOperations() {
        uploadOperations.forEach { $0.cancel() }
        uploadOperations.removeAll()
        
        clearUploadCounters()
        clearSyncCounters()
        
        CardsManager.default.stopOperationWithType(type: .upload)
        CardsManager.default.stopOperationWithType(type: .sync)
        ItemOperationManager.default.syncFinished()
    }
    
    func cancelSyncToUseOperations() {
        var operationsToRemove = uploadOperations.filter({ $0.uploadType == .syncToUse })
        
        cancelAndRemove(operations: operationsToRemove)
        
        print("AUTOSYNC: removed \(operationsToRemove.count) operations")
        operationsToRemove.removeAll()
    }
    
    func cancelUploadOperations() {
        var operationsToRemove = uploadOperations.filter({ $0.uploadType == .fromHomePage })
        
        cancelAndRemove(operations: operationsToRemove)
        
        operationsToRemove.removeAll()
    }
    
    func cancelSyncOperations(photo: Bool, video: Bool) {
        print("AUTOSYNC: cancelling sync operations for \(photo ? "photo" : "video")")
        let time = Date()
        var operationsToRemove = uploadOperations.filter({ $0.uploadType == .autoSync &&
            ((video && $0.item.fileType == .video) || (photo && $0.item.fileType == .image)) })
        
        print("AUTOSYNC: found \(operationsToRemove.count) operations to remove in \(Date().timeIntervalSince(time)) secs")
        
        cancelAndRemove(operations: operationsToRemove)
        
        print("AUTOSYNC: removed \(operationsToRemove.count) operations in \(Date().timeIntervalSince(time)) secs")
        operationsToRemove.removeAll()
        
        if photo {
            finishedPhotoSyncOperationsCount = 0
        }
        if video {
            finishedVideoSyncOperationsCount = 0
        }
        
        showSyncCardProgress()
    }
    
    func cancelOperations(with assets: [PHAsset]?) {
        guard let assets = assets else {
            return
        }
        
        var operationsToRemove = uploadOperations.filter { operation -> Bool in
            if let asset = operation.item.asset {
                return !operation.isCancelled && assets.contains(asset)
            }
            return false
        }
        
        cancelAndRemove(operations: operationsToRemove)
        
        print("AUTOSYNC: removed \(operationsToRemove.count) operations")
        operationsToRemove.removeAll()
    }
    
    private func cancelAndRemove(operations: [UploadOperations]) {
        operations.forEach { operation in
            uploadOperations.removeIfExists(operation)
        }
        
        operations.forEach { operation in
            operation.cancel()
        }
    }
    
    private func clearUploadCounters() {
        finishedUploadOperationsCount = 0
    }
    
    private func clearSyncToUseCounters() {
        print("UPLOAD: clearing sync to use counters")
        finishedSyncToUseOperationsCount = 0
    }
    
    private func clearSyncCounters() {
        print("AUTOSYNC: clearing sync counters")
        finishedPhotoSyncOperationsCount = 0
        finishedVideoSyncOperationsCount = 0
    }
    
    func upload(uploadParam: Upload, success: FileOperationSucces?, fail: FailResponse? ) -> URLSessionTask? {
        logEvent("StartUpload \(uploadParam.fileName)")
        
        let request = executeUploadRequest(param: uploadParam, response: { data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                if 200...299 ~= httpResponse.statusCode {
                    success?()
                    return
                } else {
                    fail?(.httpCode(httpResponse.statusCode))
                    return
                }
            } else if let error = error {
                fail?(.error(error))
                return
            }
            
            fail?(.string("Error upload"))
        })
        
        return request
    }
    
    func baseUrl(success: @escaping UploadServiceBaseUrlResponse, fail: FailResponse?) -> URLSessionTask {
        let param = UploadBaseURL()
        let handler = BaseResponseHandler<UploadBaseURLResponse, ObjectRequestResponse>(success: { result in
            success(result as? UploadBaseURLResponse)
        }, fail: fail)
        
        return executeGetRequest(param: param, handler: handler)
    }
    
    func uploadNotify(param: UploadNotify, success: @escaping SuccessResponse, fail: FailResponse?) {
        let handler = BaseResponseHandler<SearchItemResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
}


extension UploadService {
    fileprivate func showOutOfSpaceAlert() {
        let controller = PopUpController.with(title: TextConstants.syncOutOfSpaceAlertTitle,
                                              message: TextConstants.syncOutOfSpaceAlertText,
                                              image: .none,
                                              firstButtonTitle: TextConstants.syncOutOfSpaceAlertCancel,
                                              secondButtonTitle: TextConstants.upgrade,
                                              firstAction: nil,
                                              secondAction: { vc in
                                                vc.close(completion: {
                                                    let router = RouterVC()
                                                    if router.navigationController?.presentedViewController != nil {
                                                        router.pushOnPresentedView(viewController: router.packages)
                                                    } else {
                                                        router.pushViewController(viewController: router.packages)
                                                    }
                                                })
        })
        
        DispatchQueue.main.async {
            RouterVC().tabBarVC?.present(controller, animated: false, completion: nil)
        }
    }
    
    fileprivate func filter(items: [WrapData]) -> [WrapData]? {
        guard !items.isEmpty else {
            return nil
        }
        
        var result = items.filter { $0.fileSize < NumericConstants.fourGigabytes }
        guard !result.isEmpty else {
            UIApplication.showErrorAlert(message: TextConstants.syncFourGbVideo)
            return nil
        }
        
        let freeDiskSpaceInBytes = Device.getFreeDiskSpaceInBytes() ?? 0
        result = result.filter { $0.fileSize < freeDiskSpaceInBytes }
        guard !result.isEmpty else {
            UIApplication.showErrorAlert(message: TextConstants.syncNotEnoughMemory)
            return nil
        }
        
        return result
    }
}

extension UploadService {
    
    fileprivate func trackAnalyticsFor(items: [WrapData], isFromCamera: Bool) {
        
        guard !isFromCamera else {
            analyticsService.track(event: .uploadFromCamera)
            return
        }
        
        if items.first(where: { $0.fileType == .video }) != nil {
            analyticsService.track(event: .uploadVideo)
        }
        
        if items.first(where: { $0.fileType == .image }) != nil {
            analyticsService.track(event: .uploadPhoto)
        }
        
        if items.first(where: { $0.fileType == .audio }) != nil {
            analyticsService.track(event: .uploadMusic)
        }
        
        if items.first(where: { $0.fileType.isDocument }) != nil {
            analyticsService.track(event: .uploadDocument)
        }
    }
}

extension UploadService {
    
    fileprivate func logEvent(_ message: String) {
        DispatchQueue.main.async {
            if UIApplication.shared.applicationState == .background {
                log.debug("Upload Service Background sync \(message)")
            } else {
                log.debug("Upload Service \(message)")
            }
        }
    }
    
    fileprivate func logSyncSettings(state: String) {
        let settings = autoSyncStorage.settings
        var logString = "Auto Sync Settings: PHOTOS: \(settings.photoSetting.option.localizedText) + VIDEOS: \(settings.videoSetting.option.localizedText)"
        logString += "; DEVICE NETWORK: \(reachabilityService.status)"
        logString += " --> \(state)"
        log.debug(logString)
    }
    
    @objc fileprivate func updateSyncSettings() {
        logSyncSettings(state: "Auto Sync setting changed")
    }
}
