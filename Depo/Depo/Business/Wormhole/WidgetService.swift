//
//  WidgetService.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 2/7/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import MMWormhole
import WidgetKit

final class WidgetService {
    static let shared = WidgetService()
    
    //Using Wormhole is overkill but it's in the old app and we'll probably need it in a future
    private(set) lazy var wormhole: MMWormhole = MMWormhole(applicationGroupIdentifier: SharedConstants.groupIdentifier, optionalDirectory: SharedConstants.wormholeDirectoryIdentifier)
    
    private lazy var defaults = UserDefaults(suiteName: SharedConstants.groupIdentifier)
    
    init() {
        syncAppFirstLaunchFlags()
    }
    
    private func syncAppFirstLaunchFlags() {
        //sync isAppFirstLaunch flag for first widget install
        let storageIsAppFirstLaunch = UserDefaults.standard.object(forKey: SharedConstants.isAppFirstLaunchKey) as? Bool ?? true
        if isAppFirstLaunch && !storageIsAppFirstLaunch {
            isAppFirstLaunch = storageIsAppFirstLaunch
        }
    }
    
    var isAppFirstLaunch: Bool {
        get { return defaults?.object(forKey: SharedConstants.isAppFirstLaunchKey) as? Bool ?? true }
        set { defaults?.set(newValue, forKey: SharedConstants.isAppFirstLaunchKey) }
    }
    
    var isPreparationFinished: Bool {
        get { return defaults?.bool(forKey: SharedConstants.isPreparationFinished) ?? false }
        set { defaults?.set(newValue, forKey: SharedConstants.isPreparationFinished)}
    }
    
    var mainAppResponsivenessDate: Date? {
        get { return defaults?.object(forKey: SharedConstants.mainAppSchemeResponsivenessDateKey) as? Date }
        set { defaults?.set(newValue, forKey: SharedConstants.mainAppSchemeResponsivenessDateKey)}
    }
    
    private (set) var totalCount: Int {
        get { return defaults?.integer(forKey: SharedConstants.totalAutoSyncCountKey) ?? 0 }
        set { defaults?.set(newValue, forKey: SharedConstants.totalAutoSyncCountKey) }
    }
    
    private (set) var finishedCount: Int {
        get { return defaults?.integer(forKey: SharedConstants.finishedAutoSyncCountKey) ?? 0 }
        set { defaults?.set(newValue, forKey: SharedConstants.finishedAutoSyncCountKey) }
    }
    
    private (set) var lastSyncedDate: Date? {
        get {
            if let timeinterval = defaults?.double(forKey: SharedConstants.lastSyncDateKey) {
                return Date(timeIntervalSince1970: timeinterval)
            }
            return nil
        }
        set { defaults?.set(newValue?.timeIntervalSince1970, forKey: SharedConstants.lastSyncDateKey) }
    }
    
    private (set) var currentSyncFileName: String {
        get { return defaults?.string(forKey: SharedConstants.currentSyncFileNameKey) ?? "" }
        set { defaults?.set(newValue, forKey: SharedConstants.currentSyncFileNameKey) }
    }
    
    private (set) var widgetShownSyncStatus: WidgetSyncStatus {
        get {
            let statusValue = defaults?.string(forKey: SharedConstants.widgetShownSyncStatusKey) ?? ""
            return WidgetSyncStatus(rawValue: statusValue) ?? .undetermined
        }
        set { defaults?.set(newValue.rawValue, forKey: SharedConstants.widgetShownSyncStatusKey) }
    }
    
    private (set) var syncStatus: WidgetSyncStatus {
        get {
            let statusValue = defaults?.string(forKey: SharedConstants.syncStatusKey) ?? ""
            return WidgetSyncStatus(rawValue: statusValue) ?? .undetermined
        }
        set { defaults?.set(newValue.rawValue, forKey: SharedConstants.syncStatusKey) }
    }
    
    private (set) var isAutoSyncEnabled: Bool {
        get { defaults?.bool(forKey: SharedConstants.autoSyncEnabledKey) ?? false }
        set { defaults?.set(newValue, forKey: SharedConstants.autoSyncEnabledKey) }
    }
    
    private var currentImageData: Data? {
        get { return defaults?.data(forKey: SharedConstants.currentImageDataKey) }
        set { defaults?.set(newValue, forKey: SharedConstants.currentImageDataKey) }
    }
    
    var currentCompressedImage: UIImage? {
        guard let data = currentImageData else {
            return nil
        }
        
        var compressedImage = UIImage(data: data)
        compressedImage = compressedImage?.resizedImage(to: CGSize(width: 100, height: 100))
        return compressedImage
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter
    }()
    
    
    func notifyWidgetAbout(_ synced: Int, of total: Int) {
        finishedCount = synced
        //TODO: remove count check after queue is implemented
        if total != totalCount {
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        totalCount = total
        lastSyncedDate = Date()
        
        wormhole.passMessageObject(nil, identifier: SharedConstants.wormholeMessageIdentifier)
    }
    
    func notifyWidgetAbout(syncFileName: String) {
        currentSyncFileName = syncFileName
    }
    
    func notifyWidgetAbout(currentImage: UIImage?) {
//        currentImageData = currentImage?.jpeg(.low)
        wormhole.passMessageObject(nil, identifier: SharedConstants.wormholeMessageIdentifier)
    }
    
    func notifyWidgetAbout(status: WidgetSyncStatus) {
        guard syncStatus != status else {
            return
        }
        
        syncStatus = status
        
        if syncStatus != .executing {
            finishedCount = 0
            totalCount = 0
            currentImageData = nil
            currentSyncFileName = ""
        }
        
        if syncStatus != .undetermined {
            //TODO: maybe not need to reload on stopped state
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        
        wormhole.passMessageObject(nil, identifier: SharedConstants.wormholeMessageIdentifier)
    }
    
    func notifyAboutChangeWidgetState(_ newStateName: String) {
        wormhole.passMessageObject(newStateName as NSString, identifier: SharedConstants.wormholeNewWidgetStateIdentifier)
    }
    
    func notifyWidgetAbout(autoSyncEnabled: Bool) {
        isAutoSyncEnabled = autoSyncEnabled
        //TODO: remove it after queue is implemented
        if autoSyncEnabled {
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    func notifyAbout(shownSyncStatus: WidgetSyncStatus) {
        guard widgetShownSyncStatus != shownSyncStatus else {
            return
        }
        
        widgetShownSyncStatus = shownSyncStatus
    }
}
