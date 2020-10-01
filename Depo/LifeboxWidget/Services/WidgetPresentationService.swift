//
//  WidgetPresentationService.swift
//  LifeboxWidgetExtension
//
//  Created by Roman Harhun on 03/09/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import CoreGraphics
import MMWormhole

class UserInfo {
    var isFIREnabled = false
    var hasFIRPermission = false
    var peopleInfos = [PeopleInfo]()
}

class SyncInfo {
    var syncStatus: AutoSyncStatus = .undetermined
    var isAppLaunch = false
    var totalCount = 0
    var uploadCount = 0
}

final class WidgetPresentationService {
    static let shared = WidgetPresentationService()
    private let widgetService = WidgetService.shared
    
    var isAuthorized: Bool { serverService.isAuthorized }
    var isPreperationFinished: Bool { widgetService.isPreperationFinished }
    
    private let serverService = WidgetServerService.shared
    private let photoLibraryService = WidgetPhotoLibraryObserver.shared
    
    private lazy var imageLoader = WidgetImageLoader()
    
    private lazy var defaults = UserDefaults(suiteName: SharedConstants.groupIdentifier)

    //TODO: change to enum?
    var lastWidgetEntry: WidgetBaseEntry? {
        get {
            if let typeString = lastWidgetEntryType, let type: WidgetBaseEntry.Type = NSClassFromString(typeString) as? WidgetBaseEntry.Type {
                return try? defaults?.getObject(forKey: SharedConstants.lastWidgetEntryKey, castTo: type)
            }
            return try? defaults?.getObject(forKey: SharedConstants.lastWidgetEntryKey, castTo: WidgetBaseEntry.self) }
        set {
            if let object = newValue {
                lastWidgetEntryType = String(describing: object.self)
            }
            try? defaults?.setObject(newValue, forKey: SharedConstants.lastWidgetEntryKey)
        }
    }
    
    private var lastWidgetEntryType: String? {
        get { return defaults?.string(forKey: SharedConstants.lastWidgetEntryTypeKey) }
        set { defaults?.set(newValue, forKey: SharedConstants.lastWidgetEntryTypeKey) }
    }
    
    init() {
        setupWormhole()
    }
    
    func notifyChangeWidgetState(_ newState: WidgetState) {
        widgetService.notifyAboutChangeWidgetState(newState.gaName)
    }
    
    private func setupWormhole() {
        widgetService.wormhole.listenForMessage(withIdentifier: SharedConstants.wormholeMessageIdentifier) { [weak self] messageObject in

        }
    }
    
    func messageEntryChanged(entry: WidgetStateOrder) {
        widgetService.wormhole.message(withIdentifier: SharedConstants.entryChangedKey)
    }
    
    func getStorageQuota(completion: @escaping ValueHandler<Int>, fail: @escaping VoidHandler) {
        serverService.getQuotaInfo { response in
            switch response {
            case .success(let quota):
                guard
                    let quotaBytes = quota.bytes,
                    let usedBytes = quota.bytesUsed
                else {
                    fail()
                    return
                }
                let usagePercentage = CGFloat(usedBytes) / CGFloat(quotaBytes)
                completion(Int(usagePercentage * 100))
            case .failed:
                fail()
            }
        }
    }
    
    func getDeviceStorageQuota(completion: @escaping ValueHandler<Int>){
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])
            let usedPersentage: CGFloat
            if let capacity = values.volumeAvailableCapacityForImportantUsage, let total = values.volumeTotalCapacity {
                usedPersentage = CGFloat(capacity) / CGFloat(total)
            } else {
                usedPersentage = .zero
            }
            completion(100 - (Int(usedPersentage * 100)))
        } catch {
            completion(.zero)
        }
    }
    
    func getContactBackupStatus(completion: @escaping ValueHandler<ContantBackupResponse>, fail: @escaping VoidHandler) {
        serverService.getBackUpStatus(completion: completion, fail: fail)
    }
    
    func getFIRStatus(completion: @escaping ValueHandler<(userInfo: UserInfo, isLoadingImages: Bool)>) {
        let userInfo = UserInfo()
        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        
        group.notify(queue: .global()) { [weak self] in
            if userInfo.hasFIRPermission && userInfo.isFIREnabled {
                self?.getPeopleInfo { [weak self] peopleInfos in
                    userInfo.peopleInfos = peopleInfos
                    self?.loadImages { isLoadingImages in
                        completion((userInfo, isLoadingImages))
                    }
                }
            } else {
                completion((userInfo, false))
            }
        }

        getFaceImageEnabled { face in
            userInfo.isFIREnabled = face
            group.leave()
        }
        
        getFaceImageRecognitionStatus { hasFIRPermission in
            userInfo.hasFIRPermission = hasFIRPermission
            group.leave()
        }
    }
    
    func hasUnsyncedItems(completion: @escaping (Bool) -> ()) {
        photoLibraryService.hasUnsynced(completion: completion)
    }
    
    func getSyncInfo() -> SyncInfo {
        let syncInfo = SyncInfo()
        syncInfo.syncStatus = widgetService.syncStatus
        syncInfo.uploadCount = widgetService.finishedCount
        syncInfo.totalCount = widgetService.totalCount
        
        if let date = widgetService.mainAppResponsivenessDate, date.timeIntervalSince(Date()) < NumericConstants.intervalInSecondsBetweenAppResponsivenessUpdate * 0.1 {
            syncInfo.isAppLaunch = true
        } else {
            syncInfo.isAppLaunch = false
        }
        
        return syncInfo
    }
    
    private func getFaceImageEnabled(completion: @escaping ((Bool) -> ())) {
        serverService.getSettingsInfoPermissions { response in
            switch response {
            case .success(let response):
                completion(response.isFaceImageAllowed == true)
            case .failed:
                completion(false)
            }
        }
    }
    
    private func getFaceImageRecognitionStatus(completion: @escaping BoolHandler) {
        serverService.permissions { response in
            switch response {
            case .success(let response):
                completion(response.hasPermissionFor(.faceRecognition))
            case .failed:
                completion(false)
            }
        }
    }
    
    private func getPeopleInfo(completion: @escaping ValueHandler<[PeopleInfo]>) {
        serverService.getPeopleInfo { result in
            switch result {
            case .success(let response):
                completion(response.personInfos)
            case .failed:
                completion([])
            }
        }
    }
    
    private func loadImages(completion: @escaping ValueHandler<Bool>) {
        getPeopleInfo { [weak self] peopleInfos in
            let urls = peopleInfos.map { $0.thumbnail ?? $0.alternateThumbnail }
            self?.imageLoader.loadImage(urls: urls) { loadingImages in
                completion(loadingImages.firstIndex(where: { $0 == nil }) != nil)
            }
        }
    }
    
    func isPhotoLibriaryAvailable() -> Bool {
        return photoLibraryService.isPhotoLibriaryAccessable()
    }
}
