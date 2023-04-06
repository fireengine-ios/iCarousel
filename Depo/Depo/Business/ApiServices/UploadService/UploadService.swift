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
    private var uploadOperations = SynchronizedArray<UploadOperation>()
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var privateShareAnalytics = PrivateShareAnalytics()
    private lazy var autoSyncStorage = AutoSyncDataStorage()
    private lazy var reachabilityService = ReachabilityService.shared
    
    private var allSyncOperationsCount: Int {
        return uploadOperations.filter({ $0.uploadType == .autoSync && !$0.isCancelled }).count + finishedSyncOperationsCount
    }
    private var finishedSyncOperationsCount: Int {
        return finishedPhotoSyncOperationsCount + finishedVideoSyncOperationsCount
    }
    private var finishedPhotoSyncOperationsCount = 0
    private var finishedVideoSyncOperationsCount = 0
    
    
    private var allUploadOperationsCount: Int {
        return uploadOperations.filter({ $0.uploadType.isContained(in: [.upload]) && !$0.isCancelled }).count + finishedUploadOperationsCount
    }
    private var finishedUploadOperationsCount = 0
    
    
    private var allSyncToUseOperationsCount: Int {
        return uploadOperations.filter({ $0.uploadType == .syncToUse && !$0.isCancelled }).count + finishedSyncToUseOperationsCount
    }
    private var finishedSyncToUseOperationsCount = 0
    
    private var allSharedWithMeUploadOperationsCount: Int {
        return uploadOperations.filter({ $0.uploadType == .sharedWithMe && !$0.isCancelled }).count + finishedSharedWithMeUploadOperationsCount
    }
    private var finishedSharedWithMeUploadOperationsCount = 0
    
    //specific UI counters
    
    private var currentSyncOperationNumber: Int {
        return finishedSyncOperationsCount + 1
    }
    
    private var currentUploadOperationNumber: Int {
        return finishedUploadOperationsCount + finishedSyncToUseOperationsCount + 1
    }
    
    private var currentSharedWithMeUploadOperationNumber: Int {
        return finishedSharedWithMeUploadOperationsCount + 1
    }
    
    override init() {
        uploadQueue.maxConcurrentOperationCount = 1
        uploadQueue.qualityOfService = .userInteractive
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSyncSettings), name: .autoSyncStatusDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Deinited UploadService")
    }
    
    
    // MARK: -
    class func convertUploadType(uploadType: UploadType) -> OperationType {
        switch uploadType {
        case .autoSync:
            return .sync
        case .syncToUse, .upload, .save, .saveAs:
            return .upload
        case .sharedWithMe:
            return .sharedWithMeUpload
        }
    }
    
    func uploadFileList(items: [WrapData], uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, isFromCamera: Bool = false, projectId: String? = nil, isCollage: Bool = false, success: @escaping FileOperationSucces, fail: @escaping FailResponse, returnedUploadOperation: @escaping ([UploadOperation]?) -> Void) {
        debugLog("UploadService uploadFileList")
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                returnedUploadOperation(nil)
                return
            }
            
            PremiumService.shared.showPopupForNewUserIfNeeded()
            
            let uploadedTypesToCount = NetmeraService.getItemsTypeToCount(items: items)
            uploadedTypesToCount.forEach {
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Upload(uploadType: uploadType, fileTypes: $0.0))
            }
            
            
            let filteredItems = self.filter(items: items)
            self.trackAnalyticsFor(items: filteredItems, isFromCamera: isFromCamera)
            
            switch uploadType {
            case .autoSync:
                self.syncFileList(items: filteredItems,
                                  uploadStategy: uploadStategy,
                                  uploadTo: uploadTo,
                                  folder: folder,
                                  isFavorites: isFavorites,
                                  isFromAlbum: isFromAlbum,
                                  success: success,
                                  fail: fail,
                                  syncOperationsListCallBack: { syncOperations in
                    returnedUploadOperation(syncOperations)
                })
            case .syncToUse:
                self.syncToUseFileList(items: filteredItems,
                                       uploadStategy: uploadStategy,
                                       uploadTo: uploadTo,
                                       folder: folder,
                                       isFavorites: isFavorites,
                                       isFromAlbum: isFromAlbum,
                                       success: { [weak self] in
                    self?.stopTracking()
                    self?.clearCounters(uploadType: .syncToUse)
                    self?.hideIfNeededCard(for: .syncToUse)
                    success()
                    }, fail: { [weak self] errorResponse in
                        self?.stopTracking()
                        self?.clearCounters(uploadType: .syncToUse)
                        self?.hideIfNeededCard(for: .syncToUse)
                        
                        if errorResponse.isOutOfSpaceError {
                            self?.cancelSyncToUseOperations()
                            ///In order to update the progress bar of the items which are not synchronized
                            filteredItems.forEach { wrapData in
                                ItemOperationManager.default.cancelledUpload(file: wrapData)
                            }
                            
                            DispatchQueue.main.async {
                                self?.showOutOfSpaceAlert()
                            }
                        }
                        
                        fail(errorResponse)
                    }, syncToUseFileListOperationsCallBack: { seyncOperations in
                        returnedUploadOperation(seyncOperations)
                })
            default:
                 self.analyticsService.trackDimentionsEveryClickGA(screen: .upload, downloadsMetrics: nil, uploadsMetrics: items.count)
                 
                self.uploadFileList(items: filteredItems, uploadType: uploadType, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, projectId: projectId, isCollage: isCollage, success: { [weak self] in
                    self?.stopTracking()
                    self?.clearCounters(uploadType: uploadType)
                    self?.hideIfNeededCard(for: uploadType)
                    ItemOperationManager.default.finishUploadFiles()
                    success()
                    }, fail: { [weak self] errorResponse in
                        self?.stopTracking()
                        self?.clearCounters(uploadType: uploadType)
                        self?.hideIfNeededCard(for: uploadType)
                        
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
                    }, returnedOprations: { roperations in
                        returnedUploadOperation(roperations)
                })
            }
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
    
    private func hideIfNeededCard(for uploadType: UploadType) {
        switch uploadType {
            case .upload, .syncToUse, .save, .saveAs:
                hideUploadCardIfNeeded()
                
            case .autoSync:
                hideSyncCardIfNeeded()
                
            case .sharedWithMe:
                hideSharedWithMeUploadCardIfNeeded()
                
            default:
                assertionFailure()
                hideUploadCardIfNeeded()
        }
    }
    
    private func hideUploadCardIfNeeded() {
        if uploadOperations.filter({ $0.uploadType?.isContained(in: [.upload, .syncToUse]) ?? false }).count == 0 {
            CardsManager.default.stopOperationWith(type: .upload)
        }
    }
    
    private func hideSyncCardIfNeeded() {
        if uploadOperations.filter({ $0.uploadType?.isContained(in: [.autoSync]) ?? false }).count == 0 {
            CardsManager.default.stopOperationWith(type: .sync)
        }
    }
    
    private func hideSharedWithMeUploadCardIfNeeded() {
        if uploadOperations.filter({ $0.uploadType?.isContained(in: [.sharedWithMe]) ?? false }).count == 0 {
            CardsManager.default.stopOperationWith(type: .sharedWithMeUpload)
        }
    }
    
    private func showCardProgress(type: OperationType, object: WrapData? = nil, newItemsCount: Int = 0, forced: Bool = false) {
        switch type {
            case .upload:
                showUploadCardProgress(object: object, newItemsCount: newItemsCount, forced: forced)
                
            case .sync:
                showSyncCardProgress(object: object, newItemsCount: newItemsCount, forced: forced)
                
            case .sharedWithMeUpload:
                showSharedWithMeUploadCardProgress(object: object, newItemsCount: newItemsCount, forced: forced)
                
            default:
                assertionFailure()
                showUploadCardProgress(object: object, newItemsCount: newItemsCount, forced: forced)
        }
    }
    
    private func showUploadCardProgress(object: WrapData? = nil, newItemsCount: Int = 0, forced: Bool = false) {
        let allOperations = allSyncToUseOperationsCount + allUploadOperationsCount + newItemsCount
        guard
            forced ||
            (allOperations != 0 &&
            currentUploadOperationNumber <= allOperations)
        else {
            return
        }
        
        widgetNotifySyncProgress(finishedCount: currentUploadOperationNumber, totalCount: allOperations)
        CardsManager.default.setProgressForOperationWith(type: .upload,
                                                         object: object,
                                                         allOperations: allOperations,
                                                         completedOperations: currentUploadOperationNumber)
    }
    
    private func showSharedWithMeUploadCardProgress(object: WrapData? = nil, newItemsCount: Int = 0, forced: Bool = false) {
        let allOperations = allSharedWithMeUploadOperationsCount + newItemsCount
        guard
            forced ||
            (allOperations != 0 &&
            currentSharedWithMeUploadOperationNumber <= allOperations)
        else {
            return
        }
        
        widgetNotifySyncProgress(finishedCount: currentSharedWithMeUploadOperationNumber, totalCount: allOperations)
        CardsManager.default.setProgressForOperationWith(type: .sharedWithMeUpload,
                                                         object: object,
                                                         allOperations: allOperations,
                                                         completedOperations: currentSharedWithMeUploadOperationNumber)
    }
    
    private func showSyncCardProgress(object: WrapData? = nil, newItemsCount: Int = 0, forced: Bool = false) {
        let allOperations = allSyncOperationsCount + newItemsCount
        widgetNotifySyncProgress(finishedCount: currentSyncOperationNumber, totalCount: allOperations)
        
        guard
            forced ||
            (allOperations != 0 &&
            allOperations != finishedSyncOperationsCount &&
            autoSyncStorage.settings.isAutoSyncEnabled &&
            SyncServiceManager.shared.hasExecutingSync)
        else {
            clearSyncCounters()
            return
        }
        
        CardsManager.default.setProgressForOperationWith(type: .sync,
                                                         object: object,
                                                         allOperations: allOperations,
                                                         completedOperations: currentSyncOperationNumber)
    }
    
    private func syncToUseFileList(items: [WrapData], uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, success: @escaping FileOperationSucces, fail: @escaping FailResponse, syncToUseFileListOperationsCallBack: @escaping ([UploadOperation]?)-> Void ) {
//        dispatchQueue.async { [weak self] in
//            guard let `self` = self else {
//                syncToUseFileListOperationsCallBack(nil)
//                return
//            }
        
            // filter all items which md5's are not in the uploadOperations
            let itemsToUpload = items.filter { item -> Bool in
                (self.uploadOperations.first(where: { operation -> Bool in
                    if operation.inputItem.md5 == item.md5 && operation.uploadType?.isContained(in: [.autoSync, .upload]) ?? false {
                        operation.cancel()
                        self.uploadOperations.removeIfExists(operation)
                        return false
                    }
                    return operation.inputItem.md5 == item.md5
                }) == nil)
            }
            
            guard !itemsToUpload.isEmpty, let firstObject = itemsToUpload.first else {
                syncToUseFileListOperationsCallBack(nil)
                return
            }
            
            self.showCardProgress(type: .upload, object: firstObject, newItemsCount: itemsToUpload.count, forced: true)
        
            self.widgetNotifySyncExecute(finishedCount: self.currentUploadOperationNumber,
                                         totalCount: self.allSyncToUseOperationsCount + self.allUploadOperationsCount + itemsToUpload.count,
                                         firstFileName: firstObject.name ?? "")

            // change cells into inQueue state
            itemsToUpload.forEach { ItemOperationManager.default.startUploadFile(file: $0) }
            
            self.logSyncSettings(state: "StartSyncToUseFileList")
            
            let operations: [UploadOperation] = itemsToUpload.compactMap {
                
                let operation = UploadOperation(item: $0, uploadType: .syncToUse, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, handler: { [weak self] finishedOperation, error in
                    self?.dispatchQueue.async { [weak self] in
                        guard let `self` = self else {
                            syncToUseFileListOperationsCallBack(nil)
                            return
                        }
                        
                        let checkIfFinished = {
                            if self.uploadOperations.filter({ $0.uploadType == .syncToUse }).isEmpty {
                                self.trackUploadItemsFinished(items: itemsToUpload)
                                success()
                                ItemOperationManager.default.syncFinished()
                                self.widgetNotifySyncFinished()
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
                            ItemOperationManager.default.failedUploadFile(file: finishedOperation.inputItem, error: error)
                            fail(error)
                            //                    }
                            return
                        }
                        
                        if let fileName = finishedOperation.inputItem.name {
                            self.logEvent("FinishUpload \(fileName)")
                        }
                        
                        self.uploadOperations.removeIfExists(finishedOperation)
                        
                        self.finishedSyncToUseOperationsCount += 1
                        
                        self.showCardProgress(type: .upload)
                        
                        if let outputItem = finishedOperation.outputItem {
                            ItemOperationManager.default.finishedUploadFile(file: outputItem)
                            finishedOperation.inputItem.copyFileData(from: outputItem)
                        }
                        
                        checkIfFinished()
                    }
                })
                operation.queuePriority = .veryHigh
                return operation
            }
            self.uploadOperations.append(operations)
            
            self.uploadQueue.addOperations(operations, waitUntilFinished: false)
            debugLog("UPLOADING upload: \(operations.count) have been added to the upload queue")
            print("UPLOADING upload: \(operations.count) have been added to the upload queue")
            
            syncToUseFileListOperationsCallBack(self.uploadOperations.filter({ $0.uploadType == .syncToUse }))
//        }
    }
    
    private func uploadFileList(items: [WrapData], uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, projectId: String? = nil, isCollage: Bool = false, success: @escaping FileOperationSucces, fail: @escaping FailResponse, returnedOprations: @escaping ([UploadOperation]?) -> Void) {
        
        // filter all items which md5's are not in the uploadOperations
        let itemsToUpload = items.filter { item -> Bool in
            (self.uploadOperations.first(where: { operation -> Bool in
                if operation.inputItem.md5 == item.md5 && operation.uploadType == .autoSync && !operation.isExecuting {
                    operation.cancel()
                    self.uploadOperations.removeIfExists(operation)
                    return false
                }
                return operation.inputItem.md5 == item.md5
            }) == nil)
        }
        
        guard !itemsToUpload.isEmpty, let firstObject = itemsToUpload.first else {
            returnedOprations(nil)
            return
        }
        
        let cardType = UploadService.convertUploadType(uploadType: uploadType)
        
        showCardProgress(type: cardType, object: firstObject, newItemsCount: itemsToUpload.count, forced: true)
        
        if uploadType != .sharedWithMe {
            self.widgetNotifySyncExecute(finishedCount: self.currentUploadOperationNumber,
                                         totalCount: self.allSyncToUseOperationsCount + self.allUploadOperationsCount + itemsToUpload.count,
                                         firstFileName: firstObject.name ?? "")
        }
        
        
        // change cells into inQueue state
        itemsToUpload.forEach { ItemOperationManager.default.startUploadFile(file: $0) }
        
        self.logSyncSettings(state: "StartUploadFileList")
        
        let operations: [UploadOperation] = itemsToUpload.compactMap {
            let operation = UploadOperation(item: $0, uploadType: uploadType, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, projectId: projectId, isCollage: isCollage, handler: { [weak self] finishedOperation, error in
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
                                self.widgetNotifySyncFinished()
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
                            self.showCardProgress(type: cardType)
                            checkIfFinished()
                        } else {
                            self.uploadOperations.removeIfExists(finishedOperation)
                            if let fileName = finishedOperation.inputItem.name {
                                self.logEvent("FinishUpload \(fileName) FAIL: \(error.errorDescription ?? error.description)")
                            }
                            ItemOperationManager.default.failedUploadFile(file: finishedOperation.inputItem, error: error)
                            fail(error)
                        }
                        return
                    }
                    
                    if let fileName = finishedOperation.inputItem.name {
                        self.logEvent("FinishUpload \(fileName)")
                    }
                    
                    self.uploadOperations.removeIfExists(finishedOperation)
                    
                    if uploadType == .sharedWithMe {
                        self.finishedSharedWithMeUploadOperationsCount += 1
                    } else {
                        self.finishedUploadOperationsCount += 1
                    }
                    
                    self.showCardProgress(type: cardType)
                    
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
        
        uploadQueue.addOperations(operations, waitUntilFinished: false)
        debugLog("UPLOADING upload: \(operations.count) have been added to the upload queue")
        print("UPLOADING upload: \(operations.count) have been added to the upload queue")
        let operationsToReturn = uploadOperations.filter({ $0.uploadType.isContained(in: [uploadType]) })
        returnedOprations(operationsToReturn)
    }
    
    private func syncFileList(items: [WrapData], uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", isFavorites: Bool = false, isFromAlbum: Bool = false, success: @escaping FileOperationSucces, fail: @escaping FailResponse, syncOperationsListCallBack: @escaping ([UploadOperation]?) -> Void) {
//        dispatchQueue.async { [weak self] in
//            guard let `self` = self else {
//                syncOperationsListCallBack(nil)
//                return
//            }
            // filter all items which md5's are not in the uploadOperations
            let itemsToSync = items.filter { item -> Bool in
                (self.uploadOperations.first(where: { operation -> Bool in
                    return operation.inputItem.md5 == item.md5
                }) == nil)
            }
            
            guard !itemsToSync.isEmpty, let firstObject = itemsToSync.first else {
                syncOperationsListCallBack(nil)
                return
            }
            
            print("AUTOSYNC: trying to add \(itemsToSync.count) item(s) of \(firstObject.fileType) type")
        
            self.showCardProgress(type: .sync, object: firstObject, newItemsCount: itemsToSync.count, forced: true)

            self.widgetNotifySyncExecute(finishedCount: self.currentSyncOperationNumber,
                                         totalCount: self.allSyncOperationsCount + itemsToSync.count,
                                         firstFileName: firstObject.name ?? "")

            // change cells into inQueue state
            itemsToSync.forEach { ItemOperationManager.default.startUploadFile(file: $0) }
            
            self.logSyncSettings(state: "StartSyncFileList")
            
            var successHandled = false

            let operations: [UploadOperation] = itemsToSync.compactMap {
                let operation = UploadOperation(item: $0, uploadType: .autoSync, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, isFavorites: isFavorites, isFromAlbum: isFromAlbum, handler: { [weak self] finishedOperation, error in
                    self?.dispatchQueue.async { [weak self] in
                        guard let `self` = self else {
                            syncOperationsListCallBack(nil)
                            return
                        }
                        
                        let checkIfFinished = {
                            if !successHandled, self.uploadOperations.filter({ $0.uploadType == .autoSync && $0.inputItem.fileType == finishedOperation.inputItem.fileType }).isEmpty {
                                successHandled = true
                                self.trackUploadItemsFinished(items: itemsToSync)
                                self.stopTracking()
                                success()
                                ItemOperationManager.default.syncFinished()
                                self.widgetNotifySyncFinished()
                                self.hideIfNeededCard(for: .autoSync)
                                self.logSyncSettings(state: "FinishedSyncFileList")
                                return
                            }
                        }
                        
                        if let error = error {
                            if finishedOperation.isCancelled {
                                ItemOperationManager.default.cancelledUpload(file: finishedOperation.inputItem)
                                /// don't call main thread here due a lot of cancel operations
                                checkIfFinished()
                            } else {
                                if let fileName = finishedOperation.inputItem.name {
                                    self.logEvent("FinishUpload \(fileName) FAIL: \(error.errorDescription ?? "")")
                                }
                                self.uploadOperations.removeIfExists(finishedOperation)
                                self.stopTracking()
                                ItemOperationManager.default.failedUploadFile(file: finishedOperation.inputItem, error: error)
                                self.showCardProgress(type: .sync)
                                
                                fail(error)
                                checkIfFinished()
                            }
                            return
                        }
                        
                        if let fileName = finishedOperation.inputItem.name {
                            self.logEvent("FinishUpload \(fileName)")
                        }
                        self.uploadOperations.removeIfExists(finishedOperation)
                        
                        if finishedOperation.inputItem.fileType == .image { self.finishedPhotoSyncOperationsCount += 1 } else if finishedOperation.inputItem.fileType == .video { self.finishedVideoSyncOperationsCount += 1 }
                        
                        self.showCardProgress(type: .sync)
                        
                        if let outputItem = finishedOperation.outputItem {
                            ItemOperationManager.default.finishedUploadFile(file: outputItem)
                            finishedOperation.inputItem.copyFileData(from: outputItem)
                        }
                        
                        checkIfFinished()
                    }
                })
                
                operation.queuePriority = firstObject.fileType == .image ? .normal : .low // start images sync first
                return operation
            }
            self.uploadOperations.append(operations)
            
            self.uploadQueue.addOperations(operations, waitUntilFinished: false)
            debugLog("AUTOSYNC: \(operations.count) \(firstObject.fileType)(s) have been added to the sync queue")
            print("AUTOSYNC: \(operations.count) \(firstObject.fileType)(s) have been added to the sync queue")
            
            syncOperationsListCallBack(self.uploadOperations.filter({ $0.uploadType == .autoSync }))
//        }
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
        debugLog("SYNC: Cancel Operations")
        uploadOperations.forEach { $0.cancel() }
        uploadOperations.removeAll()
        
        clearUploadCounters()
        clearSyncToUseCounters()
        clearSharedWithMeUploadCounters()
        clearSyncCounters()
        
        CardsManager.default.stopOperationWith(type: .upload)
        CardsManager.default.stopOperationWith(type: .sharedWithMeUpload)
        CardsManager.default.stopOperationWith(type: .sync)
        ItemOperationManager.default.syncFinished()
        
        widgetNotifySyncStopped()
    }
    
    func cancelSyncToUseOperations() {
        var operationsToRemove = uploadOperations.filter({ $0.uploadType == .syncToUse })
        
        cancelAndRemove(operations: operationsToRemove)
        
        print("AUTOSYNC: removed \(operationsToRemove.count) operations")
        operationsToRemove.removeAll()
    }
    
    func cancelUploadOperations() {
        var operationsToRemove = uploadOperations.filter({ $0.uploadType.isContained(in: [.upload]) })
        
        cancelAndRemove(operations: operationsToRemove)
        
        operationsToRemove.removeAll()
    }
    
    func cancelUploadOperations(operations: [UploadOperation]) {
        cancelAndRemove(operations: operations)
    }
    
    func cancelSyncOperations(photo: Bool, video: Bool) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            print("AUTOSYNC: cancelling sync operations for \(photo ? "photo" : "video")")
            let time = Date()
            var operationsToRemove = self.uploadOperations.filter({ $0.uploadType == .autoSync &&
                ((video && $0.inputItem.fileType == .video) || (photo && $0.inputItem.fileType == .image)) })
            
            print("AUTOSYNC: found \(operationsToRemove.count) operations to remove in \(Date().timeIntervalSince(time)) secs")
            self.cancelAndRemove(operations: operationsToRemove)
            
            print("AUTOSYNC: removed \(operationsToRemove.count) operations in \(Date().timeIntervalSince(time)) secs")
            operationsToRemove.removeAll()
            
            if photo {
                self.finishedPhotoSyncOperationsCount = 0
            }
            if video {
                self.finishedVideoSyncOperationsCount = 0
            }
            
            self.showCardProgress(type: .sync)
        }
    }
    
    func cancelOperations(md5s: [String]) {
        guard !md5s.isEmpty else {
            return
        }
        
        var operationsToRemove = uploadOperations.filter {
            !$0.isCancelled && md5s.contains($0.inputItem.md5)
        }
        
        cancelAndRemove(operations: operationsToRemove)
        
        print("AUTOSYNC: removed \(operationsToRemove.count) operations")
        operationsToRemove.removeAll()
    }
    
    func cancelOperations(with assets: [PHAsset]?) {
        guard let assets = assets else {
            return
        }
        
        var operationsToRemove = uploadOperations.filter { operation -> Bool in
            if let asset = operation.inputItem.asset {
                return !operation.isCancelled && assets.contains(asset)
            }
            return false
        }
        
        cancelAndRemove(operations: operationsToRemove)
        
        print("AUTOSYNC: removed \(operationsToRemove.count) operations")
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
            case .autoSync:
                clearSyncCounters()
                
            case .syncToUse:
                clearSyncToUseCounters()
                
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
    
    private func clearSyncToUseCounters() {
        print("UPLOAD: clearing sync to use counters")
        finishedSyncToUseOperationsCount = 0
    }
    
    private func clearSyncCounters() {
        print("AUTOSYNC: clearing sync counters")
        finishedPhotoSyncOperationsCount = 0
        finishedVideoSyncOperationsCount = 0
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
                    let json = JSON(data)
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
    
    func baseUrl(success: @escaping ValueHandler<URL?>, fail: FailResponse?) -> URLSessionTask {
        let param = UploadBaseURL()
        let handler = BaseResponseHandler<UploadBaseURLResponse, ObjectRequestResponse>(success: { result in
            success((result as? UploadBaseURLResponse)?.url)
        }, fail: fail)
        
        return executeGetRequest(param: param, handler: handler)
    }
    
    func uploadNotify(param: UploadNotify, success: @escaping SuccessResponse, fail: FailResponse?) {
        let handler = BaseResponseHandler<SearchItemResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
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
        let settings = autoSyncStorage.settings
        let photoSetting = autoSyncStorage.settings.isAutoSyncEnabled ? settings.photoSetting.option.localizedText : AutoSyncOption.never.localizedText
        let videoSetting = autoSyncStorage.settings.isAutoSyncEnabled ? settings.videoSetting.option.localizedText : AutoSyncOption.never.localizedText
        var logString = "Auto Sync Settings: PHOTOS: \(photoSetting) + VIDEOS: \(videoSetting)"
        logString += "; DEVICE NETWORK: \(reachabilityService.status)"
        logString += " --> \(state)"
        debugLog(logString)
    }
    
    @objc fileprivate func updateSyncSettings() {
        logSyncSettings(state: "Auto Sync setting changed")
    }
}

//Home widget notifications

extension UploadService {
    func widgetNotifySyncProgress(finishedCount: Int, totalCount: Int) {
        WidgetService.shared.notifyWidgetAbout(finishedCount, of: totalCount)
    }
    
    func widgetNotifySyncExecute(finishedCount: Int, totalCount: Int, firstFileName: String) {
        widgetNotifySyncProgress(finishedCount: finishedCount, totalCount: totalCount)
        WidgetService.shared.notifyWidgetAbout(syncFileName: firstFileName)
        WidgetService.shared.notifyWidgetAbout(status: .executing)
    }
    
    func widgetNotifySyncFinished() {
        WidgetService.shared.notifyWidgetAbout(status: .synced)
    }
    
    func widgetNotifySyncStopped() {
        WidgetService.shared.notifyWidgetAbout(status: .stopped)
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
