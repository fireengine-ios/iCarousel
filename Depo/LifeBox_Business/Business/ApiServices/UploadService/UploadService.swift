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
    
    static let shared = UploadService()
    
    static let notificatioUploadServiceDidUpload = "notificatioUploadServiceDidUpload"
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.upload)
    
    private var uploadQueue = OperationQueue()
    private var uploadOperations = SynchronizedArray<UploadOperation>()
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var privateShareAnalytics = PrivateShareAnalytics()
    private lazy var reachabilityService = ReachabilityService.shared
    
    private var allUploadOperationsCount: Int {
        return uploadOperations.filter({ $0.uploadType.isContained(in: [.regular, .sharedArea]) && !$0.isCancelled }).count + finishedUploadOperationsCount
    }
    private var finishedUploadOperationsCount = 0
    
    private var allSharedWithMeUploadOperationsCount: Int {
        return uploadOperations.filter({ $0.uploadType == .sharedWithMe && !$0.isCancelled }).count + finishedSharedWithMeUploadOperationsCount
    }
    private var finishedSharedWithMeUploadOperationsCount = 0
    
    //specific UI counters
    private var currentUploadOperationNumber: Int {
        return finishedUploadOperationsCount + 1
    }
    
    private var currentSharedWithMeUploadOperationNumber: Int {
        return finishedSharedWithMeUploadOperationsCount + 1
    }
    
    private let uploadProgress = UploadProgressManager.shared
    
    
    override init() {
        uploadQueue.maxConcurrentOperationCount = 1
        uploadQueue.qualityOfService = .userInteractive
        
        super.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Deinited UploadService")
    }
    
    
    // MARK: -
    class func convertUploadType(uploadType: UploadType) -> OperationType {
        switch uploadType {
            case .regular, .sharedArea:
                return .upload
            case .sharedWithMe:
                return .sharedWithMeUpload
        }
    }
    
    func uploadFileList(items: [WrapData], uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, isFromCamera: Bool = false, projectId: String? = nil, success: @escaping FileOperationSucces, fail: @escaping FailResponse, returnedUploadOperation: @escaping ([UploadOperation]?) -> Void) {
        
        debugLog("UploadService uploadFileList")
        
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                returnedUploadOperation(nil)
                return
            }
            
            let uploadedTypesToCount = NetmeraService.getItemsTypeToCount(items: items)
            uploadedTypesToCount.forEach {
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Upload(uploadType: uploadType, fileTypes: $0.0))
            }
            
            let filteredItems = self.filter(items: items)
            self.trackAnalyticsFor(items: filteredItems, isFromCamera: isFromCamera)
            
            self.analyticsService.trackDimentionsEveryClickGA(screen: .upload, downloadsMetrics: nil, uploadsMetrics: items.count)
            
            self.uploadFileList(items: filteredItems, uploadType: uploadType, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, projectId: projectId, success: { [weak self] in
                self?.stopTracking()
                self?.clearCounters(uploadType: uploadType)
                self?.hideIfNeededUploadProgress()
                ItemOperationManager.default.finishUploadFiles()
                success()
                
            }, fail: { [weak self] errorResponse in
                self?.stopTracking()
                self?.clearCounters(uploadType: uploadType)
                self?.hideIfNeededUploadProgress()
                
                if errorResponse.isOutOfSpaceError {
                    self?.cancelUploadOperations()
                    ///In order to update the progress bar of the items which are not synchronized
                    filteredItems.forEach { wrapData in
                        ItemOperationManager.default.cancelledUpload(file: wrapData)
                    }
                    //FIXME: Bad practice to call popup from service directly, we have controllers that handle this error
                    DispatchQueue.main.async {
                        self?.showOutOfSpaceAlert()
                    }
                }
                
                fail(errorResponse)
                
            }, returnedOprations: { operations in
                returnedUploadOperation(operations)
            })
        }
    }
    
    private func startSyncTracking() {
        guard uploadOperations.isEmpty else {
            return
        }
        analyticsService.trackEventTimely(eventCategory: .functions, eventActions: .sync, eventLabel: .syncEveryMinute)
    }
    
    private func stopTracking() {
        guard uploadOperations.isEmpty else {
            return
        }
        analyticsService.stopTimelyTracking()
    }
    
    private func hideIfNeededUploadProgress() {
        if uploadOperations.count == 0 {
            uploadProgress.cleanAll()
        }
    }
    
    private func showProgress(type: OperationType, object: WrapData? = nil, newItemsCount: Int = 0, forced: Bool = false) {
        
        let uploaded = finishedUploadOperationsCount + finishedSharedWithMeUploadOperationsCount + 1
        let total = allUploadOperationsCount + allSharedWithMeUploadOperationsCount + newItemsCount
        
        if total >= uploaded {
            uploadProgress.set(uploaded: uploaded, total: total)
        }
    }
    
    private func uploadFileList(items: [WrapData], uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, projectId: String? = nil, success: @escaping FileOperationSucces, fail: @escaping FailResponse, returnedOprations: @escaping ([UploadOperation]?) -> Void) {
        
        // filter all items which md5's are not in the uploadOperations
        let itemsToUpload = items.filter { item -> Bool in
            (self.uploadOperations.first(where: { operation -> Bool in
                return operation.inputItem.md5 == item.md5
            }) == nil)
        }
        
        guard !itemsToUpload.isEmpty, let firstObject = itemsToUpload.first else {
            returnedOprations(nil)
            return
        }
        
        let cardType = UploadService.convertUploadType(uploadType: uploadType)
        showProgress(type: cardType, object: firstObject, newItemsCount: itemsToUpload.count, forced: true)
        
        // change cells into inQueue state
        itemsToUpload.forEach { ItemOperationManager.default.startUploadFile(file: $0) }
        
        self.logSyncSettings(state: "StartUploadFileList")
        
        let operations: [UploadOperation] = itemsToUpload.compactMap {
            let operation = UploadOperation(item: $0, uploadType: uploadType, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, projectId: projectId, handler: { [weak self] finishedOperation, error in
                self?.dispatchQueue.async { [weak self] in
                    guard let `self` = self else {
                        returnedOprations(nil)
                        return
                    }
                    
                    let checkIfFinished = {
                        if self.uploadOperations.filter({ $0.uploadType.isContained(in: [uploadType]) }).isEmpty {
                            
                            if uploadType == .sharedWithMe {
                                self.trackUploadSharedWithMeItems(count: self.finishedSharedWithMeUploadOperationsCount)
                            }
                            
                            success()
                            
                            if uploadType != .sharedWithMe {
                                self.trackUploadItemsFinished(items: itemsToUpload)
                            }
                            
                            ItemOperationManager.default.syncFinished()
                            
                            self.logSyncSettings(state: "FinishedUploadFileList")
                            return
                        }
                    }
                    
                    if let error = error {
                        print("UPLOAD: \(error.description)")
                        if finishedOperation.isCancelled {
                            //operation was cancelled - not an actual error
                            self.showProgress(type: cardType)
                            
                            checkIfFinished()
                        } else {
                            if error.errorCode == 403 {
                                SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.unauthorizedUploadOperation)
                            } else {
                                self.uploadOperations.removeIfExists(finishedOperation)
                                if let fileName = finishedOperation.inputItem.name {
                                    self.logEvent("FinishUpload \(fileName) FAIL: \(error.errorDescription ?? error.description)")
                                }
                                ItemOperationManager.default.failedUploadFile(file: finishedOperation.inputItem, error: error)
                                fail(error)
                            }
                            
                            UploadProgressManager.shared.update(item: finishedOperation.inputItem, status: .failed)
                        }
                        return
                    }
                    
                    if let fileName = finishedOperation.inputItem.name {
                        self.logEvent("FinishUpload \(fileName)")
                    }
                    
                    UploadProgressManager.shared.update(item: finishedOperation.inputItem, status: .completed)
                    
                    self.uploadOperations.removeIfExists(finishedOperation)
                    
                    if uploadType == .sharedWithMe {
                        self.finishedSharedWithMeUploadOperationsCount += 1
                    } else {
                        self.finishedUploadOperationsCount += 1
                    }
                    
                    self.showProgress(type: cardType)
                    
                    if let outputItem = finishedOperation.outputItem {
                        ItemOperationManager.default.finishedUploadFile(file: outputItem)
                        finishedOperation.inputItem.copyFileData(from: outputItem)
                    }
                    
                    checkIfFinished()
                }
            })
            operation.queuePriority = .high
            return operation
        }
        
        uploadOperations.append(operations)
        uploadProgress.append(items: operations.compactMap { $0.inputItem })
        
        uploadQueue.addOperations(operations, waitUntilFinished: false)
        debugLog("UPLOADING upload: \(operations.count) have been added to the upload queue")
        print("UPLOADING upload: \(operations.count) have been added to the upload queue")
        
        let operationsToReturn = uploadOperations.filter({ $0.uploadType.isContained(in: [uploadType]) })
        
        returnedOprations(operationsToReturn)
    }
    
    
    private func trackUploadItemsFinished(items: [WrapData]) {
        var typesUploaded = [FileType]()
        items.forEach {
            if !typesUploaded.contains($0.fileType) {
                typesUploaded.append($0.fileType)
                switch $0.fileType {
                ///In the future there might be doc upload available, but for now its only photos and videos
                case .image:
                    self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .uploadFile, eventLabel: .uploadFile(.photo))
                    self.analyticsService.trackDimentionsEveryClickGA(screen: .photos, downloadsMetrics: nil, uploadsMetrics: items.count, isPaymentMethodNative: nil)
                case .video:
                    self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .uploadFile, eventLabel: .uploadFile(.video))
                    self.analyticsService.trackDimentionsEveryClickGA(screen: .videos, downloadsMetrics: nil, uploadsMetrics: items.count, isPaymentMethodNative: nil)
                default:
                    break
                }
            }
        }
    }
    
    private func trackUploadSharedWithMeItems(count: Int) {
        if count > 0 {
            privateShareAnalytics.sharedWithMeUploadedItems(count: count)
        }
    }
    
    func cancelOperations() {
        uploadOperations.forEach { $0.cancel() }
        uploadOperations.removeAll()
        
        clearUploadCounters()
        clearSharedWithMeUploadCounters()
        
        uploadProgress.cleanAll()
        
        ItemOperationManager.default.syncFinished()
    }
    
    func cancelUploadOperations() {
        var operationsToRemove = uploadOperations.filter({ $0.uploadType.isContained(in: [.regular, .sharedArea]) })
        
        cancelAndRemove(operations: operationsToRemove)
        
        operationsToRemove.removeAll()
    }
    
    func cancelUploadOperations(operations: [UploadOperation]) {
        cancelAndRemove(operations: operations)
    }
    
    func cancelOperation(item: WrapData?) {
        guard let item = item else {
            return
        }
        
        var operationsToRemove = uploadOperations.filter {
            !$0.isCancelled && $0.inputItem == item
        }
        
        cancelAndRemove(operations: operationsToRemove)
        
        print(" removed \(operationsToRemove.count) operations")
        operationsToRemove.removeAll()
    }
    
    private func cancelAndRemove(operations: [UploadOperation]) {
        operations.reversed().forEach { operation in
            uploadOperations.removeIfExists(operation)
        }
        
        operations.reversed().forEach { operation in
            operation.cancel()
        }
    }
    
    private func clearCounters(uploadType: UploadType) {
        switch uploadType {
            case .sharedWithMe:
                clearSharedWithMeUploadCounters()
                
            default:
                clearUploadCounters()
        }
    }
    
    private func clearUploadCounters() {
        finishedUploadOperationsCount = 0
    }
    
    private func clearSharedWithMeUploadCounters() {
        finishedSharedWithMeUploadOperationsCount = 0
    }
    
    func upload(uploadParam: UploadRequestParametrs, success: FileOperationSucces?, fail: FailResponse? ) -> URLSessionTask? {
        debugLog("StartUpload \(uploadParam.fileName)")
        
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
    
    /**
    Check if
    - parameter uploadParam: ResumableUpload.
     If empty == true, just resumable upload status will be checked without any data uploading
     
    - parameter handler: ResumableUploadHandler.
     
    - returns: URLSessionTask
    */
    func resumableUpload(uploadParam: ResumableUpload, handler: @escaping ResumableUploadHandler ) -> URLSessionTask? {
        debugLog("resumableUpload \(uploadParam.fileName)")
        
        let request = executeUploadRequest(param: uploadParam, response: { data, response, error in
            
            let handleError = { (error: Error?) in
                if let error = error {
                    handler(nil, .error(error))
                } else {
                    handler(nil, .string("Error upload"))
                }
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                handleError(error)
                return
            }

            switch httpResponse.statusCode {
            case 200...299:
                handler(.completed, nil)
                
            case 308:
                //should continue
                guard
                    let headerValue = httpResponse.allHeaderFields["Range"] as? String,
                    let upperValueString = headerValue.lastNonEmptyHalf(after: "-"),
                    let upperValue = Int(upperValueString)
                else {
                    handler(nil, nil)
                    return
                }
                
                handler(.uploaded(bytes: upperValue + 1), nil)
                
            case 400:
                if let data = data {
                    let json = JSON(data: data)
                    let errorCode = json["error_code"].stringValue
                    debugLog("resumable_upload: error_code is \(errorCode)")
                    switch errorCode {
                    case "RU_2":
                        /// Provided first-byte-pos is not the continuation of the last-byte-pos of pre-uploaded part!
                        handler(.discontinuityError, nil)
                        
                    case "RU_1":
                        /// Invalid upload request! Initial upload must start from the beginning
                        handler(.invalidUploadRequest, nil)
                        
                    default:
                        //RU_9, RU_10 - also possible but undocumented
                        handleError(error)
                    }
                } else {
                    handleError(error)
                }
                
            case 404:
                // can't find prevous upload
                handler(.didntStart, nil)
                
            default:
                handleError(error)
            }
        })
        
        return request
    }
    
    func isInQueue(item uuid: String) -> Bool {
        return uploadOperations.first(where: {
            $0.inputItem.uuid == uuid && !($0.isCancelled || $0.isFinished)
        }) != nil
    }
}


extension UploadService {
    fileprivate func showOutOfSpaceAlert() {
        RouterVC().showFullQuotaPopUp()
    }
    
    fileprivate func filter(items: [WrapData]) -> [WrapData] {
        guard !items.isEmpty else {
            return []
        }
        
        var result = items.filter { $0.fileSize < NumericConstants.fourGigabytes }
        guard !result.isEmpty else {
            UIApplication.showErrorAlert(message: TextConstants.syncFourGbVideo)
            return []
        }
        
        let freeDiskSpaceInBytes = Device.getFreeDiskSpaceInBytes()
        result = result.filter { $0.fileSize < freeDiskSpaceInBytes }
        guard !result.isEmpty else {
            UIApplication.showErrorAlert(message: TextConstants.syncNotEnoughMemory)
            return []
        }
        
        return result
    }
}

extension UploadService {
    
    fileprivate func trackAnalyticsFor(items: [WrapData], isFromCamera: Bool) {
        startSyncTracking()
        
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
            if ApplicationStateHelper.shared.isBackground {
                debugLog("Upload Service Background sync \(message)")
            } else {
                debugLog("Upload Service \(message)")
            }
        }
    }
    
    fileprivate func logSyncSettings(state: String) {
        var logString = "DEVICE NETWORK: \(reachabilityService.status)"
        logString += " --> \(state)"
        debugLog(logString)
    }
}


private extension String {
    func lastNonEmptyHalf(after separator: Character) -> String? {
        guard
            let substring = self.split(separator: separator, maxSplits: 2, omittingEmptySubsequences: true).last
        else {
            return nil
        }
        
        return String(substring)
    }
}
