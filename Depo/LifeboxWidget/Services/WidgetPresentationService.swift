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
import WidgetKit

class UserInfo {
    var isFIREnabled = false
    var hasFIRPermission = false
    var peopleInfos = [PeopleInfo]()
}

class SyncInfo {
    var syncStatus: WidgetSyncStatus = .undetermined
    var isAutoSyncEnabled = false
    var isAppLaunch = false
    var totalCount = 0
    var uploadCount = 0
    var currentSyncFileName = ""
    var lastSyncedDate: Date?
}

final class WidgetPresentationService {
    static let shared = WidgetPresentationService()
    private let widgetService = WidgetService.shared
    private lazy var mainAppResponsivenessService = AppResponsivenessService.shared
    
    var isAuthorized: Bool { serverService.isAuthorized }
    var isPreparationFinished: Bool { widgetService.isPreparationFinished }
    
    private let serverService = WidgetServerService.shared
    private let photoLibraryService = WidgetPhotoLibraryObserver.shared
    
    private lazy var imageLoader = WidgetImageLoader()
    
    private lazy var defaults = UserDefaults(suiteName: SharedConstants.groupIdentifier)
    
    private var lastQuotaUsagePercentage: Int?
    private var lastQuotaUsageRequestDate: Date?

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

    //MARK: -
    
    init() {
        setupWormhole()
    }
    
    private func setupWormhole() {
        widgetService.wormhole.listenForMessage(withIdentifier: SharedConstants.wormholeDidLogout) { [weak self] _ in
            self?.didLogout()
        }
    }
    
    private func didLogout() {
        lastQuotaUsagePercentage = nil
        lastQuotaUsageRequestDate = nil
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func notifyChangeWidgetState(_ newState: WidgetState) {
        widgetService.notifyAboutChangeWidgetState(newState.gaName)
    }
    
    func messageEntryChanged(entry: WidgetStateOrder) {
        widgetService.wormhole.message(withIdentifier: SharedConstants.entryChangedKey)
    }
    
    func getStorageQuota(completion: @escaping ValueHandler<Int>) {
        
        if let lastQuotaUsagePercentage = lastQuotaUsagePercentage,
           let lastQuotaUsageRequestDate = lastQuotaUsageRequestDate,
           let eghtHoursSinceLastQuotaRequest = Calendar.current.date(byAdding: .hour, value: 8, to: lastQuotaUsageRequestDate),
           eghtHoursSinceLastQuotaRequest > Date()
           {
            completion(lastQuotaUsagePercentage)
            return
        }
        serverService.getQuotaInfo { [weak self] response in
            switch response {
            case .success(let quota):
                guard
                    let quotaBytes = quota.bytes,
                    let usedBytes = quota.bytesUsed
                else {
                    completion(.zero)
                    return
                }
                let usagePercentage = CGFloat(usedBytes) / CGFloat(quotaBytes)
                let quotaUsagePercentage = Int(usagePercentage * 100)
                self?.lastQuotaUsagePercentage = quotaUsagePercentage
                self?.lastQuotaUsageRequestDate = Date()
                completion(quotaUsagePercentage)
                
            case .failed:
                completion(.zero)
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
    
    func getContactBackupStatus(completion: @escaping ValueHandler<ContantBackupResponse?>) {
        serverService.getBackUpStatus(completion: completion)
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
        syncInfo.isAutoSyncEnabled = widgetService.isAutoSyncEnabled
        syncInfo.uploadCount = widgetService.finishedCount
        syncInfo.totalCount = widgetService.totalCount
        syncInfo.currentSyncFileName = widgetService.currentSyncFileName
        syncInfo.lastSyncedDate = widgetService.lastSyncedDate
        syncInfo.isAppLaunch = mainAppResponsivenessService.isMainAppResponsive()
        
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
