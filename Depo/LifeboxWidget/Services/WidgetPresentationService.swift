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
    var imageUrls = [URL?]()
}

class SyncInfo {
    var shownSyncStatus: WidgetSyncStatus = .undetermined
    var syncStatus: WidgetSyncStatus = .undetermined
    var isAutoSyncEnabled = false
    var isAppLaunch = false
    var totalCount = 0
    var uploadCount = 0
    var currentSyncFileName = ""
    var lastSyncedDate: Date?
}

protocol WidgetPresentationServiceDelegate: class {
    func didLogout()
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

    weak var delegate: WidgetPresentationServiceDelegate?
    
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
        delegate?.didLogout()
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
                
            case .failed(let error):
                DebugLogService.debugLog("ORDER 1: getQuotaInfo failed - \(error.localizedDescription)")
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
        group.enter()
        
        group.notify(queue: .global()) { [weak self] in
            if userInfo.hasFIRPermission && !userInfo.isFIREnabled {
                //for 7.3 display placeholders
                completion((userInfo, false))
                return
            }
            
            func load(urls: [URL?]) {
                userInfo.imageUrls = urls
                self?.loadImages(urls: urls, completion: { isLoadingImages in
                    completion((userInfo, isLoadingImages))
                })
            }
            
            if userInfo.hasFIRPermission && userInfo.isFIREnabled {
                //for 7.1,7.2 display people avatars
                let urls = userInfo.peopleInfos.map { $0.thumbnail ?? $0.alternateThumbnail }
                load(urls: urls)
            } else {
                //for 7.4 display last uploads
                self?.serverService.lastUploads { lastUploadsUrls in
                    load(urls: lastUploadsUrls)
                }
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
        
        getPeopleInfo { peopleInfos in
            userInfo.peopleInfos = Array(peopleInfos.prefix(3))
            group.leave()
        }
    }
    
    func hasUnsyncedItems(completion: @escaping (Bool) -> ()) {
        photoLibraryService.hasUnsynced(completion: completion)
    }
    
    func getSyncInfo() -> SyncInfo {
        let syncInfo = SyncInfo()
        syncInfo.shownSyncStatus = widgetService.widgetShownSyncStatus
        syncInfo.syncStatus = widgetService.syncStatus
        syncInfo.isAutoSyncEnabled = widgetService.isAutoSyncEnabled
        syncInfo.uploadCount = widgetService.finishedCount
        syncInfo.totalCount = widgetService.totalCount
        syncInfo.currentSyncFileName = widgetService.currentSyncFileName
        syncInfo.lastSyncedDate = widgetService.lastSyncedDate
        syncInfo.isAppLaunch = mainAppResponsivenessService.isMainAppResponsive()
        
        return syncInfo
    }
    
    func save(shownSyncStatus: WidgetSyncStatus) {
        widgetService.notifyAbout(shownSyncStatus: shownSyncStatus)
    }
    
    private func getFaceImageEnabled(completion: @escaping ((Bool) -> ())) {
        serverService.getSettingsInfoPermissions { response in
            switch response {
            case .success(let response):
                let isFIREnabled = response.isFaceImageAllowed == true
                DebugLogService.debugLog("ORDER 7: isFIREnabled == \(isFIREnabled)")
                completion(isFIREnabled)
            case .failed(let error):
                DebugLogService.debugLog("ORDER 7: get FIR enabled failed - \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    private func getFaceImageRecognitionStatus(completion: @escaping BoolHandler) {
        serverService.permissions { response in
            switch response {
            case .success(let response):
                let hasFIRPermission = response.hasPermissionFor(.faceRecognition)
                DebugLogService.debugLog("ORDER 7: hasFIRPermission == \(hasFIRPermission)")
                completion(hasFIRPermission)
            case .failed(let error):
                DebugLogService.debugLog("ORDER 7: get FIR permission failed - \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    private func getPeopleInfo(completion: @escaping ValueHandler<[PeopleInfo]>) {
        serverService.getPeopleInfo { result in
            switch result {
            case .success(let response):
                completion(response.personInfos)
            case .failed(let error):
                DebugLogService.debugLog("ORDER 7: getPeopleInfo failed - \(error.localizedDescription)")
                completion([])
            }
        }
    }
    
    private func loadImages(urls: [URL?], completion: @escaping ValueHandler<Bool>) {
        imageLoader.loadImage(urls: urls) { loadingImages in
            completion(loadingImages.firstIndex(where: { $0 == nil }) != nil)
        }
    }
    
    func isPhotoLibriaryAvailable() -> Bool {
        return photoLibraryService.isPhotoLibriaryAccessable()
    }
}
